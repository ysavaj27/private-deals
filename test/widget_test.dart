import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/app/routing/middleware/auth_middleware.dart';
import 'package:private_deals/src/app/routing/pages.dart';

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });
  test(
    'Every registered business page has a guard; developer route is absent',
    () {
      const public = {
        '/',
        '/init',
        '/sign-in',
        '/sign-in/inquiry',
        '/sign-in/forgot-password',
        '/session',
        '/access-denied',
        '/not-found',
      };
      for (final page in Pages.pages) {
        if (!public.contains(page.name))
          expect(
            page.middlewares?.whereType<AuthMiddleware>(),
            isNotEmpty,
            reason: page.name,
          );
      }
      expect(Pages.pages.any((p) => p.name == '/TestPage'), false);
      expect(Pages.pages.map((p) => p.name).toSet().length, Pages.pages.length);
    },
  );
  for (final role in ['Wealth Manager', 'Institution']) {
    testWidgets('$role cannot construct the other dashboard', (tester) async {
      await app.setUser(prefUser: {'id': 1, 'token': 'test', 'type': role});
      var built = 0;
      final other = role == 'Institution'
          ? '/wealth-manager/dashboard'
          : '/institution/dashboard';
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: other,
          getPages: [
            GetPage(name: '/', page: () => const SizedBox()),
            GetPage(
              name: other,
              page: () {
                built++;
                return const Scaffold(body: Text('Private data'));
              },
              middlewares: [
                AuthMiddleware(
                  scope: role == 'Institution'
                      ? AccessScope.business
                      : AccessScope.institution,
                ),
              ],
            ),
            GetPage(
              name: '/access-denied',
              page: () => const Scaffold(body: Text('Access denied')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(built, 0);
      expect(find.text('Private data'), findsNothing);
      expect(find.text('Access denied'), findsOneWidget);
    });
  }
  testWidgets('Restoring a stored token never constructs private content', (
    tester,
  ) async {
    await app.setUser(
      prefUser: {'id': 1, 'token': 'test', 'type': 'Institution'},
    );
    app.validated(false);
    var built = 0;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/institution/dashboard',
        getPages: [
          GetPage(name: '/', page: () => const SizedBox()),
          GetPage(
            name: '/institution/dashboard',
            page: () {
              built++;
              return const Text('Private');
            },
            middlewares: [AuthMiddleware()],
          ),
          GetPage(
            name: '/session',
            page: () => const Scaffold(body: Text('Retry session')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(built, 0);
    expect(find.text('Retry session'), findsOneWidget);
  });
}
