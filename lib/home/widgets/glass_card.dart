import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../core/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double? width;
  final double? height;
  final Color baseColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 14,
    this.width,
    this.height,
    this.baseColor = AppColors.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor,
            border: Border.all(color: AppColors.strokeLight, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

@Preview(name: 'Glass Card Preview')
Widget glassCardPreview() {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: GlassCard(
        width: 200,
        height: 100,
        child: Center(
          child: Text('Glass Card', style: TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );
}
