import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<Object?> showCustomDialog(
  Widget widget, [
  barrierDismissible = true,
]) async {
  final context = Get.context;
  if (context == null) return null;

  return showDialog<Object?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.85,
          ),
          child: Material(color: Colors.transparent, child: widget),
        ),
      );
    },
  );
}
