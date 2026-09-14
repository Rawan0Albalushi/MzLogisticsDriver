import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.background,
    this.size = 40,
    this.iconSize = 20,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
