import 'package:flutter/material.dart';
import 'package:ground_guard_app/core/theme/app_colors.dart';
import 'package:ground_guard_app/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ground_guard_app/core/theme/app_spacing.dart';

class AppTheme {
  static BorderRadius radiusSM = BorderRadius.circular(8);
  static BorderRadius radiusMD = BorderRadius.circular(16);
  static BorderRadius radiusLG = BorderRadius.circular(24);
  static BorderRadius radiusXL = BorderRadius.circular(32);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,

      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,

      tertiary: AppColors.tertiary,

      surface: AppColors.surface,
      onSurface: AppColors.onSurface,

      error: AppColors.error,

      outline: AppColors.outline,
    ),

    textTheme: AppTextStyle.textStyleTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceContainer,
      elevation: 0,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: radiusLG,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
        backgroundColor: AppColors.mintAccent.withOpacity(0.25),
        foregroundColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.15),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        textStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF4F4EF),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),

      hintStyle: GoogleFonts.quicksand(
        color: AppColors.outline,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),

      border: OutlineInputBorder(
        borderRadius: radiusMD,
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: radiusMD,
        borderSide: BorderSide(
          color: AppColors.outline.withOpacity(0.1),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: radiusMD,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.mintAccent,
      disabledColor: Colors.grey.shade300,
      selectedColor: AppColors.secondaryContainer,
      secondarySelectedColor: AppColors.tertiaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
      ),
      labelStyle: GoogleFonts.quicksand(
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.outline,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondaryContainer,
      foregroundColor: AppColors.primary,
      elevation: 0,
    ),
  );
}
