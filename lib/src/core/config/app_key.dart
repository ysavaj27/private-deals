
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class AppKey {
  /// PREF KEYS
  static const userKey = 'user';
  static const themeKey = 'theme-mode';
  static const languageKey = 'language-co0de';
  static const core = 'core';
  static const appKeys = 'headtoken';
  static const appKeyValue =
      'FBvBeiP253uCFK0VEUO6RWQhXlXp4PmeK1ZY1NbzhahertMCcgjoCMfpmWpe';

  //APP LINKS
  // static const rateUsAndroid =
  //     'https://play.google.com/store/apps/details?id=(bundle_name)';
  // static const rateUsIOS = 'https://apps.apple.com/us/app/(app_name)/(app_id)';

  static const investorIOS =
      'https://apps.apple.com/us/app/shuru-up/id6736905561';
  static const wealthManagerIOS =
      'https://apps.apple.com/us/app/shuru-up-business/id6737124969';
  static const investorAndroid =
      'https://play.google.com/store/apps/details?id=com.shuruup.investor';
  static const wealthMangerAndroid =
      'https://play.google.com/store/apps/details?id=com.privatedeals.partner';
  static String wealthMangerEXE =
      app.config.s3Baseurl + app.config.build.windows.distributer;
  static String investorEXE =
      app.config.s3Baseurl + app.config.build.windows.investor;

  static String get updateUrl {
    final isInvestor = app.userType == UserType.investor;

    final Map<TargetPlatform, List<String>> platformUrls = {
      TargetPlatform.iOS: [investorIOS, wealthManagerIOS],
      TargetPlatform.android: [investorAndroid, wealthMangerAndroid],
      TargetPlatform.macOS: [investorIOS, wealthManagerIOS],
      TargetPlatform.windows: [investorEXE, wealthMangerEXE],
    };

    final urls = platformUrls[defaultTargetPlatform] ?? [];

    return urls.isNotEmpty ? (isInvestor ? urls[0] : urls[1]) : '';
  }
}
