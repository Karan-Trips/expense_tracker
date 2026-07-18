import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtils {
  // MARGIN
  static const double margin = 16;
  static const double fieldSpace = 8;
  static const double spacingStander = 16;
  static const double spacingControl = 12;
  static const double spacingStandardControl = 8;
  static const double buttonHeight = 60;
  static const double cardCircularRadius = 12;
  static const double panelHeightClosed = 72;

  // FONTS
  static const double fontTextTitle = 30;
  static const double fontTextBig = 24;
  static const double fontTextMBig = 20;
  static const double fontText = 16;
  static const double fontEditText = fontText;
  static const double fontButton = fontText;
  static const double fontTextSmall = 14;
  static const double fontTextSmaller = 12;
  static const double fontTextTiny = 10;
  static const double fontMinimum = 8;

  static const double textRadius = 50;
  static const double editTextRadius = 6;
  static const double keyboardRadius = 40;
  static const double keyboardIconHW = 80;

  // RADIUS
  static const double kBorderRadius = 14.0;
  static const double kImageBorderRadius = 12.0;
}

class AppColors {
  static const Color background = Color(0xFF0B0E17); // Deep navy-slate dark
  static const Color surface = Color(0xFF161B2A);    // Frosted dark navy card
  static const Color accentTeal = Color(0xFF14B8A6);  // Mint Teal
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
  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextTitle,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textBig = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextBig,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textMBig = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontTextMBig,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle text = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontText,
  );

  static const TextStyle editText = TextStyle(
    color: AppColors.textPrimary,
    fontSize: ScreenUtils.fontEditText,
  );

  static const TextStyle button = TextStyle(
    color: AppColors.background,
    fontSize: ScreenUtils.fontButton,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textSmall = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextSmall,
  );

  static const TextStyle textSmaller = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextSmaller,
  );

  static const TextStyle textTiny = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontTextTiny,
  );

  static const TextStyle minimum = TextStyle(
    color: AppColors.textSecondary,
    fontSize: ScreenUtils.fontMinimum,
  );
}

// Thin (100)
final TextStyle textThinInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w100,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Extra Light (200)
final TextStyle textExtraLightInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w200,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Light (300)
final TextStyle textLightInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w300,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Regular (400)
final TextStyle textRegularInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w400,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Medium (500)
final TextStyle textMediumInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w500,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Semi Bold (600)
final TextStyle textSemiBoldInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w600,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Bold (700)
final TextStyle textBoldInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w700,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Extra Bold (800)
final TextStyle textExtraBoldInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w800,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);

// Black (900)
final TextStyle textBlackInter = TextStyle(
  decoration: TextDecoration.none,
  fontWeight: FontWeight.w900,
  fontSize: 16.spMin,
  overflow: TextOverflow.ellipsis,
  color: AppColor.textPrimary,
  fontFamily: 'SF-Compact-Text',
);
