import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_sections.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/seller_pre_ipo_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/seller_slots_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _SellerDetailCtrl extends PreIPODetailPageCtrl {
  _SellerDetailCtrl(CompanyModel company) {
    model.value = company;
  }
  final selections = <PreIPOOffer>[];

  @override
  Future<void> getData() async {}

  @override
  Future<void> selectOffer(PreIPOOffer offer, {required bool phone}) async {
    selections.add(offer);
  }
}

Map<String, dynamic> _deal(
  int id,
  String seller, {
  String type = 'sell',
  bool hot = false,
  int? settlementDays,
}) => {
  'id': id,
  'uuid': 'deal-$id',
  'status': 'available',
  'deal_type': type,
  'share_price': 1200 + id * 10,
  'minimum_qty': 100,
  'available_quantity': 2000,
  'is_hot_deal': hot,
  if (settlementDays != null) 'settlement_days': settlementDays,
  'seller': {'id': 100 + id, 'company_name': seller},
};

CompanyModel _company() => CompanyModel.fromJson({
  'id': 12,
  'slug': 'northstar',
  'brand_name': 'Northstar Technologies',
  'company_name': 'Northstar Technologies Limited',
  'sector': 'Technology',
  'category': 'Unlisted',
  'about': 'Long company overview that sellers should not see.',
  'fundamentals': {
    'lot_size': 100,
    'market_cap': 8400,
    'pe_ratio': 24.6,
    'roe': 18.4,
  },
  'deals': [
    _deal(1, 'Meridian Capital', hot: true),
    _deal(2, 'Oakwood Securities'),
    _deal(3, 'Crescent Investments'),
    _deal(4, 'Harbour Buyers', type: 'buy', settlementDays: 2),
  ],
  'seller_share_prices': [
    {
      'sell_price': 1270,
      'min_qty': 500,
      'seller': {'id': 19, 'company_name': 'Harbour Securities'},
    },
  ],
});

Future<_SellerDetailCtrl> _pump(
  WidgetTester tester,
  double width, {
  bool withRoutes = false,
}) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final c = _SellerDetailCtrl(_company());
  Get.put<PreIPODetailPageCtrl>(c);
  addTearDown(Get.reset);
  final home = SellerPreIPODetailView(phone: width < 600);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      initialRoute: withRoutes ? '/' : null,
      getPages: withRoutes
          ? [
              GetPage(
                name: '/',
                page: () => const Scaffold(body: Text('Home')),
              ),
              GetPage(name: '/detail', page: () => home),
              GetPage(
                name: '/institution/sell-enquiries',
                page: () => const Scaffold(body: Text('Seller enquiries')),
              ),
              GetPage(
                name: '/wealth-manager/my-inquiries',
                page: () => const Scaffold(body: Text('My enquiries')),
              ),
            ]
          : null,
      home: withRoutes ? null : home,
    ),
  );
  await tester.pumpAndSettle();
  if (withRoutes) {
    Get.toNamed('/detail');
    await tester.pumpAndSettle();
  }
  return c;
}

