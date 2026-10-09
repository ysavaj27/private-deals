import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page_ctrl.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/shared/models/config_model.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity());
    app.configModel(
      ConfigModel.fromJson({
        'settlement_days': [
          {'value': 1, 'label': 'T+1'},
          {'value': 2, 'label': 'T+2'},
        ],
      }),
    );
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [
          {'id': 42, 'brand_name': 'Sample company', 'uuid': 'sample'},
        ],
      }),
    );
  });
  tearDown(() async {
    Get.reset();
    await app.clear();
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  for (final type in ['unlisted', 'secondary']) {
    for (final hot in [false, true]) {
      for (final width in [390.0, 1280.0]) {
        testWidgets(
          '$type sell settlement is visible, validated and submitted (hot=$hot, width=$width)',
          (tester) async {
            tester.view.physicalSize = Size(width, 1000);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final route =
                '/institution/deals/${hot ? 'hot' : 'manage'}/$type/create';
            await tester.pumpWidget(
              GetMaterialApp(
                initialRoute: route,
                getPages: [GetPage(name: route, page: () => CreateDealPage())],
              ),
            );
            await tester.pumpAndSettle();
            final c = Get.find<CreateDealPageCtrl>();
            c.selectedCompany(
              LiteCompanyModel(id: 42, brandName: 'Sample company'),
            );
            c.availableQuantityCtrl.text = '100';
            c.minimumQuantityCtrl.text = '10';
            c.sharePriceCtrl.text = '250';
            expect(find.byType(SettlementDaysDropdown), findsOneWidget);
            expect(c.requiresSettlement, true);
            expect(c.validateSettlement(), false);
            c.settlementDays(99);
            expect(c.validateSettlement(), false);
            c.settlementDays(2);
            expect(c.validateSettlement(), true);
            expect(c.buildPayload()['settlement_days'], 2);
            expect(c.buildPayload()['is_hot_deal'], hot ? 1 : 0);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(DropdownButtonFormField<String>));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Buy').last);
            await tester.pumpAndSettle();
            expect(find.byType(SettlementDaysDropdown), findsNothing);
            expect(c.settlementDays.value, isNull);
            expect(c.validateSettlement(), true);
            expect(c.buildPayload().containsKey('settlement_days'), false);

            await tester.tap(find.byType(DropdownButtonFormField<String>));
            await tester.pumpAndSettle();
            await tester.tap(find.text('Sell').last);
            await tester.pumpAndSettle();
            expect(find.byType(SettlementDaysDropdown), findsOneWidget);
            expect(c.validateSettlement(), false);
            await tester.pumpAndSettle();
            expect(find.text('Select a settlement cycle'), findsOneWidget);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
          },
        );
      }
    }
  }
}
