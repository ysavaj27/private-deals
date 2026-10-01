import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/app/routing/pages.dart';
import 'session_and_api_test.dart' show FakeAdapter, response, identity;

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity());
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (options) async => response({
        'status': 1,
        'data': options.path.endsWith('seller/dashboard')
            ? {
                'access': {
                  'is_preipo_access': true,
                  'is_secondary_access': true,
                },
                'summary': {},
                'recent': {},
                'charts': {},
              }
            : [],
      }),
    );
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });
  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    for (final path in [
      '/institution/dashboard',
      '/institution/sell-enquiries',
      '/institution/unlisted-transactions',
      '/institution/secondary-transactions',
      '/institution/bulk-deals',
      '/institution/profile',
      '/institution/companies/secondary',
      '/institution/deals/unlisted',
      '/investors',
    ]) {
      testWidgets(
        'Merged page $path at ${size.width} has no rendering errors',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            GetMaterialApp(initialRoute: path, getPages: Pages.pages),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(Scaffold), findsWidgets);
          expect(Get.currentRoute, path);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
  testWidgets(
    'Refreshing a quotation checkout asks for an offer instead of using an empty model',
    (tester) async {
      await app.setUser(prefUser: identity('Wealth Manager'));
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute:
              '/wealth-manager/unlisted-shares/detail/test-company/investment',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('View company offers'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
