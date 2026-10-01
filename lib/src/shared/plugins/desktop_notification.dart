import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/plugins/open_file.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

class DesktopNotification {
  static final _winNotifyPlugin =
      WindowsNotification(applicationId: "Shuru up");

  static Future<void> showNotification(String path, String name) async {
    try {
      final byteData = await rootBundle.load(AppAssets.newLogo);
      var file = await DownloadFile.downloadFromByte(
          bytes: byteData.buffer.asUint8List(),
          fileName: 'logo',
          isTempPath: true);
      NotificationMessage message = NotificationMessage.fromPluginTemplate(
          "notification_1",
          "Download Successfully",
          "$name has been download.Tap to open the file",
          payload: {"file_path": path},
          image: file);

      _winNotifyPlugin.showNotificationPluginTemplate(message);
    } catch (e, t) {
      logger.e("ERROR FOUND IN DESKTOP NOTIFICATION");
      logger.e(e, stackTrace: t);
    }
  }

  static void addListener() async {
    _winNotifyPlugin.initNotificationCallBack(
      (NotificationCallBackDetails details) async {
        logger.d("Notification Data :${details.message.payload}");
        if (details.message.payload.isNotEmpty &&
            details.message.payload.containsKey("file_path")) {
          File file = File(details.message.payload["file_path"]);
          if (await file.exists()) {
            openFile(file.path);
          }
        }
      },
    );
  }
}
