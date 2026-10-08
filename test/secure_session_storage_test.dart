import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/session/secure_session_store.dart';

import 'session_and_api_test.dart' show identity;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, dynamic> preferences;
  late Map<String, String> secure;
  late SecureSessionStore store;
  late AuthSession session;
  String? failingOperation;
  Completer<void>? writeStarted;
  Completer<void>? releaseWrite;

  setUp(() {
    preferences = {'theme': 2, 'login_count': 4};
    secure = {};
    failingOperation = null;
    writeStarted = null;
    releaseWrite = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == failingOperation) {
            throw PlatformException(code: 'storage_unavailable');
          }
          final key = call.arguments['key'] as String;
          switch (call.method) {
            case 'read':
              return secure[key];
            case 'write':
              writeStarted?.complete();
              if (releaseWrite != null) await releaseWrite!.future;
              secure[key] = call.arguments['value'] as String;
              return null;
            case 'delete':
              secure.remove(key);
              return null;
            default:
              throw UnsupportedError(call.method);
          }
        });
    store = SecureSessionStore(
      readPreference: (key) async => preferences[key],
      writePreference: (key, value) async {
        preferences[key] = value;
      },
      removePreference: (key) async {
        preferences.remove(key);
      },
    );
    session = AuthSession(sessionStore: store);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'Login persists credentials securely, keeping profiles in memory',
    () async {
      await session.setUser(prefUser: {...identity(), 'name': 'Example'});
      expect(session.isUserLogin, true);
      expect(session.wUser.name, 'Example');
      expect(jsonDecode(secure[SecureSessionStore.secureKey]!), {
        'id': 7,
        'token': 'test-token-7',
      });
      expect(preferences, {'theme': 2, 'login_count': 4});
      final restarted = AuthSession(sessionStore: store);
      await restarted.getUser();
      expect(restarted.token, 'test-token-7');
      expect(restarted.userId, 7);
      expect(restarted.role, PartnerRole.unknown);
      expect(restarted.isUserLogin, false);
      expect(
        AccessPolicy.check(restarted.access, AccessScope.account),
        AccessResult.retrySession,
      );
    },
  );

  for (final key in SecureSessionStore.legacyKeys) {
    test('Migrates $key without trusting stored permissions', () async {
      preferences[key] = identity();
      await session.getUser();
      expect(session.token, 'test-token-7');
      expect(session.isUserLogin, false);
      expect(session.role, PartnerRole.unknown);
      expect(session.wUser.isPrimaryAccess, false);
      expect(preferences, {'theme': 2, 'login_count': 4});
      expect(jsonDecode(secure[SecureSessionStore.secureKey]!), {
        'id': 7,
        'token': 'test-token-7',
      });
    });
  }

  test(
    'Secure credentials take precedence over leftover old sessions',
    () async {
      secure[SecureSessionStore.secureKey] = jsonEncode(
        identity('Institution', 8),
      );
      for (final key in SecureSessionStore.legacyKeys) {
        preferences[key] = identity();
      }
      await session.getUser();
      expect(session.userId, 8);
      expect(preferences, {'theme': 2, 'login_count': 4});
    },
  );

  test(
    'Failed migration preserves the old session and can be retried',
    () async {
      preferences[SecureSessionStore.legacyKey] = identity();
      failingOperation = 'write';
      await session.getUser();
      expect(session.token, isEmpty);
      expect(session.isUserLogin, false);
      expect(preferences[SecureSessionStore.legacyKey], identity());
      expect(
        AccessPolicy.check(session.access, AccessScope.account),
        AccessResult.retrySession,
      );
      failingOperation = null;
      await session.getUser();
      expect(session.token, 'test-token-7');
      expect(preferences.containsKey(SecureSessionStore.legacyKey), false);
    },
  );

  test(
    'Unavailable secure storage cannot silently fall back to plaintext',
    () async {
      preferences[SecureSessionStore.legacyKey] = identity();
      failingOperation = 'read';
      await session.getUser();
      expect(session.token, isEmpty);
      expect(session.sessionError(), isNotEmpty);
      expect(await session.restore(), false);
      expect(session.restoring(), false);
      expect(preferences[SecureSessionStore.legacyKey], identity());
    },
  );

  test(
    'Failed secure login write does not authenticate; later login works',
    () async {
      failingOperation = 'write';
      await expectLater(
        session.setUser(prefUser: identity()),
        throwsA(isA<PlatformException>()),
      );
      expect(session.isUserLogin, false);
      expect(session.token, isEmpty);
      expect(secure, isEmpty);
      failingOperation = null;
      await session.setUser(prefUser: identity());
      expect(session.isUserLogin, true);
    },
  );

  test(
    'Logout removes secure and legacy credentials, preserving preferences',
    () async {
      await session.setUser(prefUser: identity());
      for (final key in SecureSessionStore.legacyKeys) {
        preferences[key] = identity();
      }
      secure['unrelated-secret'] = 'keep';
      await session.clear();
      expect(session.token, isEmpty);
      expect(session.isUserLogin, false);
      expect(secure, {'unrelated-secret': 'keep'});
      expect(preferences, {
        'theme': 2,
        'login_count': 4,
        SecureSessionStore.signedOutKey: true,
      });
      await session.getUser();
      expect(session.token, isEmpty);
    },
  );

  test(
    'Failed deletion cannot restore a logged-out session after restart',
    () async {
      await session.setUser(prefUser: identity());
      failingOperation = 'delete';
      await session.clear();
      expect(secure, isNotEmpty);
      final restarted = AuthSession(sessionStore: store);
      await restarted.getUser();
      expect(restarted.token, isEmpty);
      failingOperation = null;
      await restarted.getUser();
      expect(secure, isEmpty);
      await restarted.setUser(prefUser: identity('Institution', 8));
      expect(preferences.containsKey(SecureSessionStore.signedOutKey), false);
      await restarted.getUser();
      expect(restarted.userId, 8);
    },
  );

  for (final encoded in [
    'broken json',
    '[]',
    '{"id":7}',
    '{"id":0,"token":"x"}',
  ]) {
    test(
      'Malformed secure record $encoded does not resurrect legacy credentials',
      () async {
        secure[SecureSessionStore.secureKey] = encoded;
        preferences[SecureSessionStore.legacyKey] = identity();
        await session.getUser();
        expect(session.token, isEmpty);
        expect(secure, isEmpty);
        expect(preferences.containsKey(SecureSessionStore.legacyKey), false);
      },
    );
  }

  test(
    'Logout during a pending secure write cannot resurrect the session',
    () async {
      writeStarted = Completer<void>();
      releaseWrite = Completer<void>();
      final login = session.setUser(prefUser: identity());
      await writeStarted!.future;
      final logout = session.clear();
      releaseWrite!.complete();
      await Future.wait([login, logout]);
      expect(session.token, isEmpty);
      expect(session.isUserLogin, false);
      expect(secure, isEmpty);
    },
  );

  test('Expiration clears credentials only for the current session', () async {
    await session.setUser(prefUser: identity());
    final staleRevision = session.revision;
    await session.setUser(prefUser: identity('Institution', 8));
    expect(await session.expire(staleRevision), false);
    expect(secure, isNotEmpty);
    expect(await session.expire(session.revision), true);
    expect(secure, isEmpty);
    expect(session.token, isEmpty);
  });
}
