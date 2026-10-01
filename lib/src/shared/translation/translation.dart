import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/translation/translation_english.dart';
import 'package:private_deals/src/shared/translation/translation_german.dart';
import 'package:private_deals/src/shared/translation/translation_model.dart';

class Translation extends Translations {
  static final locales = [
    TranslationModel.fromJson(English.data),
    TranslationModel.fromJson(Germany.data),
  ];

  static void onChanged(TranslationModel? translation) {
    if (translation == null) return;
    Get.updateLocale(translation.toLocale());
    init.translation = translation;
  }

  @override
  Map<String, Map<String, String>> get keys {
    return {for (var locale in locales) locale.languageCode: locale.data};
  }
}
