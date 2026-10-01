import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/theme/partner_theme.dart';

/// One visual identity across every investment section.
class AppTheme {
  AppTheme._();
  static final AppTheme instance = AppTheme._();
  static const fonts = 'inter';
  static final lightTheme = LightTheme.theme;
  static final darkTheme = DarkTheme.theme;
  static final Rx<ThemeData> theme = darkTheme.obs;

  // Retain the entry point used by section navigation, without changing colors.
  static Future<void> setTheme({required int index}) async {
    await getTheme();
  }

  // Legacy saved darkTheme indices are intentionally ignored.
  static Future<void> getTheme() async {
    theme.value = darkTheme;
  }

  static List<BoxShadow> get boxShadow => [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4)),
      ];
  static Gradient get whiteGradient => const LinearGradient(
        colors: [Color(0xFFE4E9F1), Color(0xFFF7F9FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
