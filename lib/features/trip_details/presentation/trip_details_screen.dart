import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_status.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../tracking/presentation/tracking_card.dart';
import '../providers/trip_details_providers.dart';
import 'widgets/trip_facts_sheet.dart';
import 'widgets/trip_progress_track.dart';
import 'widgets/trip_route_panel.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final action = ref.watch(statusActionProvider(tripId));
    final trip = tripAsync.valueOrNull;
    if (trip?.status == TripStatus.delivered &&
        !action.submitting &&
        action.error == null) {
      Future.microtask(
        () => ref.read(statusActionProvider(tripId).notifier).finishDelivered(),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('trip.details'),
            subtitle: trip?.reference,
            showBack: true,
            extra: trip == null
                ? null
                : StatusBadge(
                    status: trip.status,
                    label: strings.t(trip.status.labelKey),
                    light: true,
                  ),
          ),
          Expanded(
            child: tripAsync.when(
              loading: () => LoadingState(message: strings.t('state.loading')),
              error: (error, _) => ErrorState(
                message: errorMessageFor(
                  error,
                  strings.t('state.offline'),
                  strings.t('state.error'),
                ),
                retryLabel: strings.t('state.retry'),
                onRetry: () => ref.invalidate(tripDetailsProvider(tripId)),
              ),
              data: (trip) => _TripBody(trip: trip, strings: strings),
            ),
          ),
        ],
      ),
      bottomNavigationBar: tripAsync.maybeWhen(
        data: (trip) {
          final nextKey = trip.status.nextActionKey;
          final retryDelivered =
              trip.status == TripStatus.delivered && action.error != null;
          if (!trip.status.needsPod && nextKey == null && !retryDelivered) {
            return null;
          }
          return _TripActionBar(
            trip: trip,
            strings: strings,
            action: action,
            onUpdate: () async {
              if (trip.status == TripStatus.delivered) {
                await ref
                    .read(statusActionProvider(tripId).notifier)
                    .finishDelivered(retry: true);
                return;
              }
              final nextKey = trip.status.nextActionKey;
              if (nextKey == null) return;
              final confirmed = await _confirmStatusUpdate(
                context,
                strings,
                strings.t(nextKey),
              );
              if (!confirmed || !context.mounted) return;
              final updated = await ref
                  .read(statusActionProvider(tripId).notifier)
                  .advance();
              if (!context.mounted || updated == null) return;
              if (updated.status.needsPod) {
                context.push('/trips/$tripId/pod');
              }
            },
            onPod: () => context.push('/trips/$tripId/pod'),
          );
        },
        orElse: () => null,
      ),
    );
  }
}

Future<bool> _confirmStatusUpdate(
  BuildContext context,
  AppStrings strings,
  String actionLabel,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(actionLabel),
        content: Text(strings.t('action.status_confirm_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text(strings.t('common.confirm')),
          ),
        ],
      );
    },
  );
  return confirmed == true;
}

class _TripActionBar extends StatelessWidget {
  const _TripActionBar({
    required this.trip,
    required this.strings,
    required this.action,
    required this.onUpdate,
    required this.onPod,
  });

  final Trip trip;
  final AppStrings strings;
  final StatusActionState action;
  final Future<void> Function() onUpdate;
  final VoidCallback onPod;

  @override
  Widget build(BuildContext context) {
    final nextKey = trip.status.nextActionKey;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (action.error != null) ...[
                Text(
                  action.offline
                      ? strings.t('state.offline')
                      : strings.t('state.error'),
                  style: AppText.body.copyWith(color: AppColors.danger),
                ),
                const SizedBox(height: 8),
              ],
              if (trip.status.needsPod)
                AppButton(
                  label: strings.t('action.record_pod'),
                  icon: Icons.assignment_turned_in_rounded,
                  onPressed: onPod,
                )
              else if (nextKey != null || action.error != null)
                AppButton(
                  label: action.error != null
                      ? strings.t('action.retry')
                      : strings.t(nextKey!),
                  busy: action.submitting,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: onUpdate,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripBody extends StatelessWidget {
  const _TripBody({required this.trip, required this.strings});

  final Trip trip;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final showTracking =
        AppConfig.liveTrackingEnabled && trip.status.canShareLocation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        if (trip.status != TripStatus.cancelled) ...[
          Appear(
            child: TripProgressTrack(status: trip.status, strings: strings),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Appear.stagger(
          index: 1,
          child: TripRoutePanel(trip: trip, strings: strings),
        ),
        const SizedBox(height: AppSpacing.md),
        Appear.stagger(
          index: 2,
          child: TripFactsSheet(trip: trip, strings: strings),
        ),
        if (showTracking) ...[
          const SizedBox(height: AppSpacing.md),
          Appear.stagger(
            index: 3,
            child: TrackingCard(
              tripId: trip.id,
              lastLat: trip.currentLat,
              lastLng: trip.currentLng,
            ),
          ),
        ],
      ],
    );
  }
}
