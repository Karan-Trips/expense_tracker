import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';

export '../utils/screen_utils.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentTeal,
        secondary: AppColors.accentPurple,
        surface: AppColors.surface,
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: ScreenUtils.fontTextMBig,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: AppColors.surface.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.cardCircularRadius),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: AppColors.background,
          minimumSize: Size.fromHeight(ScreenUtils.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenUtils.kBorderRadius),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtils.fontButton,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.5),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.editTextRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.editTextRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenUtils.editTextRadius),
          borderSide: const BorderSide(color: AppColors.accentTeal),
        ),
      ),
    );
  }
}
