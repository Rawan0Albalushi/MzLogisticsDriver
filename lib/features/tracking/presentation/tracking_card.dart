import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_button.dart';
import '../data/location_service.dart';
import '../providers/tracking_controller.dart';

class TrackingCard extends ConsumerWidget {
  const TrackingCard({
    super.key,
    required this.tripId,
    this.lastLat,
    this.lastLng,
  });

  final int tripId;
  final double? lastLat;
  final double? lastLng;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final tracking = ref.watch(trackingControllerProvider(tripId));
    final controller = ref.read(trackingControllerProvider(tripId).notifier);
    final lat = tracking.lastLat ?? lastLat;
    final lng = tracking.lastLng ?? lastLng;

    final message = switch (tracking.issue) {
      LocationIssue.serviceDisabled => strings.t('gps.off'),
      LocationIssue.denied => strings.t('gps.denied'),
      LocationIssue.deniedForever => strings.t('gps.denied_forever'),
      LocationIssue.failed => strings.t('gps.failed'),
      LocationIssue.ready => switch (tracking.ui) {
          TrackingUiStatus.shared => strings.t('gps.shared'),
          TrackingUiStatus.offline => strings.t('gps.offline'),
          TrackingUiStatus.failed => strings.t('gps.failed'),
          _ => strings.t('gps.ready'),
        },
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.t('gps.title'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.muted, height: 1.4)),
          if (lat != null && lng != null) ...[
            const SizedBox(height: 8),
            Text(
              '${strings.t('gps.last')}: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: tracking.ui == TrackingUiStatus.failed ||
                    tracking.ui == TrackingUiStatus.offline
                ? strings.t('action.retry')
                : strings.t('action.share_location'),
            busy: tracking.ui == TrackingUiStatus.sharing,
            icon: Icons.my_location_rounded,
            onPressed: controller.share,
          ),
          if (tracking.issue == LocationIssue.deniedForever ||
              tracking.issue == LocationIssue.denied) ...[
            const SizedBox(height: 10),
            AppButton(
              label: strings.t('gps.open_settings'),
              tone: AppButtonTone.ghost,
              onPressed: () => ref.read(locationServiceProvider).openSettings(),
            ),
          ],
          if (tracking.issue == LocationIssue.serviceDisabled) ...[
            const SizedBox(height: 10),
            AppButton(
              label: strings.t('gps.open_settings'),
              tone: AppButtonTone.ghost,
              onPressed: () =>
                  ref.read(locationServiceProvider).openLocationSettings(),
            ),
          ],
        ],
      ),
    );
  }
}
