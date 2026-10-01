import 'dart:io';

import 'package:private_deals/src/shared/models/deep_link_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/plugins/open_file.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void selectNotification(NotificationResponse response) async {
  logger.d("Notification Message Without Payload:${response.toString()}");
  if (response.payload != null && response.payload!.isNotEmpty) {
    logger.d("Notification Message :${response.payload}");
    // Handle the notification tap and deep link if needed
    File file = File(response.payload!);
    if (await file.exists()) {
      openFile(file.path);
    }
    final result = DeepLinkParser.parse(response.payload!);
    if (result != null) {
      app.deepLinkResult = result;
    }
  }
}

class NotificationServices {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// set icon path here
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  static const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  static const DarwinInitializationSettings initializationSettingsMacOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  static const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );

  static const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'notification_channel',
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    icon: '@mipmap/ic_launcher',
  );

  static const NotificationDetails platformChannelSpecifics =
      NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails());

  static Future<void> notificationRequest() async {
    if (kIsWeb) return;
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> initNotification() async {
    try {
      tz.initializeTimeZones();
      // toast('Local notification initialize');
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveBackgroundNotificationResponse: selectNotification,
        onDidReceiveNotificationResponse: selectNotification,
      );
      logger.d('NOTIFICATION INIT');
      // toast('Notification Req Called');
      await notificationRequest();
      // toast('Notification Request Complete');
      if (!kIsWeb && Platform.isIOS) {
        // toast('getNotificationAppLaunchDetails Called');
        NotificationAppLaunchDetails? details =
            await flutterLocalNotificationsPlugin
                .getNotificationAppLaunchDetails();
        if (details != null && details.notificationResponse != null) {
          // logger.d(
          //     "Notification Message :${details.notificationResponse?.payload}");
          selectNotification(details.notificationResponse!);
        }
        await flutterLocalNotificationsPlugin.cancelAll();
      }
      // toast('FirebaseMessaging.onMessage Called');
      if (!kIsWeb) {
        if (app.isUserLogin) {
          await _firebaseMessaging.unsubscribeFromTopic('guest_topic');
          await _firebaseMessaging.unsubscribeFromTopic('inactive_users');
        } else if (app.loginUserCount > 0) {
          await _firebaseMessaging.subscribeToTopic('inactive_users');
        } else {
          await _firebaseMessaging.subscribeToTopic('guest_topic');
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;

        if (notification != null) {
          logger.d("Show Notification Call :${message.data}");
          showNotification(
            id: notification.hashCode,
            title: notification.title ?? 'No Title',
            body: notification.body ?? 'No Body',
            // payload: message.data['payload'] ?? '',
            payload: message.data['route'] ?? '',
          );
        }
      });
      // toast('FirebaseMessaging.onMessageOpenedApp Called');

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        logger.d("Notification Details :${message.toMap()}");
        selectNotification(
          NotificationResponse(
            id: message.messageId.hashCode,
            payload: message.data['payload'],
            input: '',
            actionId: '',
            notificationResponseType:
                NotificationResponseType.selectedNotificationAction,
          ),
        );
      });
      // toast('Init Notification Function Completed');
    } catch (e, t) {
      // toast('FirebaseMessaging.onMessageOpenedApp Called');
      logger.e("Error On Init Notification Function :$e", stackTrace: t);
    }
  }

  static Future<String> getToken() async {
    try {
      if (kIsWeb) {
        return await getWebFCMToken();
      } else if (!PlatformHelper.isWindows) {
        var res = await _firebaseMessaging.getToken();
        return res ?? "N/A";
        // return await _firebaseMessaging.getToken();
      } else {
        return 'N/A';
      }
    } on Exception catch (e) {
      logger.d("Error Found on get FCM TOKEN :$e");
      return 'N/A';
    }
  }

  static Future<String> getWebFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Request notification permissions from the browser
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.d('User granted notification permission.');

      String? token = await messaging.getToken();

      if (token != null) {
        return token;
      }
    } else {
      logger.d('User declined or has not accepted permission.');
    }
    return 'N/A';
  }

  // static Future<void> updateTokens() async {
  //   if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
  //     String? fcmToken = await _firebaseMessaging.getToken();
  //     logger.d('FCM Token: $fcmToken');
  //
  //     // Get the device ID
  //     String deviceId = await DeviceInfoService.getDeviceId();
  //     // logger.d('Device ID: $deviceId');
  //   }
  // }

  static Future<void> removeNotification({required int id}) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  static Future<void> scheduleNotifications({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    try {
      var time = tz.TZDateTime.from(scheduledTime, tz.local);
      logger.d(
          "Notification ID $id \nTitle :$title \nBody :$body \nPayload :$payload");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: time,
        notificationDetails: platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, t) {
      logger.e('Notification Error :$e \n Trace :$t');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      logger.d(
          "Notification ID $id \nTitle :$title \nBody :$body \nPayload :$payload");
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics,
        payload: payload,
      );
    } catch (e, t) {
      logger.e('Error :$e \n Trace :$t');
    }
  }
}
