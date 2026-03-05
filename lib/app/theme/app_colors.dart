import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const accent = Color(0xFFEFC179);
  static const accentDark = Color(0xFFD1882B);
  static const card = Color(0xFF1C1C1E);
  static const muted = Color(0xFF9A9A9A);

  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;

  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDark],
  );
}
