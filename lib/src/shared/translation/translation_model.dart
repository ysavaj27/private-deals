import 'dart:ui';

import 'package:private_deals/src/shared/functions/parse.dart';

class TranslationModel {
  final String countryCode;
  final String languageCode;
  final Map<String, String> data;

  TranslationModel({
    required this.countryCode,
    required this.languageCode,
    required this.data,
  });

  bool get isEmpty => languageCode.isEmpty;

  factory TranslationModel.fromJson(Map<String, String> data) =>
      TranslationModel(
        countryCode: Parse.toStrings(data['countryCode']),
        languageCode: Parse.toStrings(data['languageCode']),
        data: data,
      );

  Locale toLocale() => Locale(languageCode, countryCode);
}
