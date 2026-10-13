import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/phone_pre_ipo_investment_view.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _Checkout extends PreIPOInvestmentPageCtrl {
  // Start with an already selected investor, as on a checkout in progress.
  @override
  void getData() {}
  @override
  void onReady() {}
}

void main() {
  late HttpClientAdapter originalAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    originalAdapter = dioConfig.dio.httpClientAdapter;
  });
  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  for (final role in ['Wealth Manager', 'Institution']) {
    testWidgets('$role keeps and submits its draft after checkout widens', (
      tester,
    ) async {
      await app.setUser(prefUser: identity(role));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final company = CompanyModel.fromJson({
        'brand_name': 'Test Company',
        'slug': 'test-company',
      });
      final offer = PreIPOOffer.fromDeal(
        DealModel.fromJson({
          'id': 42,
          'uuid': 'deal-42',
          'deal_type': 'sell',
          'share_price': 120.75,
          'minimum_qty': 10,
          'seller': {'id': 8, 'company_name': 'Test Seller'},
        }),
      );
      final self = role == 'Institution';
      final draft = SelectInvestorModel(
        investorId: self ? 70 : 22,
        investorName: self ? 'My account' : 'Test client',
        isSelf: self,
        isMarket: true,
        price: offer.price,
        priceCTRL: TextEditingController(text: '120.75'),
        quantityCTRL: TextEditingController(),
      );
      final controller = _Checkout()
        ..model(company)
        ..selectedOffer.value = offer;
      controller.investorList.add(draft);
      final adapter = FakeAdapter(
        (request) async => response({
          'status': 1,
          'data': request.method == 'GET'
              ? [
                  {'id': draft.investorId, 'preipo_kyc_status': 1},
                ]
              : [],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Scaffold()),
            GetPage(
              name: '/investment',
              page: () {
                Get.put<PreIPOInvestmentPageCtrl>(controller);
                return const PreIPOInvestmentPage();
              },
            ),
            GetPage(
              name: '/wealth-manager/investor-transactions',
              page: () => const Scaffold(body: Text('Orders')),
            ),
            GetPage(
              name: '/institution/unlisted-transactions',
              page: () => const Scaffold(body: Text('Orders')),
            ),
          ],
        ),
      );
      Get.toNamed(
        '/investment',
        arguments: PreIPOInvestmentSelection(company, offer),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '25');
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(1280, 1000);
      await tester.pumpAndSettle();
      expect(find.byType(CardView), findsOneWidget);
      expect(find.text('Invest'), findsOneWidget);
      expect(draft.quantityCTRL!.text, '25');
      expect(draft.priceCTRL!.text, '120.75');
      expect(controller.investorList.single, same(draft));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Invest'));
      await tester.pumpAndSettle();
      final buy = adapter.requests.singleWhere(
        (request) => request.method == 'POST',
      );
      expect(buy.data, {
        'orders': [
          {
            'investor_id': draft.investorId,
            'deal_id': 42,
            'deal_uuid': 'deal-42',
            'shares': 25,
            'share_price': 120.75,
          },
        ],
      });
      expect(Get.currentRoute, Routes.unlistedTransactionsPath());
      expect(find.text('Orders'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
