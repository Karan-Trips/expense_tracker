import 'package:flutter/material.dart';
import 'core/router/router.dart';
import 'core/constant/app_colors.dart';

class AuraExpenseApp extends StatelessWidget {
  const AuraExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AuraExpense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
