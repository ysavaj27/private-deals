import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';

void onBackLogic(BuildContext context, bool didPop) {
  if (didPop) return;

  if (Navigator.canPop(context)) {
    Get.back();
    return;
  }

  final parent = RouteHierarchy.resolveParent(Get.currentRoute);
  // logger.d('BACK PAGE :$parent');
  Get.offAndToNamed(parent, arguments: null);
}

void onBackPressed() {
  // logger.d('BACK PRESS CALLED');
  if (Navigator.of(Get.context!).canPop() || Get.previousRoute.isNotEmpty) {
    // logger.d("Get.previousRoute : ${Get.previousRoute}");
    Get.back();
    return;
  }

  // logger.d("Get.currentRoute : ${Get.previousRoute}");
  final parent = RouteHierarchy.resolveParent(Get.currentRoute);
  Get.offAndToNamed(parent, arguments: null);
}
