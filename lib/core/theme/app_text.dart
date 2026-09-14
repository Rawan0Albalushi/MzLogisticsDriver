import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tight type scale for the driver app.
/// Use only these sizes so screens stay visually consistent.
class AppText {
  const AppText._();

  static const double captionSize = 12;
  static const double labelSize = 13;
  static const double bodySize = 15;
  static const double titleSize = 16;
  static const double headingSize = 20;
  static const double displaySize = 24;
  static const double numeralSize = 28;

  static const TextStyle caption = TextStyle(
    fontSize: captionSize,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  );

  static const TextStyle label = TextStyle(
    fontSize: labelSize,
    height: 1.35,
    fontWeight: FontWeight.w700,
    color: AppColors.muted,
  );

  static const TextStyle body = TextStyle(
    fontSize: bodySize,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: bodySize,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  static const TextStyle title = TextStyle(
    fontSize: titleSize,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle heading = TextStyle(
    fontSize: headingSize,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle display = TextStyle(
    fontSize: displaySize,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle numeral = TextStyle(
    fontSize: numeralSize,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 6,
    color: AppColors.primaryDark,
  );

  static const TextStyle button = TextStyle(
    fontSize: titleSize,
    height: 1.2,
    fontWeight: FontWeight.w800,
  );
}
