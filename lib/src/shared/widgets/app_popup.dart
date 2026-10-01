import 'dart:ui';

import 'package:private_deals/src/shared/app_exports.dart';

Future<dynamic> appPopUp(
    {required List<Widget> children,
    bool barrierDismissible = true,
    Color? dialogColor}) {
  return showDialog(
    context: Get.context!,
    barrierDismissible: barrierDismissible,
    builder: (context) => PopScope(
      onPopInvokedWithResult: (v, _) => barrierDismissible,
      child: CustomBackdropFilter(
        child: SimpleDialog(
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: dialogColor ?? Colors.grey.withOpacity(0.5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            )
          ],
        ),
      ),
    ),
  );
}

class CustomBackdropFilter extends StatelessWidget {
  final Widget? child;
  final double? sigmaX;
  final double? sigmaY;

  const CustomBackdropFilter(
      {super.key, required this.child, this.sigmaX, this.sigmaY});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX ?? 5, sigmaY: sigmaY ?? 5),
      child: child,
    );
  }
}
