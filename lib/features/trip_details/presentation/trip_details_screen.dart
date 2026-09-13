import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/maps/google_maps_links.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/trip.dart';
import '../../../shared/models/trip_status.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/async_states.dart';
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
      appBar: AppBar(title: Text(strings.t('trip.details'))),
      body: tripAsync.when(
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
        data: (trip) => _TripBody(
          trip: trip,
          strings: strings,
          action: action,
          onUpdate: () async {
            final next = trip.status.nextApiValue;
            if (next == null) {
              return;
            }
            await ref.read(statusActionProvider(tripId).notifier).updateTo(next);
          },
          onPod: () => context.push('/trips/$tripId/pod'),
        ),
      ),
    );
  }
}

class _TripBody extends StatelessWidget {
  const _TripBody({
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
    final shipment = trip.job?.shipment;
    final nextKey = trip.status.nextActionKey;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                trip.reference,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
            StatusBadge(
              status: trip.status,
              label: strings.t(trip.status.labelKey),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _FlowDots(status: trip.status),
        if (trip.otpCode != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _OtpCard(code: trip.otpCode!, strings: strings),
        ],
        const SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: strings.t('trip.cargo'),
          lines: [
            shipment?.cargoType,
            shipment?.cargoDescription,
            if (shipment?.notes != null) shipment!.notes,
          ],
        ),
        const SizedBox(height: 12),
        _LocationCard(
          title: strings.t('trip.pickup'),
          address: trip.pickupLabel,
          lat: trip.pickupLat,
          lng: trip.pickupLng,
          strings: strings,
        ),
        const SizedBox(height: 12),
        _LocationCard(
          title: strings.t('trip.delivery'),
          address: trip.deliveryLabel,
          lat: trip.deliveryLat,
          lng: trip.deliveryLng,
          strings: strings,
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: strings.t('trip.quantity'),
          lines: [
            '${strings.t('trip.planned')}: ${_qty(trip.plannedQuantity)}',
            if (trip.deliveredQuantity != null)
              '${strings.t('trip.delivered_qty')}: ${_qty(trip.deliveredQuantity)}',
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          title: strings.t('trip.truck'),
          lines: [
            if (trip.truck?.plateNumber != null)
              '${strings.t('trip.plate')}: ${trip.truck!.plateNumber}',
            trip.truck?.label,
            if (trip.job?.customer != null)
              '${strings.t('trip.customer')}: ${trip.job!.customer!.name}',
          ],
        ),
        if (trip.status.canShareLocation) ...[
          const SizedBox(height: AppSpacing.lg),
          TrackingCard(
            tripId: trip.id,
            lastLat: trip.currentLat,
            lastLng: trip.currentLng,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (trip.status.needsPod)
          AppButton(
            label: strings.t('action.record_pod'),
            icon: Icons.assignment_turned_in_outlined,
            onPressed: onPod,
          )
        else if (nextKey != null)
          AppButton(
            label: action.error != null
                ? strings.t('action.retry')
                : strings.t(nextKey),
            busy: action.submitting,
            onPressed: onUpdate,
          ),
        if (action.error != null) ...[
          const SizedBox(height: 10),
          Text(
            action.offline ? strings.t('state.offline') : strings.t('state.error'),
            style: const TextStyle(color: AppColors.danger),
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
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        children: [
          Text(
            strings.t('trip.otp'),
            style: const TextStyle(color: Color(0xFFC5D0D6)),
          ),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(
              color: AppColors.amber,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.t('trip.otp_hint'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFC5D0D6), height: 1.4),
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
    this.lat,
    this.lng,
  });

  final String title;
  final String address;
  final AppStrings strings;
  final double? lat;
  final double? lng;

  @override
  Widget build(BuildContext context) {
    final hasCoords = lat != null && lng != null;
    return _InfoCard(
      title: title,
      lines: [
        address,
        if (hasCoords) GoogleMapsLinks.format(lat, lng),
      ],
      action: hasCoords
          ? TextButton.icon(
              onPressed: () => GoogleMapsLinks.open(lat: lat!, lng: lng!, navigate: true),
              icon: const Icon(Icons.navigation_outlined),
              label: Text(strings.t('action.navigate')),
            )
          : null,
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.lines, this.action});

  final String title;
  final List<String?> lines;
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
          Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            visible.isEmpty ? '—' : visible.join('\n'),
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          ?action,
        ],
      ),
    );
  }
}

class _FlowDots extends StatelessWidget {
  const _FlowDots({required this.status});

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final current = status.progressIndex;
    return Row(
      children: [
        for (var i = 0; i < TripStatus.driverFlow.length; i++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.amber : AppColors.line,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (i < TripStatus.driverFlow.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
