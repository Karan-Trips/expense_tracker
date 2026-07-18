import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constant/app_colors.dart';

class FrostedCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;

  const FrostedCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.08,
    this.borderRadius,
    this.padding,
    this.margin,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius ?? ScreenUtils.cardCircularRadius;
    final resolvedPadding = padding ?? EdgeInsets.all(ScreenUtils.margin);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(resolvedRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: resolvedPadding,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(opacity),
              borderRadius: BorderRadius.circular(resolvedRadius),
              border: Border.all(
                color: borderColor ?? AppColors.border.withOpacity(0.4),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
