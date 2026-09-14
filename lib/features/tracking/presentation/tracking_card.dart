import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/icon_bubble.dart';
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
      LocationIssue.serviceDisabled =>
        strings.t(kIsWeb ? 'gps.off_web' : 'gps.off'),
      LocationIssue.denied =>
        strings.t(kIsWeb ? 'gps.denied_web' : 'gps.denied'),
      LocationIssue.deniedForever =>
        strings.t(kIsWeb ? 'gps.denied_forever_web' : 'gps.denied_forever'),
      LocationIssue.failed => strings.t('gps.failed'),
      LocationIssue.ready => switch (tracking.ui) {
          TrackingUiStatus.shared => strings.t('gps.shared'),
          TrackingUiStatus.offline => strings.t('gps.offline'),
          TrackingUiStatus.failed => strings.t('gps.failed'),
          _ => strings.t('gps.ready'),
        },
    };

    final shared = tracking.ui == TrackingUiStatus.shared;

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
          Row(
            children: [
              IconBubble(
                icon: shared
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                color: shared ? AppColors.success : AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  strings.t('gps.title'),
                  style: AppText.title,
                ),
              ),
              if (shared)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: AppText.bodyMuted),
          if (lat != null && lng != null) ...[
            const SizedBox(height: 8),
            Text(
              '${strings.t('gps.last')}: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
              style: AppText.label,
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
              tracking.issue == LocationIssue.denied ||
              tracking.issue == LocationIssue.serviceDisabled) ...[
            const SizedBox(height: 10),
            AppButton(
              label: strings.t(
                kIsWeb ? 'gps.allow_location' : 'gps.open_settings',
              ),
              tone: AppButtonTone.ghost,
              icon: Icons.settings_outlined,
              onPressed: controller.resolveIssue,
            ),
          ],
        ],
      ),
    );
  }
}
