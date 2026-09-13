import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.tone = AppButtonTone.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final AppButtonTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    final colors = switch (tone) {
      AppButtonTone.primary => (AppColors.amber, AppColors.onAccent),
      AppButtonTone.navy => (AppColors.navy, AppColors.white),
      AppButtonTone.danger => (AppColors.danger, AppColors.white),
      AppButtonTone.ghost => (AppColors.white, AppColors.navy),
    };

    final child = busy
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 22),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    final style = FilledButton.styleFrom(
      backgroundColor: tone == AppButtonTone.primary ? Colors.transparent : colors.$1,
      foregroundColor: colors.$2,
      disabledBackgroundColor: AppColors.line,
      disabledForegroundColor: AppColors.muted,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: tone == AppButtonTone.ghost
            ? const BorderSide(color: AppColors.line)
            : BorderSide.none,
      ),
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );

    final button = FilledButton(
      onPressed: enabled ? onPressed : null,
      style: style,
      child: child,
    );

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.touch,
      child: tone == AppButtonTone.primary && enabled
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: button,
            )
          : button,
    );
  }
}

enum AppButtonTone { primary, navy, danger, ghost }
