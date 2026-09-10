import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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
    final color = switch (status) {
      TripStatus.completed || TripStatus.delivered => AppColors.success,
      TripStatus.cancelled => AppColors.danger,
      TripStatus.inTransit || TripStatus.arrived => AppColors.amber,
      _ => light ? AppColors.white : AppColors.navy,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: light ? Colors.white.withValues(alpha: 0.12) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: light ? Colors.white24 : color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? AppColors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
