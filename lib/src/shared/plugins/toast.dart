import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/widgets/app_toast.dart';

void toast(
  String message, [
  MessageEnum type = MessageEnum.alert,
  Duration? duration,
]) {
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