void main() {
  late HttpClientAdapter originalAdapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.setUser(prefUser: identity('Institution'));
    originalAdapter = dioConfig.dio.httpClientAdapter;
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  testWidgets('Seller detail shows only the header and the deals board', (
    tester,
  ) async {
    await _pump(tester, 1280);
    expect(find.byType(PreIPOCompanyHeader), findsOneWidget);
    expect(find.text('Market cap'), findsOneWidget);
    expect(find.byType(PreIPODetailSections), findsNothing);
    expect(find.byType(SellerSlotsWidget), findsNothing);
    expect(find.text('Fundamentals'), findsNothing);
    expect(find.textContaining('Long company overview'), findsNothing);
    expect(find.byKey(const ValueKey('pre-ipo-enquiry-footer')), findsNothing);
    expect(find.byKey(const ValueKey('seller-deals-board')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Desktop lists deals as rows under column headers', (
    tester,
  ) async {
    await _pump(tester, 1280);
    expect(
      find.byKey(const ValueKey('seller-deals-list-header')),
      findsNWidgets(2),
    );
    expect(find.text('Price / share'), findsNWidgets(2));
    final oakwood = tester.getTopLeft(find.text('Oakwood Securities'));
    final crescent = tester.getTopLeft(find.text('Crescent Investments'));
    expect(oakwood.dx, crescent.dx);
    expect(crescent.dy, greaterThan(oakwood.dy));
    final hot = tester.getTopLeft(
      find.byKey(const ValueKey('seller-hot-deals')),
    );
    final offers = tester.getTopLeft(
      find.byKey(const ValueKey('seller-available-offers')),
    );
    expect(hot.dy, lessThan(offers.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phone stacks compact rows without column headers', (
    tester,
  ) async {
    await _pump(tester, 390);
    expect(find.byKey(const ValueKey('seller-deals-list-header')), findsNothing);
    final oakwood = tester.getTopLeft(find.text('Oakwood Securities'));
    final crescent = tester.getTopLeft(find.text('Crescent Investments'));
    expect(oakwood.dx, crescent.dx);
    expect(crescent.dy, greaterThan(oakwood.dy));
    expect(find.textContaining('Min. 100 shares'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sellers can buy sell deals without the partner enquire footer', (
    tester,
  ) async {
    final c = await _pump(tester, 1280);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('seller-buy-tab')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Buy'), findsNWidgets(3));
    expect(find.byKey(const ValueKey('pre-ipo-enquiry-footer')), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Buy').first);
    await tester.pumpAndSettle();
    expect(c.selections.single.dealId, 1);

    await tester.tap(find.text('Harbour Securities'));
    await tester.pumpAndSettle();
    expect(find.text('Seller details'), findsOneWidget);
    expect(find.textContaining('Enquire'), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('seller-sell-tab')));
    await tester.pumpAndSettle();
    expect(find.text('Harbour Buyers'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Buy'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Sell'), findsOneWidget);

    await tester.tap(find.text('Harbour Buyers'));
    await tester.pumpAndSettle();
    expect(find.text('Buyer details'), findsOneWidget);
    expect(find.text('Buy Now'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Sell Now'), findsOneWidget);
    expect(
      find.textContaining('raise a sell enquiry'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Sell on buyer deals opens seeded enquiry dialog and cancel stays',
    (tester) async {
      final originalConfig = app.config;
      addTearDown(() => app.configModel(originalConfig));
      app.configModel(
        ConfigModel.fromJson({
          'settlement_days': [
            {'value': 2, 'label': 'T+2'},
          ],
        }),
      );
      final c = await _pump(tester, 1280);
      await tester.tap(find.byKey(const ValueKey('seller-sell-tab')));
      await tester.pumpAndSettle();
      final sell = find.widgetWithText(FilledButton, 'Sell');
      expect(sell, findsOneWidget);
      await tester.tap(sell);
      await tester.pumpAndSettle();
      expect(find.byType(DesktopEnquiryDialogView), findsOneWidget);
      expect(find.textContaining('open sell enquiry'), findsOneWidget);
      final enquiry = tester.widget<DesktopEnquiryDialogView>(
        find.byType(DesktopEnquiryDialogView),
      );
      expect(enquiry.initialType, InvestmentTypeEnum.sell);
      expect(enquiry.initialQuantity, 100);
      expect(enquiry.initialOfferPrice, 1240);
      expect(enquiry.initialSettlementDays, 2);
      expect(c.selections, isEmpty);

      await tester.tap(find.widgetWithText(CustomOutlinedButton, 'Close'));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopEnquiryDialogView), findsNothing);
      expect(find.byKey(const ValueKey('seller-deals-board')), findsOneWidget);
      expect(c.selections, isEmpty);

      await tester.tap(find.text('Harbour Buyers'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sell Now'));
      await tester.pumpAndSettle();
      expect(find.text('Buyer details'), findsNothing);
      expect(find.byType(DesktopEnquiryDialogView), findsOneWidget);
      final fromDetails = tester.widget<DesktopEnquiryDialogView>(
        find.byType(DesktopEnquiryDialogView),
      );
      expect(fromDetails.initialType, InvestmentTypeEnum.sell);
      expect(fromDetails.initialQuantity, 100);
      expect(fromDetails.initialOfferPrice, 1240);
      expect(c.selections, isEmpty);
    },
  );

  testWidgets(
    'Successful seller sell enquiry navigates to institution enquiries',
    (tester) async {
      final originalConfig = app.config;
      addTearDown(() => app.configModel(originalConfig));
      app.configModel(
        ConfigModel.fromJson({
          'settlement_days': [
            {'value': 2, 'label': 'T+2'},
          ],
        }),
      );
      final adapter = FakeAdapter((_) async => response({'status': 1}));
      dioConfig.dio.httpClientAdapter = adapter;
      await _pump(tester, 1280, withRoutes: true);
      await tester.tap(find.byKey(const ValueKey('seller-sell-tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Sell'));
      await tester.pumpAndSettle();
      expect(find.byType(DesktopEnquiryDialogView), findsOneWidget);
      await tester.ensureVisible(find.text('Submit'));
      final submit = tester.widget<CustomElevatedButton>(
        find.ancestor(
          of: find.text('Submit'),
          matching: find.byType(CustomElevatedButton),
        ),
      );
      await tester.runAsync(submit.onPressed as Future<void> Function());
      await tester.pumpAndSettle();
      expect(adapter.requests.single.path, 'v2/business/enquiries/deals');
      expect(adapter.requests.single.data, {
        'deal_type': 'sell',
        'company_slug': 'northstar',
        'quantity': 100,
        'share_price': 1240,
        'settlement_days': 2,
      });
      expect(Get.currentRoute, Routes.enquiriesPath());
      expect(find.text('Seller enquiries'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Sell deal dialog offers Buy Now', (tester) async {
    final c = await _pump(tester, 1280);
    await tester.tap(find.text('Oakwood Securities'));
    await tester.pumpAndSettle();
    expect(find.text('Offer details'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Buy Now'));
    await tester.pumpAndSettle();
    expect(c.selections.single.dealId, 2);
  });
}
