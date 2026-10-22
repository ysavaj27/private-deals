import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/shared/widgets/buttons/custom_elevated_button.dart';

import 'session_and_api_test.dart' show identity;
import 'support/recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingAnalytics client;
  setUp(() async {
    client = RecordingAnalytics();
    await Analytics.init(
      client: client,
      routeTemplates: [
        '/',
        '/sign-in',
        '/wealth-manager/dashboard',
        '/wealth-manager/unlisted-shares/detail/:slug',
        '/wealth-manager/investors/kyc/:id',
        '/institution/dashboard',
        '/institution/companies/unlisted/:slug/promoters',
      ],
    );
    app.persist = false;
    await app.clear();
    await client.drain();
    client.events.clear();
  });
  tearDown(() async {
    await app.clear();
    await client.drain();
  });

  test(
    'event names obey Firebase length, first-character and prefix rules',
    () {
      expect(Analytics.sanitizeName('Log In'), 'log_in');
      expect(
        Analytics.sanitizeName('Update share price'),
        'update_share_price',
      );
      expect(Analytics.sanitizeName(List.filled(50, 'a').join()).length, 40);
      expect(Analytics.sanitizeName('  !!!  '), '');
      expect(Analytics.sanitizeName('123'), 'app_123');
      for (final prefix in ['firebase', 'google', 'ga']) {
        expect(
          Analytics.sanitizeName('${prefix}_event'),
          'app_${prefix}_event',
        );
      }
    },
  );

  test('screen names remove queries and dynamic identifiers in both flows', () {
    expect(
      Analytics.screenName(
        '/wealth-manager/dashboard?email=private@example.com',
      ),
      'wealth_manager_dashboard',
    );
    expect(
      Analytics.screenName(
        '/wealth-manager/unlisted-shares/detail/company-one',
      ),
      Analytics.screenName(
        '/wealth-manager/unlisted-shares/detail/company-two',
      ),
    );
    expect(
      Analytics.screenName('/wealth-manager/investors/kyc/secret-id'),
      'wealth_manager_investors_kyc_id',
    );
    expect(
      Analytics.screenName(
        '/institution/companies/unlisted/private-slug/promoters',
      ),
      'institution_companies_unlisted_slug_promoters',
    );
    expect(
      Analytics.screenName('/unregistered/private@example.com'),
      'unknown',
    );
    expect(
      Analytics.screenName('/wealth-manager/investors/kyc/%FF'),
      'unknown',
    );
    expect(Analytics.screenName(null), '');
  });

  test(
    'parameters are bounded and unsupported values are not stringified',
    () async {
      await Analytics.event(
        'safe_event',
        params: {
          'null': null,
          'yes': true,
          'no': false,
          'price': 42.5,
          'infinite': double.infinity,
          'nan': double.nan,
          'object': {'email': 'private@example.com'},
          '123': 'valid',
          'long': 'x' * 150,
          for (var i = 0; i < 30; i++) 'param_$i': i,
        },
      );
      final params = client.events.single.parameters;
      expect(params['yes'], 1);
      expect(params['no'], 0);
      expect(params['price'], 42.5);
      expect(params['app_123'], 'valid');
      expect((params['long'] as String).length, 100);
      expect(params.keys, isNot(contains('object')));
      expect(params.keys, isNot(contains('nan')));
      expect(params.keys, isNot(contains('infinite')));
      expect(params.length, 25);
    },
  );

  test('identity, login, logout and anonymous events stay ordered', () async {
    unawaited(Analytics.setUser(7, role: 'Institution'));
    unawaited(Analytics.login(role: 'Institution'));
    unawaited(Analytics.logout());
    unawaited(Analytics.clearUser());
    await Analytics.tap('login_submit');
    expect(client.events.map((e) => e.name), ['login', 'logout', 'ui_tap']);
    expect(client.events.map((e) => e.userId), ['7', '7', null]);
    expect(client.events.first.parameters['partner_role'], 'Institution');
    expect(client.properties['partner_role'], isNull);
  });

  test(
    'missing role and invalid IDs clear stale identity properties',
    () async {
      await Analytics.setUser(7, role: 'Institution');
      await Analytics.setUser(8);
      expect(client.properties['partner_role'], isNull);
      await Analytics.setUser(0, role: 'Institution');
      expect(client.userId, isNull);
      expect(client.properties['partner_role'], isNull);
    },
  );

  test(
    'session restoration and expiry synchronize analytics identity',
    () async {
      await app.setUser(prefUser: identity('Wealth Manager', 9));
      await client.drain();
      expect(client.userId, '9');
      expect(client.properties['partner_role'], 'Wealth Manager');
      expect(await app.expire(app.revision), true);
      await client.drain();
      expect(client.userId, isNull);
      expect(client.properties['partner_role'], isNull);
    },
  );

  test(
    'a delayed SDK does not delay authentication or business requests',
    () async {
      client.identityGate = Completer<void>();
      await app.setUser(prefUser: identity());
      final result = await Analytics.trackRequest(
        'deal_create',
        request: () async => BaseModel<int>(s: 1, r: 42),
      );
      expect(app.isUserLogin, true);
      expect(result.r, 42);
      expect(client.events, isEmpty);
      client.identityGate!.complete();
      await client.drain();
      expect(client.events.single.userId, '7');
    },
  );

  test('late responses are not attributed to another session', () async {
    await Analytics.setUser(7, role: 'Institution');
    final response = Completer<BaseModel<int>>();
    final request = Analytics.trackRequest(
      'deal_create',
      request: () => response.future,
    );
    await Analytics.setUser(8, role: 'Wealth Manager');
    response.complete(BaseModel(s: 1, r: 1));
    expect((await request).isSuccess, true);
    await client.drain();
    expect(client.events, isEmpty);
  });

  test('SDK errors do not change a successful business result', () async {
    client.failEvents = true;
    final result = await Analytics.trackRequest(
      'deal_create',
      request: () async => BaseModel<int>(s: 1, r: 42),
    );
    await Analytics.event('finish');
    expect(result.r, 42);
    client.failEvents = false;
  });

  test('unavailable Firebase does not break navigation', () async {
    client.failInit = true;
    await Analytics.init(client: client);
    Analytics.observer.didPush(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/institution/dashboard'),
        builder: (_) => const SizedBox(),
      ),
      null,
    );
    await Analytics.event('deal_create');
    expect(client.events, isEmpty);
  });

  testWidgets('push and pop each log once; opening a dialog adds no visit', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        navigatorObservers: [Analytics.observer],
        initialRoute: '/',
        routes: {
          '/': (_) => const Scaffold(body: Text('Root')),
          '/institution/dashboard': (_) =>
              const Scaffold(body: Text('Dashboard')),
        },
      ),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.pushNamed('/institution/dashboard');
    await tester.pumpAndSettle();
    showDialog<void>(
      context: navigator.currentContext!,
      builder: (_) => const AlertDialog(),
    );
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.runAsync(client.drain);
    expect(client.events.map((e) => e.parameters['screen_name']), [
      'root',
      'institution_dashboard',
      'root',
    ]);
  });

  testWidgets('button labels are not sent and loading buttons cannot submit', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomElevatedButton(
            text: 'Private Investor Name',
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.runAsync(client.drain);
    expect(presses, 1);
    expect(client.events.single.parameters['name'], 'button_press');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomElevatedButton(
            text: 'Private Investor Name',
            isLoading: true,
            onPressed: () => presses++,
          ),
        ),
      ),
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    expect(client.events.length, 1);
  });
}
