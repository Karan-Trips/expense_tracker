import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/constant/app_colors.dart';

class MarkdownReportViewer extends StatelessWidget {
  final String markdown;

  const MarkdownReportViewer({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyleSheet = MarkdownStyleSheet.fromTheme(theme);

    return MarkdownBody(
      data: markdown,
      styleSheet: baseStyleSheet.copyWith(
        h1: TextStyle(
          color: Colors.white,
          fontSize: ScreenUtils.fontTextMBig,
          fontWeight: FontWeight.w900,
          height: 1.6,
        ),
        h2: TextStyle(
          color: AppColors.accentTeal,
          fontSize: ScreenUtils.fontText,
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
        h3: TextStyle(
          color: AppColors.accentTeal,
          fontSize: ScreenUtils.fontTextSmall,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        p: TextStyle(
          color: AppColors.textSecondary,
          fontSize: ScreenUtils.fontTextSmall,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        listBullet: TextStyle(
          color: AppColors.accentTeal,
          fontSize: ScreenUtils.fontTextSmall,
        ),
        listBulletPadding: const EdgeInsets.only(right: 8.0, top: 2.0),
      ),
    );
  }
}
