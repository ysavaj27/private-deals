import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/app/routing/routes.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/option/phone_option_view.dart';
import 'package:private_deals/src/shared/plugins/otp_text_field.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';

void main() {
  test('catalog list and news follow the section in the path', () {
    expect(
      SessionNavigation.scopeFor(
        '/wealth-manager/lp-secondary/company-list/search',
      ),
      AccessScope.secondary,
    );
    expect(
      SessionNavigation.scopeFor('/wealth-manager/lp-secondary/news-list'),
      AccessScope.secondary,
    );
    expect(
      SessionNavigation.scopeFor(
        '/wealth-manager/unlisted-shares/company-list/hot-deals',
      ),
      AccessScope.unlisted,
    );
    expect(
      SessionNavigation.scopeFor('/wealth-manager/unlisted-shares/news-list'),
      AccessScope.unlisted,
    );
  });

  test('iPhone Duo sizes stay on the compact layout', () {
    expect(AppWindow.compactWidth(466), isTrue);
    expect(AppWindow.compactWidth(669), isTrue);
    expect(AppWindow.compactWidth(951), isTrue);
    expect(AppWindow.compactWidth(1280), isFalse);
  });

  test('primary detail links use the startup slug', () {
    expect(
      Routes.primaryDetailPath('/wealth-manager/private-equity', 'acme'),
      '/wealth-manager/private-equity/detail/acme',
    );
    expect(
      Routes.primaryDetailPath(
        '/wealth-manager/private-equity',
        'acme',
      ).contains(':slug'),
      isFalse,
    );
  });

  testWidgets('OTP pins fit the forgot-password card on a 360 phone', (
    tester,
  ) async {
    final overflows = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed')) overflows.add(message);
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: SizedBox(width: 278, child: OtpTextField())),
        ),
      ),
    );
    await tester.pump();

    expect(overflows, isEmpty);
    expect(find.byType(OtpTextField), findsOneWidget);
  });

  testWidgets('journey card fills a 360 phone without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final overflows = <String>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('overflowed')) overflows.add(message);
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardWidget(
            title: 'LP Secondary',
            subTitle:
                'Buy/Sell to your interests to enhance liquidity in your portfolios or to take advantage of emerging opportunities',
            color: const Color(0xFF2B5996),
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(overflows, isEmpty);
    expect(find.text('Enter'), findsOneWidget);
  });
}
