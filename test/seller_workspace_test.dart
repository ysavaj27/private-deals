import 'package:private_deals/src/core/configuration/init_config.dart';
import 'package:private_deals/src/shared/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/app/routing/pages.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/desktop_sidebar.dart'
    as partner;
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart'
    as seller;
import 'package:private_deals/src/features/institution/legacy/features/company/update_share_price/update_share_price_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    app.configModel(
      ConfigModel.fromJson({
        'app_version': [
          {
            'type': init.packageName,
            'data': [
              {'device': init.deviceOs, 'current_version_code': 0},
            ],
          },
        ],
      }),
    );
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'Wealth manager KYC dialog retains partner workspace at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await app.setUser(prefUser: identity('Wealth Manager'));
        dioConfig.dio.httpClientAdapter = FakeAdapter(
          (request) async => response({
            'status': 1,
            'data': request.path == 'v2/business/investor'
                ? [
                    {'id': 70, 'name': 'Test Investor', 'preipo_kyc_status': 0},
                  ]
                : [],
          }),
        );
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/wealth-manager/investors',
            getPages: Pages.pages,
          ),
        );
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/wealth-manager/investors');
        expect(app.role, PartnerRole.wealthManager);
        expect(find.byType(seller.DSideBarWidget), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Complete KYC'));
        await tester.pumpAndSettle();
        expect(find.text('Investor KYC'), findsOneWidget);
        expect(Get.currentRoute, '/wealth-manager/investors');
        await tester.tap(find.byTooltip('Close KYC'));
        await tester.pumpAndSettle();
        if (width > 600) {
          expect(find.byType(partner.DSideBarWidget), findsOneWidget);
        }
        expect(Get.currentRoute, '/wealth-manager/investors');
        expect(app.role, PartnerRole.wealthManager);
        expect(app.token, 'test-token-7');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'Institution sidebar labels and opens Institution transaction APIs',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async => response({'status': 1, 'data': []}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/institution/dashboard',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Unlisted'), findsWidgets);
      expect(find.text('LP Secondary'), findsWidgets);
      expect(find.text('Deal of the day'), findsOneWidget);
      expect(find.text('Inquiry'), findsOneWidget);
      await tester.tap(find.text('Unlisted').first);
      await tester.pumpAndSettle();
      expect(find.text('Manage Company'), findsWidgets);
      expect(find.text('Update Share Price'), findsWidgets);
      await tester.tap(find.text('LP Secondary').first);
      await tester.pumpAndSettle();
      expect(find.text('Manage Deals'), findsOneWidget);
      await tester.tap(find.text('Inquiry'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/institution/sell-enquiries');
      expect(
        adapter.requests.any(
          (r) => r.path == 'v2/business/institution/enquiries',
        ),
        isTrue,
      );
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/institution/unlisted-transactions');
      expect(
        adapter.requests.any(
          (r) => r.path == 'v2/business/institution/pre-ipo/transaction',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'Seller endpoints reject other roles and unsupported seller actions',
    () async {
      final adapter = FakeAdapter((_) async => response({'status': 1}));
      dioConfig.dio.httpClientAdapter = adapter;
      await app.setUser(prefUser: identity('Wealth Manager'));
      await expectLater(
        dioConfig.get('v2/seller/dashboard', {}),
        throwsException,
      );
      await app.setUser(prefUser: identity());
      await expectLater(
        dioConfig.post('v2/seller/company', {}),
        throwsException,
      );
      await expectLater(dioConfig.post('v2/seller/login', {}), throwsException);
      expect(adapter.requests, isEmpty);
    },
  );

  testWidgets(
    'Bulk price table lists companies and preserves separate buy and sell drafts',
    (tester) async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (r) async => response({
          'status': 1,
          'data': [
            {'id': 1, 'brand_name': 'Alpha', 'company_name': 'Alpha Ltd'},
            {'id': 2, 'brand_name': 'Beta', 'company_name': 'Beta Ltd'},
          ],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/institution/bulk-deals',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      app.configModel(
        ConfigModel.fromJson({
          'settlement_days': [
            {'value': 1, 'label': 'T+1'},
            {'value': 2, 'label': 'T+2'},
          ],
        }),
      );
      final c = Get.find<UpdateSharePriceCtrl>();
      expect(c.rows.length, 2);
      c.rows.first.price.text = '100';
      c.rows.first.minQty.text = '5';
      c.setCommonSettlement(2);
      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      expect(c.dealType.value, 'buy');
      expect(c.rows.length, 2);
      expect(c.rows.first.price.text, isEmpty);
      c.rows.first.price.text = '90';
      c.rows.first.minQty.text = '10';
      c.rows.first.totalQty.text = '9';
      expect(c.validateRow(c.rows.first), isFalse);
      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      expect(c.rows.first.price.text, '100');
      expect(c.rows.first.minQty.text, '5');
      expect(c.rows.first.settlementDays.value, 2);
      // A rejected batch keeps both tabs' entries; successful save clears only
      // the submitted tab and sends the existing bulk API's sell/buy contract.
      final failed = FakeAdapter(
        (_) async => response({'status': 0, 'message': 'Please retry'}),
      );
      dioConfig.dio.httpClientAdapter = failed;
      await tester.runAsync(c.save);
      await tester.pumpAndSettle();
      expect(c.rows.first.price.text, '100');
      expect(c.buyRows.first.price.text, '90');
      final successful = FakeAdapter(
        (_) async => response({'status': 1, 'message': 'Saved'}),
      );
      dioConfig.dio.httpClientAdapter = successful;
      await tester.runAsync(c.save);
      await tester.pumpAndSettle();
      expect(successful.requests.single.data, {
        'sell': [
          {
            'company_id': 1,
            'sell_price': 100,
            'min_qty': 5,
            'total_qty': null,
            'settlement_days': 2,
          },
        ],
        'buy': [],
      });
      expect(c.rows.first.price.text, isEmpty);
      expect(c.buyRows.first.price.text, '90');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
