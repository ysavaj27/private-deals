/// Live API smoke configuration via `--dart-define` (never commit credentials).
///
/// Contract tests always run with a FakeAdapter (default `flutter test`).
///
/// Live read-only GETs (optional):
/// ```sh
/// flutter test test/api_smoke_live_test.dart --dart-define=SMOKE_LIVE=true \
///   --dart-define=PRIVATE_DEALS_BASE_URL=https://your-staging-host/ \
///   --dart-define=SMOKE_WM_MOBILE=... \
///   --dart-define=SMOKE_WM_PASSWORD=... \
///   --dart-define=SMOKE_INSTITUTION_MOBILE=... \
///   --dart-define=SMOKE_INSTITUTION_PASSWORD=...
/// ```
///
/// Destructive POSTs stay off unless `SMOKE_ALLOW_WRITES=true`.
class SmokeConfig {
  SmokeConfig._();

  static const baseUrl = String.fromEnvironment(
    'PRIVATE_DEALS_BASE_URL',
    defaultValue: 'https://www.privatedeals.in/',
  );

  static const live = bool.fromEnvironment('SMOKE_LIVE', defaultValue: false);

  static const allowWrites = bool.fromEnvironment(
    'SMOKE_ALLOW_WRITES',
    defaultValue: false,
  );

  static const wmMobile = String.fromEnvironment(
    'SMOKE_WM_MOBILE',
    defaultValue: '',
  );
  static const wmPassword = String.fromEnvironment(
    'SMOKE_WM_PASSWORD',
    defaultValue: '',
  );

  static const institutionMobile = String.fromEnvironment(
    'SMOKE_INSTITUTION_MOBILE',
    defaultValue: '',
  );
  static const institutionPassword = String.fromEnvironment(
    'SMOKE_INSTITUTION_PASSWORD',
    defaultValue: '',
  );

  static bool get hasWmCredentials =>
      wmMobile.isNotEmpty && wmPassword.isNotEmpty;

  static bool get hasInstitutionCredentials =>
      institutionMobile.isNotEmpty && institutionPassword.isNotEmpty;

  static bool get canRunWmLive => live && hasWmCredentials;

  static bool get canRunInstitutionLive => live && hasInstitutionCredentials;

  /// Prefer staging hosts for live smoke; production default is contract-only.
  static bool get looksLikeStaging {
    final host = Uri.tryParse(baseUrl)?.host ?? '';
    if (host.isEmpty) return false;
    return host.contains('staging') ||
        host.contains('dev') ||
        host.contains('test') ||
        host.contains('localhost') ||
        host.contains('127.0.0.1');
  }

  static String describe() {
    final roles = <String>[
      if (hasWmCredentials) 'WM',
      if (hasInstitutionCredentials) 'Institution',
    ];
    return 'baseUrl=$baseUrl live=$live allowWrites=$allowWrites '
        'roles=${roles.isEmpty ? 'none' : roles.join('+')} '
        'stagingHint=${looksLikeStaging ? 'yes' : 'no'}';
  }
}
