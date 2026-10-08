import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:private_deals/src/core/configuration/pref_config.dart';

/// Persists only the credentials needed to fetch a fresh server profile.
class SecureSessionStore {
  SecureSessionStore({
    FlutterSecureStorage? secureStorage,
    Future<dynamic> Function(String)? readPreference,
    Future<void> Function(String, dynamic)? writePreference,
    Future<void> Function(String)? removePreference,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _readPreference = readPreference ?? ((key) => prefs.getValue(key: key)),
       _writePreference = writePreference ?? _writeAndFlush,
       _removePreference = removePreference ?? _removeAndFlush;

  static const secureKey = 'private_deals.credentials.v1';
  static const legacyKey = 'private_deals.session.v1';
  // Older partner releases stored the entire profile under the user-type name.
  static const legacyKeys = [legacyKey, 'distributor'];
  static const signedOutKey = 'private_deals.session.signed_out';

  final FlutterSecureStorage _secureStorage;
  final Future<dynamic> Function(String) _readPreference;
  final Future<void> Function(String, dynamic) _writePreference;
  final Future<void> Function(String) _removePreference;

  static Future<void> _writeAndFlush(String key, dynamic value) async {
    await prefs.setValue(key: key, value: value);
    // GetStorage.write completes after scheduling its disk write. Wait for
    // that queue before relying on the sign-out marker across app restarts.
    await prefs.storage.queue.add(() async {});
  }

  static Future<void> _removeAndFlush(String key) async {
    if (await prefs.getValue(key: key) == null) return;
    await prefs.removeValue(key: key);
    await prefs.storage.queue.add(() async {});
  }

  Future<Map<String, dynamic>?> read() async {
    if (await _readPreference(signedOutKey) == true) {
      await clear();
      return null;
    }
    final encoded = await _secureStorage.read(key: secureKey);
    if (encoded != null) {
      Map<String, dynamic>? credentials;
      try {
        credentials = _credentials(jsonDecode(encoded));
      } on FormatException {
        // A malformed record must never restore an older plaintext session.
      }
      if (credentials == null) {
        await clear();
      } else {
        await _removeLegacy();
      }
      return credentials;
    }
    for (final key in legacyKeys) {
      final credentials = _credentials(await _readPreference(key));
      if (credentials == null) continue;
      // Do not remove the recoverable session until the secure write succeeds.
      await write(credentials);
      return credentials;
    }
    await _removeLegacy();
    return null;
  }

  Future<void> write(Map<String, dynamic> credentials) async {
    final value = _credentials(credentials);
    if (value == null) throw ArgumentError('Invalid session credentials');
    await _secureStorage.write(key: secureKey, value: jsonEncode(value));
    await _removeLegacy();
    await _removePreference(signedOutKey);
  }

  Future<void> clear() async {
    // This non-secret marker prevents restoring a logged-out session even if
    // the OS keychain is temporarily unavailable during deletion.
    await _writePreference(signedOutKey, true);
    await _removeLegacy();
    try {
      await _secureStorage.delete(key: secureKey);
    } catch (_) {
      // Keep the marker and retry deletion on the next read or sign-out.
    }
  }

  Future<void> _removeLegacy() async {
    for (final key in legacyKeys) {
      await _removePreference(key);
    }
  }

  static Map<String, dynamic>? _credentials(dynamic value) {
    if (value is! Map) return null;
    final id = int.tryParse('${value['id']}');
    final token = value['token'];
    if (id == null || id <= 0 || token is! String || token.trim().isEmpty) {
      return null;
    }
    return {'id': id, 'token': token};
  }
}
