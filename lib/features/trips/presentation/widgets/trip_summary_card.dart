import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/trip.dart';
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
    final background = emphasized ? AppColors.navy : AppColors.white;
    final titleColor = emphasized ? AppColors.white : AppColors.ink;
    final muted = emphasized ? const Color(0xFFC5D0D6) : AppColors.muted;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(emphasized ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: emphasized ? null : Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.reference,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: emphasized ? 22 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StatusBadge(
                    status: trip.status,
                    label: strings.t(trip.status.labelKey),
                    light: emphasized,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PlaceRow(
                icon: Icons.north_east_rounded,
                label: strings.t('trip.pickup'),
                value: trip.pickupLabel,
                color: titleColor,
                muted: muted,
              ),
              const SizedBox(height: 10),
              _PlaceRow(
                icon: Icons.south_east_rounded,
                label: strings.t('trip.delivery'),
                value: trip.deliveryLabel,
                color: titleColor,
                muted: muted,
              ),
              if (emphasized) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    strings.t('home.open_trip'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  const _PlaceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.muted,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: muted, fontSize: 13)),
              Text(
                value.isEmpty ? '—' : value,
                style: TextStyle(color: color, fontSize: 15, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
