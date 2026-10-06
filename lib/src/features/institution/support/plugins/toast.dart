import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/support/constant/app_colors.dart';

void toast(
  String message, [
  MessageEnum type = MessageEnum.alert,
  Duration? duration,
]) {
  if (message.isEmpty || Get.testMode) return;

  Color backgroundColor() {
    switch (type) {
      case MessageEnum.info:
        return AppColors.primary;
      case MessageEnum.success:
        return Colors.green.shade800;
      case MessageEnum.error:
        return Colors.red.shade800;
      case MessageEnum.alert:
        return Colors.orange.shade800;
    }
  }

  Get.showSnackbar(
    GetSnackBar(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      duration: duration ?? const Duration(milliseconds: 2000),
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      maxWidth: 650,
      borderRadius: 10,
      margin: const EdgeInsets.only(top: 15),
      animationDuration: const Duration(milliseconds: 600),
      dismissDirection: DismissDirection.endToStart,
      // forwardAnimationCurve: Curves.easeInOut,
      // reverseAnimationCurve: Curves.easeOut,
      // message: message,
      // title: ,
      // titleText: Text(
      //   isSuccess ? "Success" : "Failed",
      //   style: const TextStyle(
      //       fontWeight: FontWeight.w600, fontSize: 17, color: Colors.black),
      // ),
      messageText: Text(
        message,
        style: TextStyle(
          color: Get.theme.scaffoldBackgroundColor,
          fontSize: 14,
        ),
      ),
      backgroundColor: backgroundColor(),
    ),
  );
}
