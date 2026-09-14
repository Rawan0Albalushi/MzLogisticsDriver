import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFFF25C05);
  static const Color primaryDark = Color(0xFFD94E00);
  static const Color primarySoft = Color(0xFFFFF1E6);
  static const Color primaryMuted = Color(0xFFFFD8B8);

  static const Color ink = Color(0xFF1A120E);
  static const Color muted = Color(0xFF6F5E55);
  static const Color surface = Color(0xFFFFF8F3);
  static const Color surfaceAlt = Color(0xFFF7EDE6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFF0E2D8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF1F8A4C);
  static const Color successSoft = Color(0xFFE4F6EC);
  static const Color danger = Color(0xFFD6453D);
  static const Color dangerSoft = Color(0xFFFDECEC);
  static const Color info = Color(0xFF2F6F9F);

  /// Kept for older call sites that still name the brand color amber/navy.
  static const Color amber = primary;
  static const Color onAccent = onPrimary;
  static const Color navy = ink;
  static const Color navyMuted = Color(0xFFB9A59A);
  static const Color accentFrom = Color(0xFFFF8A3D);
  static const Color accentTo = primaryDark;

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentFrom, accentTo],
  );
}
