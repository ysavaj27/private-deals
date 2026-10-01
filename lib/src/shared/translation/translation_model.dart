import 'dart:ui';

class TranslationModel {
  final String countryCode;
  final String languageCode;
  final String languageName;
  final Map<String, String> data;

  TranslationModel({
    required this.countryCode,
    required this.languageCode,
    required this.languageName,
    required this.data,
  });

  bool get isEmpty => languageCode.isEmpty;

  factory TranslationModel.fromJson(Map<String, String> data) =>
      TranslationModel(
        countryCode: data['countryCode'] ?? '',
        languageCode: data['languageCode'] ?? '',
        languageName: data['languageName'] ?? '',
        data: data,
      );

  Locale toLocale() => Locale(languageCode, countryCode);
}
