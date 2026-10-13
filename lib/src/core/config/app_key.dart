import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/models/enums.dart';
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
  static const investorIOS =
      'https://apps.apple.com/us/app/shuru-up/id6736905561';
  static const wealthManagerIOS =
      'https://apps.apple.com/us/app/shuru-up-business/id6737124969';
  static const investorAndroid =
      'https://play.google.com/store/apps/details?id=com.shuruup.investor';
  static const wealthMangerAndroid =
      'https://play.google.com/store/apps/details?id=com.privatedeals.partner';

  static String get updateUrl {
    final isInvestor = app.userType == UserType.investor;

    final Map<TargetPlatform, List<String>> platformUrls = {
      TargetPlatform.iOS: [investorIOS, wealthManagerIOS],
      TargetPlatform.android: [investorAndroid, wealthMangerAndroid],
      TargetPlatform.macOS: [investorIOS, wealthManagerIOS],
    };

    final urls = platformUrls[defaultTargetPlatform] ?? [];

    return urls.isNotEmpty ? (isInvestor ? urls[0] : urls[1]) : '';
  }
}
