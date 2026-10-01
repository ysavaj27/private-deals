import 'package:private_deals/src/shared/app_exports.dart';
import 'package:dotted_border/dotted_border.dart';

class CustomDottedBorder extends StatelessWidget {
  final double radius;
  final double padding;
  final Widget child;
  final Color? color;
  final List<double>? dashPattern;

  const CustomDottedBorder({
    super.key,
    this.radius = 12,
    this.padding = 6,
    required this.child,
    this.dashPattern,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        // borderType: BorderType.RRect,
        color: color ?? context.theme.dividerColor,
        dashPattern: dashPattern ?? [4, 4],
        // strokeWidth: 0.5,
        // color: context.theme.disabledColor,
        radius: Radius.circular(radius),
        padding: EdgeInsets.all(padding),
      ),
      child: child,
    );
  }
}
