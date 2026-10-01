import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double? height;
  final double? width;
  final bool isBorder;
  final bool isForeground;
  final BorderRadius? borderRadius;
  final Color? color;
  final Color? borderColor;
  final BoxConstraints? constraints;
  final double borderWidth;
  final BoxBorder? border;
  final AlignmentGeometry? alignment;

  const CustomCardWidget({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.radius = 16,
    this.height,
    this.width,
    this.isBorder = true,
    this.borderRadius,
    this.color,
    this.constraints,
    this.borderColor,
    this.borderWidth = 1.0,
    this.border,
    this.isForeground = false,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(radius);
    final effectiveBorder = isBorder
        ? border ??
              Border.all(
                color: borderColor ?? colors.outlineVariant,
                width: borderWidth,
              )
        : null;

    return Container(
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: effectiveRadius,
        border: isForeground ? null : effectiveBorder,
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 10),
            color: Colors.black.withAlpha(isDark ? 51 : 15),
          ),
        ],
      ),
      foregroundDecoration: isForeground
          ? BoxDecoration(
              borderRadius: effectiveRadius,
              border: effectiveBorder,
            )
          : null,
      child: child,
    );
  }
}
