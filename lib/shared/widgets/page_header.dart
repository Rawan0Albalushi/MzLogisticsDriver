import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleAbove = false,
    this.largeTitle = false,
    this.showBack = false,
    this.extra,
  });

  final String title;
  final String? subtitle;
  final bool subtitleAbove;
  final bool largeTitle;
  final bool showBack;
  final Widget? extra;

  static const SystemUiOverlayStyle overlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.of(context).canPop();
    final titleStyle = (largeTitle ? AppText.display : AppText.heading)
        .copyWith(color: AppColors.white);
    final subtitleStyle = AppText.label.copyWith(
      color: AppColors.white.withValues(alpha: 0.82),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          MediaQuery.paddingOf(context).top + 12,
          AppSpacing.lg,
          20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: canPop ? 44 : 0),
              child: Column(
                children: [
                  if (subtitle != null && subtitleAbove) ...[
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: subtitleStyle,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: titleStyle,
                  ),
                  if (subtitle != null && !subtitleAbove) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: subtitleStyle,
                    ),
                  ],
                  if (extra != null) ...[
                    const SizedBox(height: 10),
                    extra!,
                  ],
                ],
              ),
            ),
            if (canPop)
              PositionedDirectional(
                start: 0,
                top: 0,
                child: _HeaderIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
