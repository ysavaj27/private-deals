import 'package:private_deals/src/shared/app_exports.dart';

class CustomOutlinedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? width;
  final double? borderRadius;
  final double? height;
  final Size? size;
  final Widget? child;
  /// Label / foreground color. Also used for the border when [borderColor] is null.
  final Color? color;
  /// Optional border override. Prefer this when the border should differ from the label.
  final Color? borderColor;
  final bool isLoading;

  const CustomOutlinedButton({
    super.key,
    required this.onPressed,
    this.text = '',
    this.width,
    this.borderRadius,
    this.height,
    this.size,
    this.color,
    this.borderColor,
    this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final bool disabled = onPressed == null || isLoading;

    final Color resolvedBorder = disabled
        ? scheme.outlineVariant
        : borderColor ?? color ?? scheme.outline;

    final Color resolvedForeground = disabled
        ? context.theme.disabledColor
        : color ?? scheme.onSurface;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: size ?? Size(width ?? double.infinity, height ?? 48),
        foregroundColor: resolvedForeground,
        side: BorderSide(width: 1, color: resolvedBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        ),
      ),
      child: isLoading
          ? Loader(
              color: scheme.primary,
              size: 25,
            )
          : child ??
              Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                  color: resolvedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
    );
  }
}
