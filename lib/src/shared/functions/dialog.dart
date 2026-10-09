import 'package:private_deals/src/shared/app_exports.dart';

Future<Object?> showCustomDialog(
  Widget widget, [
  barrierDismissible = true,
]) async {
  final context = Get.context!;
  final duration = AppMotion.duration(context, AppMotion.dialog);

  return await showGeneralDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: duration,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return AlertDialog(
        insetPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
        backgroundColor: Colors.transparent,
        elevation: 0,
        contentPadding: EdgeInsets.zero,
        content: widget,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.easeOut,
        reverseCurve: AppMotion.easeInOut,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: AppMotion.dialogScaleBegin,
            end: 1,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
