import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/constant/app_colors.dart';

class MarkdownReportViewer extends StatelessWidget {
  final String markdown;

  const MarkdownReportViewer({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdown,
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
          height: 1.6,
        ),
        h2: const TextStyle(
          color: AppColors.accentTeal,
          fontSize: 17.0,
          fontWeight: FontWeight.w800,
          height: 1.5,
        ),
        h3: const TextStyle(
          color: AppColors.accentTeal,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
        p: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14.0,
          height: 1.5,
        ),
        strong: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        listBullet: const TextStyle(
          color: AppColors.accentTeal,
          fontSize: 14.0,
        ),
        listBulletPadding: const EdgeInsets.only(right: 8.0, top: 2.0),
      ),
    );
  }
}
