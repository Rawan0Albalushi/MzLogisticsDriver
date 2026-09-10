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
      color: AppColors.navy,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.frameMaxWidth),
            child: Material(
              color: AppColors.surface,
              elevation: 16,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
