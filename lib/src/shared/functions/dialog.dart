import 'package:private_deals/src/shared/app_exports.dart';

Future<Object?> showCustomDialog(Widget widget,
    [barrierDismissible = true]) async {
  return await showGeneralDialog(
    context: Get.context!,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: widget,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    },
  );
}
