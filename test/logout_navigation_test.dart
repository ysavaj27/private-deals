import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _PageController extends GetxController {}

class _SessionPage extends StatelessWidget {
  _SessionPage() {
    Get.put(_PageController());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Obx(() {
      final user = app.wUser;
      // Like the sidebar, a session rebuild constructs children which find
      // their route's controller, including during the exit transition.
      Get.find<_PageController>();
      return Text('User ${user.id}');
    }),
  );
}

void main() {
  setUp(() async {
    app.persist = false;
    await app.setUser(prefUser: identity());
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  for (final scenario in ['logout', 'failed logout', 'session expiry']) {
    testWidgets('$scenario retains controllers until route disposal', (
      tester,
    ) async {
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => scenario == 'session expiry'
            ? response({'message': 'Expired'}, 401)
            : scenario == 'failed logout'
            ? response({'message': 'Unavailable'}, 500)
            : response({'status': 1}),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const SizedBox()),
            GetPage(name: '/private', page: () => _SessionPage()),
            GetPage(
              name: '/sign-in',
              page: () => const Scaffold(body: Text('Sign in')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed('/private');
      await tester.pumpAndSettle();
      expect(Get.isRegistered<_PageController>(), isTrue);

      await tester.runAsync(() async {
        if (scenario == 'session expiry') {
          await expectLater(
            dioConfig.get('v2/business/institution/company/list', {}),
            throwsException,
          );
        } else {
          await SessionNavigation.logout();
        }
      });
      await tester.pumpAndSettle();

      // Navigation began in runAsync; drain its route-disposal callbacks too.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sign in'), findsOneWidget);
      expect(app.token, isEmpty);
      expect(Get.isRegistered<_PageController>(), isFalse);
    });
  }
}
