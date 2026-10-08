import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/seller_slots_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;
import 'enquiry_flow_test.dart' show inquiry;

class _DetailCtrl extends PreIPODetailPageCtrl {
  @override
  Future<void> getData() async {}
}

class _InvestmentCtrl extends PreIPOInvestmentPageCtrl {
  @override
  void onReady() {} // Investor selection is seeded by the test.
}

PreIPOOffer offer() => PreIPOOffer.fromDeal(
  DealModel.fromJson({
    'id': 42,
    'deal_type': 'sell',
    'share_price': 100,
    'minimum_qty': 1,
  }),
);

SelectInvestorModel investor() => SelectInvestorModel(
  investorId: 1,
  quantity: 10,
  price: 100,
  quantityCTRL: TextEditingController(text: '10'),
  priceCTRL: TextEditingController(text: '100'),
);

Future<void> mountFlow(
  WidgetTester tester,
  Widget Function() source, {
  String sourcePath = '/detail',
}) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const Scaffold(body: Text('Home')),
        ),
        GetPage(name: sourcePath, page: source),
        GetPage(
          name: '/wealth-manager/investor-transactions',
          page: () => const Scaffold(body: Text('Partner transactions')),
        ),
        GetPage(
          name: '/wealth-manager/my-inquiries',
          page: () => const Scaffold(body: Text('My enquiries')),
        ),
        GetPage(
          name: '/institution/unlisted-transactions',
          page: () => const Scaffold(body: Text('Seller transactions')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  Get.toNamed(sourcePath);
  await tester.pumpAndSettle();
}

void main() {
  late HttpClientAdapter originalAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.setUser(prefUser: identity('Wealth Manager'));
    originalAdapter = dioConfig.dio.httpClientAdapter;
  });
  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  for (final mobile in [false, true]) {
    for (final success in [false, true]) {
      testWidgets(
        '${mobile ? 'mobile' : 'desktop'} purchase ${success ? 'opens Unlisted' : 'failure retains draft'}',
        (tester) async {
          final adapter = FakeAdapter(
            (request) async => response(
              request.method == 'GET'
                  ? {
                      'status': 1,
                      'data': [
                        {'id': 1, 'preipo_kyc_status': 1},
                      ],
                    }
                  : {'status': success ? 1 : 0, 'data': []},
            ),
          );
          dioConfig.dio.httpClientAdapter = adapter;
          final desktop = _DetailCtrl();
          final phone = _InvestmentCtrl();
          await mountFlow(tester, () {
            if (mobile) {
              Get.put<PreIPOInvestmentPageCtrl>(phone);
              phone.selectedOffer.value = offer();
              phone.investorList.add(investor());
            } else {
              Get.put<PreIPODetailPageCtrl>(desktop);
              desktop.selectedOffer.value = offer();
              desktop.investorList.add(investor());
            }
            return const Scaffold(body: Text('Purchase form'));
          });
          await tester.runAsync(
            () => mobile ? phone.onPress() : desktop.onPress(),
          );
          await tester.pumpAndSettle();
          expect(
            adapter.requests.where((r) => r.method == 'POST'),
            hasLength(1),
          );
          expect(tester.takeException(), isNull);
          if (success) {
            expect(Get.currentRoute, Routes.unlistedTransactionsPath());
            expect(Get.parameters['asset'], 'unlisted');
            expect(find.text('Partner transactions'), findsOneWidget);
            expect(Get.key.currentState!.canPop(), isFalse);
          } else {
            expect(Get.currentRoute, '/detail');
            expect(
              mobile ? phone.investorList.length : desktop.investorList.length,
              1,
            );
          }
        },
      );
    }
  }

  for (final width in [390.0, 800.0]) {
    for (final outcome in ['success', 'failure', 'cancel']) {
      testWidgets(
        'Pre-IPO enquiry $outcome at $width navigates only after creation',
        (tester) async {
          tester.view.physicalSize = Size(width, width < 600 ? 850 : 600);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final adapter = FakeAdapter(
            (_) async => response({'status': outcome == 'success' ? 1 : 0}),
          );
          dioConfig.dio.httpClientAdapter = adapter;
          await mountFlow(tester, () {
            final c = Get.put<PreIPODetailPageCtrl>(_DetailCtrl());
            c.model.value = CompanyModel.fromJson({'slug': 'test-company'});
            return Scaffold(
              body: SingleChildScrollView(child: SellerSlotsWidget()),
            );
          });
          await tester.tap(find.text('Enquire'));
          await tester.pumpAndSettle();
          if (outcome == 'cancel') {
            await tester.ensureVisible(find.text('Close'));
            await tester.tap(find.text('Close'));
          } else {
            await tester.enterText(find.byType(TextFormField).at(0), '10');
            await tester.enterText(find.byType(TextFormField).at(1), '100');
            await tester.ensureVisible(find.text('Submit'));
            final submit = tester.widget<CustomElevatedButton>(
              find.ancestor(
                of: find.text('Submit'),
                matching: find.byType(CustomElevatedButton),
              ),
            );
            await tester.runAsync(submit.onPressed as Future<void> Function());
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            Get.currentRoute,
            outcome == 'success' ? Routes.enquiriesPath() : '/detail',
          );
          if (outcome == 'success') {
            expect(find.text('My enquiries'), findsOneWidget);
            expect(Get.key.currentState!.canPop(), isFalse);
          } else if (outcome == 'failure') {
            expect(find.text('Submit'), findsOneWidget);
          } else {
            expect(adapter.requests, isEmpty);
          }
        },
      );
    }
  }

  for (final institution in [false, true]) {
    for (final width in [390.0, 1440.0]) {
      testWidgets(
        '${institution ? 'seller' : 'partner'} converted enquiry opens transactions at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await app.setUser(
            prefUser: identity(institution ? 'Institution' : 'Wealth Manager'),
          );
          dioConfig.dio.httpClientAdapter = FakeAdapter(
            (_) async => response({
              'status': 1,
              'data': [inquiry('converted')],
            }),
          );
          await mountFlow(
            tester,
            () => Scaffold(body: EnquiriesPage(institution: institution)),
          );
          final link = find.text('View transactions');
          await tester.ensureVisible(link);
          await tester.tap(link);
          await tester.pumpAndSettle();
          expect(
            Get.currentRoute,
            Routes.unlistedTransactionsPath(institution: institution),
          );
          expect(
            find.text(
              institution ? 'Seller transactions' : 'Partner transactions',
            ),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'Unlisted route resets a reused controller and keeps phone and desktop tabs in sync',
    (tester) async {
      late InvestorTransactionPageCtrl c;
      await mountFlow(tester, () {
        c = Get.put(InvestorTransactionPageCtrl(), permanent: true);
        return const Scaffold(body: Text('Tab source'));
      });
      c.changeTab(TransactionTypeEnum.secondary);
      expect(c.tabController.index, 1);
      Get.offNamed(Routes.unlistedTransactionsPath());
      await tester.pumpAndSettle();
      // A surviving controller must honour the requested tab as well as a new one.
      final reused = Get.find<InvestorTransactionPageCtrl>();
      reused.changeTab(TransactionTypeEnum.primary);
      reused.applyRouteSelection();
      expect(reused.currentIndex.value, TransactionTypeEnum.preIpoBuy);
      expect(reused.tabController.index, 0);
      reused.tabController.index = 1;
      expect(reused.currentIndex.value, TransactionTypeEnum.secondary);
      reused.changeTab(TransactionTypeEnum.primary);
      expect(reused.tabController.index, 2);
      expect(tester.takeException(), isNull);
    },
  );
}
