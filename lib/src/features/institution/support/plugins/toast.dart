import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/shared/widgets/app_toast.dart';

void toast(
  String message, [
  MessageEnum type = MessageEnum.alert,
  Duration? duration,
]) {
  if (Get.testMode) return;

  showAppToast(
    message,
    type: switch (type) {
      MessageEnum.info => AppToastType.info,
      MessageEnum.success => AppToastType.success,
      MessageEnum.error => AppToastType.error,
      MessageEnum.alert => AppToastType.alert,
    },
    duration: duration,
  );
}
