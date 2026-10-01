import 'package:private_deals/src/shared/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Container(
      margin: margin,
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      foregroundDecoration: isForeground
          ? BoxDecoration(
              border: isBorder
                  ? border ??
                      Border.all(
                        width: borderWidth,
                        color: borderColor != null
                            ? borderColor!
                            : AppColors.borderColor(context),
                      )
                  : null,
              /* border: isGradient && isBorder
            ? GradientBoxBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDarkMode
                      ? [Color(0xff2d2d2d), Color(0xff1B1B1B)]
                      : [Color(0xffFFFFFF), Color(0xffE3E3E3)],
                ),
              )
            : null,
        gradient: isGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: context.isDarkMode
                    ? [Color(0xff101010), Color(0xff262525)]
                    : [Color(0xffFFFFFF), Color(0xffE3E3E3)],
              )
            : null,*/
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
            )
          : null,
      decoration: isForeground
          ? null
          : BoxDecoration(
              color: color ?? context.theme.colorScheme.surface,
              border: isBorder
                  ? border ??
                      Border.all(
                        width: borderWidth,
                        color: borderColor != null
                            ? borderColor!
                            : AppColors.borderColor(context),
                      )
                  : null,
              /* border: isGradient && isBorder
            ? GradientBoxBorder(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDarkMode
                      ? [Color(0xff2d2d2d), Color(0xff1B1B1B)]
                      : [Color(0xffFFFFFF), Color(0xffE3E3E3)],
                ),
              )
            : null,
        gradient: isGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: context.isDarkMode
                    ? [Color(0xff101010), Color(0xff262525)]
                    : [Color(0xffFFFFFF), Color(0xffE3E3E3)],
              )
            : null,*/
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
            ),
      padding: padding,
      child: child,
    );
  }
}
