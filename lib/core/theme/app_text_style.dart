import 'package:flutter/material.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static final TextTheme textStyleTheme = TextTheme(
    headlineLarge: GoogleFonts.quicksand(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
      color: AppColors.onBackground,
    ),

    headlineMedium: GoogleFonts.quicksand(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.onBackground,
    ),

    bodyLarge: GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: AppColors.onBackground,
    ),

    bodyMedium: GoogleFonts.quicksand(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.onBackground,
    ),

    labelLarge: GoogleFonts.quicksand(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.4,
      color: AppColors.onBackground,
    ),
  );
}
