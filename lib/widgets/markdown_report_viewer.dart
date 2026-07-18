import 'package:flutter/material.dart';
import '../core/constant/app_colors.dart';

class MarkdownReportViewer extends StatelessWidget {
  final String markdown;

  const MarkdownReportViewer({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final lines = markdown.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      // Check for headings
      if (line.startsWith('#')) {
        int level = 0;
        while (level < line.length && line[level] == '#') {
          level++;
        }
        final text = line.substring(level).trim();
        widgets.add(_buildHeading(text, level));
      }
      // Check for bullet lists
      else if (line.startsWith('*') || line.startsWith('-')) {
        final text = line.substring(1).trim();
        widgets.add(_buildListItem(text));
      }
      // Otherwise, standard paragraph
      else {
        widgets.add(_buildParagraph(line));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildHeading(String text, int level) {
    double fontSize = 15.0;
    FontWeight fontWeight = FontWeight.bold;
    EdgeInsets padding = const EdgeInsets.only(top: 24.0, bottom: 10.0);
    Color textColor = Colors.white;

    if (level == 1) {
      fontSize = 20.0;
      fontWeight = FontWeight.w900;
    } else if (level == 2) {
      fontSize = 17.0;
      fontWeight = FontWeight.w800;
      textColor = AppColors.accentTeal;
    } else if (level == 3) {
      fontSize = 15.0;
      fontWeight = FontWeight.bold;
      textColor = AppColors.accentTeal;
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: fontSize + 2,
            margin: const EdgeInsets.only(right: 10.0),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7.0, right: 10.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.accentTeal,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: _parseInlineFormatting(text),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.0,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          children: _parseInlineFormatting(text),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.0,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  List<TextSpan> _parseInlineFormatting(String text) {
    final List<TextSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
      ));
    }

    return spans;
  }
}
