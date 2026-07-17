import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/router.dart';
import 'core/constant/app_colors.dart';

class AuraExpenseApp extends StatelessWidget {
  const AuraExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'AuraExpense',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: goRouter,
        );
      },
    );
  }
}
