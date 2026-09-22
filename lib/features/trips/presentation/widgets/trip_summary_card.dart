import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../shared/models/trip.dart';
import '../../../../shared/widgets/pressable_scale.dart';
import '../../../../shared/widgets/status_badge.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({
    super.key,
    required this.trip,
    required this.strings,
    required this.onTap,
    this.emphasized = false,
  });

  final Trip trip;
  final AppStrings strings;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final date = formatTripDate(
      trip.tripDateRaw,
      Localizations.localeOf(context).languageCode,
    );
    final pickup = _placeName(trip.pickupCity, trip.pickupLabel);
    final delivery = _placeName(trip.deliveryCity, trip.deliveryLabel);

    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A1A120E),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const _MetaIcon(icon: Icons.local_shipping_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title,
                      ),
                      if (date != null) ...[
                        const SizedBox(height: 2),
                        Text(date, style: AppText.caption),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  status: trip.status,
                  label: strings.t(trip.status.labelKey),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.muted,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _RouteMarks(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _PlaceLine(
                            label: strings.t('trip.pickup'),
                            value: pickup,
                          ),
                          const SizedBox(height: 16),
                          _PlaceLine(
                            label: strings.t('trip.delivery'),
                            value: delivery,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (emphasized) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                ),
                child: Text(
                  strings.t('home.open_trip'),
                  style: AppText.button.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  const _MetaIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: AppColors.primary),
    );
  }
}

class _RouteMarks extends StatelessWidget {
  const _RouteMarks();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          const _StopIcon(
            icon: Icons.trip_origin_rounded,
            background: AppColors.primary,
            foreground: AppColors.white,
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 2,
                color: AppColors.primaryMuted,
              ),
            ),
          ),
          const _StopIcon(
            icon: Icons.place_rounded,
            background: AppColors.white,
            foreground: AppColors.ink,
            bordered: true,
          ),
        ],
      ),
    );
  }
}

class _StopIcon extends StatelessWidget {
  const _StopIcon({
    required this.icon,
    required this.background,
    required this.foreground,
    this.bordered = false,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: AppColors.ink, width: 1.6)
            : null,
      ),
      child: Icon(icon, size: 18, color: foreground),
    );
  }
}

class _PlaceLine extends StatelessWidget {
  const _PlaceLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption.copyWith(height: 1.2)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

String _placeName(String? city, String label) {
  final trimmed = city?.trim() ?? '';
  if (trimmed.isNotEmpty) return trimmed;
  if (label.trim().isEmpty) return '—';
  return label.split(',').last.trim();
}
