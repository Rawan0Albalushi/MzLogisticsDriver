import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/breakpoints.dart';

class LargeScreenFrame extends StatelessWidget {
  const LargeScreenFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isDesktop(context)) {
      return child;
    }

    return ColoredBox(
      color: AppColors.surfaceAlt,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.frameMaxWidth),
            child: Material(
              color: AppColors.surface,
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
