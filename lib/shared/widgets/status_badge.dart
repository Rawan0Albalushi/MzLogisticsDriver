import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../models/trip_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    required this.label,
    this.light = false,
  });

  final TripStatus status;
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = switch (status.displayStage) {
      TripStatus.delivered => AppColors.success,
      TripStatus.cancelled => AppColors.danger,
      TripStatus.inTransit => AppColors.primary,
      _ => light ? AppColors.white : AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.16)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: light ? AppColors.white : color,
        ),
      ),
    );
  }
}
