import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color ink = Color(0xFF24110C);
  static const Color navy = Color(0xFF2A120C);
  static const Color accentFrom = Color(0xFFFFB020);
  static const Color accentTo = Color(0xFFFF3B1F);
  static const Color amber = accentTo;
  static const Color onAccent = Color(0xFF1A0A06);
  static const Color surface = Color(0xFFF7F3F0);
  static const Color success = Color(0xFF2F6F4E);
  static const Color danger = Color(0xFFA33B32);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF6B5B55);
  static const Color line = Color(0xFFE4D8D2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color navyMuted = Color(0xFFE0C4B8);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentFrom, accentTo],
  );
}
