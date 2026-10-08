import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:private_deals/firebase_options.dart';
import 'package:private_deals/src/app/routing/session_pages.dart';
import 'package:private_deals/src/shared/app_exports.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init.init(UserType.distributor);
  await init.initConfig();
  await app.restore();
  await AppTheme.getTheme();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    logger.d(e);
  }
  if (!PlatformHelper.isWindows && !kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Private Deals',
        enableLog: true,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.theme(),
        themeMode: init.themeModes(),
        fallbackLocale: init.translation.toLocale(),
        translations: Translation(),
        locale: init.translation.toLocale(),
        initialRoute: Routes.init,
        getPages: Pages.pages,
        unknownRoute: GetPage(
          name: '/not-found',
          page: () => const NotFoundPage(),
        ),
      );
    });
  }
}
