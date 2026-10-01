import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'package:private_deals/src/shared/translation/translation_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';

final InitConfig init = InitConfig.instance;

class InitConfig extends GetxService {
  static final InitConfig instance = InitConfig();
  bool noInternet = false;

  // RxBool isDarkMode = false.obs;
  Rx<ThemeMode> themeModes = ThemeMode.dark.obs;

  Rx<int> color = 0.obs;

  Future<void> init(UserType type) async {
    await _initGetStorage();
    app.userType = type;
    await _setOrientation();
    if (!kIsWeb && PlatformHelper.isWindows) {
      await windowManager.ensureInitialized();
      WindowManager.instance.setMinimumSize(const Size(610, 700));
      DesktopNotification.addListener();
      // WindowManager.instance.setMaximumSize(const Size(1200, 600));
    }

    await ScreenUtil.ensureScreenSize();
    _getLanguage();
  }

  Future<void> initConfig() async {
    usePathUrlStrategy();
    await app.getUser();
    await app.getLoginCounts();
    await _getDeviceInfo();
    await _getPackageInfo();
    await networkCheck();
    await ConfigApi.config();
    getTheme();
  }

  String packageName = 'Not Available';
  String packageVersion = '0.0.0+0';
  int version = 0;
  int androidVersion = 0;

  String deviceId = 'Not Available';
  String deviceModel = 'Not Available';
  String deviceOs = 'Not Available';

  // Rx<ThemeMode> themeMode = AppTheme.getTheme.obs;

  Future<void> _initGetStorage() async {
    try {
      // logger.d('INITING GET STORAGE');
      await GetStorage.init();
      getTheme();
    } catch (e) {
      logger.e(e);
    }
  }

  static _setOrientation() async {
    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarIconBrightness: Brightness.light,
    //     systemNavigationBarColor: Colors.transparent,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //   ),
    // );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void forceUpdate() async {
    if (kIsWeb) return;
    logger.d(
      "Version :$version Config :${app.config.version.currentVersionCode} Condition :${app.config.version.currentVersionCode < version}\n API VERSION :${app.config.currentApiVersion}",
    );
    if (version < app.config.version.currentVersionCode) {
      logger.d("Force Update :${app.config.version.toJson()}");
      await showCustomDialog(ForceUpdateDialog(), false);
    }
  }

  Future<void> _getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    logger.d("Package Name :${packageInfo.packageName}");

    switch (packageInfo.packageName) {
      case "com.shuruup.investor":
        packageName = 'investor';
        break;
      case "com.shuruup.distributor":
      case "com.privatedeals.partner":
      case "Shuru-Up Partner":
      case "Private Deals":
        packageName = 'distributer';
        break;
      case "Shuru-Up":
        packageName = 'investor';
        break;
    }
    version = int.tryParse(packageInfo.buildNumber) ?? 1;
    packageVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
  }

  Future<void> networkCheck() async {
    // logger.i('check network');
    // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   logger.d('result :$result Internet :$noInternet');
    //   if (result == ConnectivityResult.none && noInternet == false) {
    //     noInternet = true;
    //     appPopUp(barrierDismissible: false, children: [
    //       const SizedBox(height: 10),
    //       const SpinKitPouringHourGlassRefined(color: Colors.white),
    //       const SizedBox(height: 20),
    //       Text(
    //         "Network Connection Lost..! \n Please Reconnect..",
    //         style: Get.context?.textTheme.labelMedium
    //             ?.copyWith(fontWeight: FontWeight.bold),
    //         textAlign: TextAlign.center,
    //       ),
    //       const SizedBox(height: 10),
    //     ]);
    //   } else {
    //     Get.back();
    //     logger.d("Get.back Called");
    //     noInternet = false;
    //   }
    // });
  }

  Future<void> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

      deviceModel = webBrowserInfo.userAgent ?? 'Unknown';
      deviceId = webBrowserInfo.vendor ?? 'web';
      deviceOs = 'web';
      androidVersion = 0;

      return;
    }

    switch (Platform.operatingSystem) {
      case 'android':
        final AndroidDeviceInfo info = await deviceInfo.androidInfo;

        deviceModel = info.model;
        deviceId = info.id;
        androidVersion = int.tryParse(info.version.release) ?? 0;
        deviceOs = 'android';
        break;

      case 'ios':
        final IosDeviceInfo info = await deviceInfo.iosInfo;

        deviceModel = info.utsname.machine;
        deviceId = info.identifierForVendor ?? '';
        deviceOs = 'ios';
        break;

      case 'windows':
        final WindowsDeviceInfo info = await deviceInfo.windowsInfo;

        deviceModel = info.computerName;
        deviceId = info.deviceId;
        deviceOs = 'desktop';
        break;

      case 'macos':
        final MacOsDeviceInfo info = await deviceInfo.macOsInfo;

        deviceModel = info.computerName;
        deviceId = info.systemGUID ?? '';
        deviceOs = 'macos';
        break;

      default:
        deviceModel = 'Unknown';
        deviceId = '';
        deviceOs = Platform.operatingSystem;
        break;
    }
  }

  // static _firebaseInit() async {
  //   try {
  //     await Firebase.initializeApp();
  //     logger.d('INITING FIREBASE');
  //   } catch (e) {
  //     logger.e(e);
  //   }
  // }

  // ABOUT TRANSLATION

  TranslationModel _translation = TranslationModel.fromJson({});

  TranslationModel get translation => _translation;

  set translation(TranslationModel translation) {
    _translation = translation;
    prefs.setValue(key: AppKey.languageKey, value: translation.languageCode);
  }

  void _getLanguage() {
    try {
      var languageCode = prefs.getValue(key: AppKey.languageKey);
      for (var locale in Translation.locales) {
        if (locale.languageCode == languageCode) {
          _translation = locale;
          break;
        }
      }
      if (_translation.isEmpty) translation = Translation.locales.first;

      // logger.f(
      //     '${translation.countryCode}-${translation.languageCode}  && ${translation.languageName}');
    } catch (e, t) {
      logger.e('Locale', error: e, stackTrace: t);
    }
  }

  Future<void> changeTheme() async {
    ThemeMode newTheme = ThemeMode.dark;
    switch (themeModes()) {
      case ThemeMode.system:
        newTheme = ThemeMode.dark;
        break;
      case ThemeMode.light:
        newTheme = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newTheme = ThemeMode.light;
        break;
    }
    await prefs.setValue(key: "theme", value: newTheme.index);
    themeModes(newTheme);
    themeModes.refresh();
    Get.changeThemeMode(newTheme);
  }

  Future<void> getTheme() async {
    var themes = await prefs.getValue(key: "theme") ?? 2;
    var c = await prefs.getValue(key: "color") ??
        AppColors.sectionPrivateEquity.toARGB32();
    ThemeMode themeMode = ThemeMode.values[themes];
    color(c);
    themeModes(themeMode);
    // return theme;
  }
}
