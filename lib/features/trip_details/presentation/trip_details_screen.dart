import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/maps/google_maps_links.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_status.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/icon_bubble.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../tracking/presentation/tracking_card.dart';
import '../providers/trip_details_providers.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final int tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final tripAsync = ref.watch(tripDetailsProvider(tripId));
    final action = ref.watch(statusActionProvider(tripId));

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('trip.details'),
            subtitle: tripAsync.valueOrNull?.reference,
            showBack: true,
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
          if (!trip.status.needsPod && nextKey == null) {
            return null;
          }
          return _TripActionBar(
            trip: trip,
            strings: strings,
            action: action,
            onUpdate: () async {
              final next = trip.status.nextApiValue;
              if (next == null) return;
              await ref.read(statusActionProvider(tripId).notifier).updateTo(next);
            },
            onPod: () => context.push('/trips/$tripId/pod'),
          );
        },
        orElse: () => null,
      ),
    );
  }
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
    return Material(
      color: AppColors.white,
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
              else if (nextKey != null)
                AppButton(
                  label: action.error != null
                      ? strings.t('action.retry')
                      : strings.t(nextKey),
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
    final shipment = trip.job?.shipment;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        8,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Appear(
          child: Row(
            children: [
              Expanded(
                child: Text(trip.reference, style: AppText.heading),
              ),
              StatusBadge(
                status: trip.status,
                label: strings.t(trip.status.labelKey),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Appear.stagger(
          index: 1,
          child: _FlowTrack(status: trip.status, strings: strings),
        ),
        if (trip.otpCode != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Appear.stagger(
            index: 2,
            child: _OtpCard(code: trip.otpCode!, strings: strings),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Appear.stagger(
          index: 3,
          child: _InfoCard(
            icon: Icons.inventory_2_outlined,
            title: strings.t('trip.cargo'),
            lines: [
              shipment?.cargoType,
              shipment?.cargoDescription,
              if (shipment?.notes != null) shipment!.notes,
            ],
          ),
        ),
        const SizedBox(height: 12),
        Appear.stagger(
          index: 4,
          child: _LocationCard(
            title: strings.t('trip.pickup'),
            address: trip.pickupLabel,
            lat: trip.pickupLat,
            lng: trip.pickupLng,
            strings: strings,
            icon: Icons.upload_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Appear.stagger(
          index: 5,
          child: _LocationCard(
            title: strings.t('trip.delivery'),
            address: trip.deliveryLabel,
            lat: trip.deliveryLat,
            lng: trip.deliveryLng,
            strings: strings,
            icon: Icons.flag_rounded,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 12),
        Appear.stagger(
          index: 6,
          child: _InfoCard(
            icon: Icons.scale_outlined,
            title: strings.t('trip.quantity'),
            lines: [
              '${strings.t('trip.planned')}: ${_qty(trip.plannedQuantity)}',
              if (trip.deliveredQuantity != null)
                '${strings.t('trip.delivered_qty')}: ${_qty(trip.deliveredQuantity)}',
            ],
          ),
        ),
        const SizedBox(height: 12),
        Appear.stagger(
          index: 7,
          child: _InfoCard(
            icon: Icons.local_shipping_outlined,
            title: strings.t('trip.truck'),
            lines: [
              if (trip.truck?.plateNumber != null)
                '${strings.t('trip.plate')}: ${trip.truck!.plateNumber}',
              trip.truck?.label,
              if (trip.job?.customer != null)
                '${strings.t('trip.customer')}: ${trip.job!.customer!.name}',
            ],
          ),
        ),
        if (AppConfig.liveTrackingEnabled && trip.status.canShareLocation) ...[
          const SizedBox(height: AppSpacing.lg),
          Appear.stagger(
            index: 8,
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

  String _qty(double? value) {
    if (value == null) {
      return strings.t('common.dash');
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({required this.code, required this.strings});

  final String code;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.primaryMuted),
      ),
      child: Column(
        children: [
          const IconBubble(
            icon: Icons.pin_rounded,
            size: 44,
            iconSize: 22,
          ),
          const SizedBox(height: 10),
          Text(
            strings.t('trip.otp'),
            style: AppText.label,
          ),
          const SizedBox(height: 6),
          Text(code, style: AppText.numeral),
          const SizedBox(height: 6),
          Text(
            strings.t('trip.otp_hint'),
            textAlign: TextAlign.center,
            style: AppText.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.title,
    required this.address,
    required this.strings,
    required this.icon,
    required this.color,
    this.lat,
    this.lng,
  });

  final String title;
  final String address;
  final AppStrings strings;
  final IconData icon;
  final Color color;
  final double? lat;
  final double? lng;

  @override
  Widget build(BuildContext context) {
    final hasCoords = lat != null && lng != null;
    return _InfoCard(
      icon: icon,
      iconColor: color,
      title: title,
      lines: [
        address,
        if (hasCoords) GoogleMapsLinks.format(lat, lng),
      ],
      action: hasCoords
          ? TextButton.icon(
              onPressed: () =>
                  GoogleMapsLinks.open(lat: lat!, lng: lng!, navigate: true),
              icon: const Icon(Icons.navigation_rounded),
              label: Text(strings.t('action.navigate')),
            )
          : null,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.lines,
    required this.icon,
    this.iconColor,
    this.action,
  });

  final String title;
  final List<String?> lines;
  final IconData icon;
  final Color? iconColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final visible = lines.whereType<String>().where((line) => line.isNotEmpty);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBubble(
                icon: icon,
                color: iconColor ?? AppColors.primary,
                size: 36,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: AppText.title),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            visible.isEmpty ? '—' : visible.join('\n'),
            style: AppText.body,
          ),
          ?action,
        ],
      ),
    );
  }
}

class _FlowTrack extends StatelessWidget {
  const _FlowTrack({required this.status, required this.strings});

  final TripStatus status;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final current = status.progressIndex;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < TripStatus.driverFlow.length; i++) ...[
                Expanded(
                  child: _FlowSegment(
                    filled: i < current,
                    active: i == current,
                  ),
                ),
                if (i < TripStatus.driverFlow.length - 1)
                  const SizedBox(width: 4),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.timeline_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strings.t(status.labelKey),
                  style: AppText.title.copyWith(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlowSegment extends StatelessWidget {
  const _FlowSegment({required this.filled, required this.active});

  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final base = filled || active ? AppColors.primary : AppColors.line;
    return Container(
      height: 7,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
