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
import 'package:private_deals/src/features/wealth_manager/presentation/phone_sidebar.dart'
    as partner_phone;
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
      'Wealth manager investors and CML retain partner workspace at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await app.setUser(prefUser: identity('Wealth Manager'));
        dioConfig.dio.httpClientAdapter = FakeAdapter(
          (_) async => response({'status': 1, 'data': []}),
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

        Get.toNamed('/investors/70/cml');
        await tester.pumpAndSettle();
        if (width > 600) {
          expect(find.byType(partner.DSideBarWidget), findsOneWidget);
        } else {
          await tester.tap(find.byTooltip('Open navigation menu'));
          await tester.pumpAndSettle();
          expect(find.byType(partner_phone.PSideBarWidget), findsOneWidget);
        }
        await tester.tap(find.text('Investors').last);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/wealth-manager/investors');
        expect(app.role, PartnerRole.wealthManager);
        expect(app.token, 'test-token-7');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'Seller sidebar keeps original labels and opens old seller APIs',
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
      expect(
        adapter.requests.any((r) => r.path == 'v2/seller/dashboard'),
        isTrue,
      );
      expect(find.text('Update Unlisted Share Price'), findsOneWidget);
      expect(find.text('Unlisted Companies'), findsOneWidget);
      await tester.tap(find.text('Sell Enquiries'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/institution/sell-enquiries');
      expect(
        adapter.requests.any((r) => r.path == 'v2/seller/sell-enquiries/list'),
        isTrue,
      );
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlisted').last);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, '/institution/unlisted-transactions');
      expect(
        adapter.requests.any((r) => r.path == 'v2/seller/pre-ipo/transaction'),
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
      final c = Get.find<UpdateSharePriceCtrl>();
      expect(c.rows.length, 2);
      c.rows.first.price.text = '100';
      c.rows.first.minQty.text = '5';
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
          {'company_id': 1, 'sell_price': 100, 'min_qty': 5, 'total_qty': null},
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
