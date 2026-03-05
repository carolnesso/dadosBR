import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const sectionTitle = TextStyle(
    color: AppColors.accent,
    fontSize: 24,
    fontWeight: FontWeight.w900,
  );

  static const title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 20,
    fontWeight: FontWeight.w400,
  );

  static const description = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const caption = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const inputLabel = TextStyle(
    color: AppColors.accent,
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const resultLabel = TextStyle(
    color: AppColors.accent,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const resultValue = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
}
