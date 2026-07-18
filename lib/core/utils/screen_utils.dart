import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  // MARGIN
  static double get margin => 16.w;
  static double get fieldSpace => 8.h;
  static double get spacingStander => 16.h;
  static double get spacingControl => 12.h;
  static double get spacingStandardControl => 8.w;
  static double get buttonHeight => 60.h;
  static double get cardCircularRadius => 12.r;
  static double get panelHeightClosed => 72.h;

  // FONTS
  static double get fontTextTitle => 30.sp;
  static double get fontTextBig => 24.sp;
  static double get fontTextMBig => 20.sp;
  static double get fontText => 16.sp;
  static double get fontEditText => fontText;
  static double get fontButton => fontText;
  static double get fontTextSmall => 14.sp;
  static double get fontTextSmaller => 12.sp;
  static double get fontTextTiny => 10.sp;
  static double get fontMinimum => 8.sp;

  static double get textRadius => 50.r;
  static double get editTextRadius => 6.r;
  static double get keyboardRadius => 40.r;
  static double get keyboardIconHW => 80.w;

  // RADIUS
  static double get kBorderRadius => 14.0.r;
  static double get kImageBorderRadius => 12.0.r;
}

class AppColors {
  static const Color background = Color(0xFF0B0E17); // Deep navy-slate dark
  static const Color surface = Color(0xFF161B2A); // Frosted dark navy card
  static const Color accentTeal = Color(0xFF14B8A6); // Mint Teal
  static const Color accentPurple = Color(0xFF6366F1); // Indigo
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFF2E364F);

  static const Gradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient buttonGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

class AppColor {
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color accentTeal = AppColors.accentTeal;
  static const Color accentPurple = AppColors.accentPurple;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color border = AppColors.border;
}

class AppStyles {
  static TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextTitle,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textBig = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextBig,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textMBig = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextMBig,
    fontWeight: FontWeight.bold,
  );

  static TextStyle text = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontText,
  );

  static TextStyle editText = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontEditText,
  );

  static TextStyle button = TextStyle(
    color: AppColors.background,
    fontSize: ScreenUtils.fontButton,
    fontWeight: FontWeight.bold,
  );

  static TextStyle textSmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextSmall,
  );

  static TextStyle textSmaller = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextSmaller,
  );

  static TextStyle textTiny = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextTiny,
  );

  static TextStyle minimum = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontMinimum,
  );
}
