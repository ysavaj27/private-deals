import 'package:private_deals/src/shared/app_exports.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double radius;
  final double? elevation;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? child;
  final bool isLoginGradient;
  final bool noGradient;
  final Size? size;
  final Size? maximumSize;
  final BorderRadius? borderRadius;

  const CustomElevatedButton({
    super.key,
    this.text = "",
    required this.onPressed,
    this.backgroundColor,
    this.fontWeight,
    this.textColor,
    this.fontSize,
    this.width,
    this.elevation,
    this.height,
    this.style,
    this.color,
    this.isLoading = false,
    this.radius = 12.0,
    this.padding,
    this.child,
    this.isLoginGradient = true,
    this.noGradient = false,
    this.size,
    this.maximumSize,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading ? true : false,
      // isLoading ? null :
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          // maximumSize: Size(150, 50),
          enabledMouseCursor: SystemMouseCursors.click,
          elevation: elevation,
          // minimumSize:  const Size(150, 50),
          minimumSize: size ?? Size(width ?? double.infinity, height ?? 48),
          // maximumSize: maximumSize,
          // primary: backgroundColor ?? Theme.of(context).primaryColor,
          // onPrimary: textColor ?? Colors.white,
          backgroundColor: backgroundColor,
          foregroundColor: textColor ?? color,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(radius),
          ),
        ),
        child: isLoading
            ? Loader(
                color: textColor ?? color ?? Colors.white,
                // duration: Duration(seconds: 2),
                size: 25,
              )
            : child ??
                Text(
                  text,
                  style: style ??
                      TextStyle(
                        fontSize: fontSize ?? 14.0,
                        color: onPressed == null
                            ? context.theme.disabledColor
                            : color,
                        fontWeight: fontWeight ?? FontWeight.w600,
                      ),
                ),
      ),
    );
  }
}
