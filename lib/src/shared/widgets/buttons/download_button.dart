import 'package:private_deals/src/shared/app_exports.dart';

class DownloadButton extends StatelessWidget {
  final void Function()? onTap;
  final double size;
  final Color? color;

  const DownloadButton({super.key, this.onTap, this.size = 26, this.color});

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 26,
        width: 26,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color ?? context.theme.primaryColor)),
        child: Center(
          child: FaIcon(FontAwesomeIcons.download,
              color: color ?? context.theme.primaryColor, size: 14),
        ),
      ),
    );
  }
}
