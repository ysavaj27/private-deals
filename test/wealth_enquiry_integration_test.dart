import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart'
    as seller;
import 'package:private_deals/src/features/wealth_manager/presentation/desktop_sidebar.dart'
    as partner;
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'enquiry_flow_test.dart'
    show inquiry, quotePayload, seedSettlementConfig;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  late HttpClientAdapter originalAdapter;
  late List<Interceptor> originalInterceptors;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    seedSettlementConfig();
    originalAdapter = dioConfig.dio.httpClientAdapter;
    originalInterceptors = dioConfig.dio.interceptors.toList();
    // Keep permission/session enforcement, without logging request headers.
    dioConfig.dio.interceptors.removeWhere((item) => item is ApiLogInterceptor);
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    dioConfig.dio.interceptors
      ..clear()
      ..addAll(originalInterceptors);
    await app.clear();
    Get.reset();
  });

  Future<void> mount(
    WidgetTester tester,
    double width, {
    String path = Routes.myInquiries,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        initialRoute: path,
        getPages: Pages.pages,
      ),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, path);
    expect(find.byType(seller.DSideBarWidget), findsNothing);
    if (width >= 1024) {
      expect(find.byType(partner.DSideBarWidget), findsOneWidget);
    }
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  void expectPartnerRequests(FakeAdapter adapter) {
    expect(
      adapter.requests.where((r) => r.path.contains('/institution/')),
      isEmpty,
    );
  }

  for (final width in [390.0, 1024.0, 1440.0]) {
    testWidgets('WM sidebar, filters, refresh failure and retry at $width', (
      tester,
    ) async {
      var failList = false;
      final adapter = FakeAdapter((request) async {
        if (request.path == EnquiryApi.partnerPath) {
          return response(
            failList
                ? {'status': 0, 'message': 'List unavailable'}
                : {
                    'status': 1,
                    'data': [
                      inquiry('open')
                        ..['company'] = {'brand_name': 'Own Buy Company'},
                      inquiry('open', side: 'sell')
                        ..['partner'] = {'id': 9, 'name': 'Other Partner'}
                        ..['uuid'] = 'other-sell'
                        ..['company'] = {'brand_name': 'Other Sell Company'},
                    ],
                  },
          );
        }
        return response({'status': 1, 'data': <String, dynamic>{}});
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await mount(tester, width, path: '/wealth-manager/dashboard');
      if (width < 1024) {
        tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
        await tester.pumpAndSettle();
      }
      await tap(tester, find.text('My Enquiries').last);
      expect(Get.currentRoute, Routes.myInquiries);
      expect(Get.find<HomePageCtrl>().currentTab(), WTabBarEnum.myInquiries);
      expect(find.byType(EnquiriesPage), findsOneWidget);
      expect(find.text('All (2)'), findsOneWidget);
      expect(find.text('Buy (1)'), findsOneWidget);
      expect(find.text('Sell (1)'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('inquiry-type-sell')));
      await tester.enterText(find.byType(TextField).first, 'Other');
      await tester.pumpAndSettle();
      expect(find.text('Other Sell Company'), findsOneWidget);
      expect(find.text('Own Buy Company'), findsNothing);
      expect(find.text('Accept & buy'), findsOneWidget);
      expect(find.text('Send quote'), findsNothing);

      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byTooltip('Refresh enquiries'),
        -300,
        scrollable: find
            .descendant(
              of: find.byType(EnquiriesPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      failList = true;
      await tap(tester, find.byTooltip('Refresh enquiries'));
      expect(find.text('Could not load enquiries'), findsOneWidget);
      expect(find.text('Accept & buy'), findsNothing);
      failList = false;
      await tap(tester, find.widgetWithText(FilledButton, 'Retry'));
      expect(find.text('Other Sell Company'), findsOneWidget);
      expect(find.text('Own Buy Company'), findsNothing);
      expect(
        tester
            .widget<ChoiceChip>(find.byKey(const ValueKey('inquiry-type-sell')))
            .selected,
        isTrue,
      );
      expectPartnerRequests(adapter);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    for (final side in ['buy', 'sell']) {
      for (final flow in ['approval', 'quote', 'counterparty']) {
        testWidgets(
          'WM $side $flow creates and opens Partner transaction at $width',
          (tester) async {
            var converted = false;
            final selling = flow == 'counterparty'
                ? side == 'buy'
                : side == 'sell';
            final order = {
              'id': 481,
              'transaction_invoice_no': 'WM-481',
              'order_step': 'mandate_pending',
              'trade_side': selling ? 'sell' : 'buy',
              'order_source': 'enquiry',
              'mandate_sent': false,
              'current_step': 'Partner mandate awaiting signature.',
              'shares': 10,
              'share_price': 100,
              'payable_amount': 1000,
              'company': {'id': 12, 'brand_name': 'Test Company'},
              'investor': {'id': 70, 'name': 'WM Investor'},
              'buyer': {'partner_id': selling ? 9 : 7, 'name': 'Buyer'},
              'seller': {'partner_id': selling ? 7 : 9, 'name': 'Seller'},
              'action': <String>[],
            };
            final adapter = FakeAdapter((request) async {
              if (request.path == 'v2/business/investor') {
                return response({
                  'status': 1,
                  'data': [
                    {'id': 70, 'name': 'WM Investor', 'preipo_kyc_status': 1},
                  ],
                });
              }
              if (request.path == 'v2/business/pre-ipo/transaction/detail') {
                return response({'status': 1, 'data': order});
              }
              if (request.method == 'POST') {
                converted = true;
                return response({
                  'status': 1,
                  'message': 'Transaction created; mandate delivery failed.',
                  'data': order,
                });
              }
              if (request.path == EnquiryApi.partnerPath) {
                final item = inquiry(
                  converted
                      ? 'converted'
                      : flow == 'approval'
                      ? 'locked'
                      : 'open',
                  side: side,
                  quotes: flow == 'quote' ? [quotePayload()] : null,
                );
                if (flow == 'counterparty') {
                  item['partner'] = {'id': 9, 'name': 'Other Partner'};
                }
                return response({
                  'status': 1,
                  'data': [item],
                });
              }
              return response({'status': 1, 'data': []});
            });
            dioConfig.dio.httpClientAdapter = adapter;
            await mount(tester, width);
            final action = switch (flow) {
              'quote' => find.byKey(
                const ValueKey('enquiry-accept-quote-quote-1'),
              ),
              'counterparty' => find.byKey(
                const ValueKey('enquiry-accept-counterparty-inquiry-1'),
              ),
              _ => find.widgetWithText(FilledButton, 'Approve'),
            };
            await tap(tester, action);
            final confirm = find.descendant(
              of: find.byType(EnquiryDecisionDialog),
              matching: find.widgetWithText(
                FilledButton,
                flow == 'counterparty' ? 'Accept' : 'Approve',
              ),
            );
            expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
            expect(
              find.textContaining(
                'will ${selling ? 'sell' : 'buy'} the shares',
              ),
              findsOneWidget,
            );
            await tap(tester, find.text('WM Investor'));
            await tap(tester, confirm);
            expect(find.text('Transaction created'), findsOneWidget);
            expect(
              find.textContaining('mandate delivery failed'),
              findsWidgets,
            );
            final post = adapter.requests
                .where((r) => r.method == 'POST')
                .single;
            expect(
              post.path,
              '${EnquiryApi.partnerPath}/${switch (flow) {
                'quote' => 'quotes/accept',
                'counterparty' => 'accept-counterparty',
                _ => 'accept',
              }}',
            );
            expect(post.data, {
              'uuid': 'inquiry-1',
              'investor_id': 70,
              if (flow == 'quote') 'quote_uuid': 'quote-1',
            });
            expect(
              adapter.requests
                  .where((r) => r.path == 'v2/business/investor')
                  .length,
              2,
            );
            await tap(
              tester,
              find.widgetWithText(FilledButton, 'View transaction'),
            );
            expect(find.text('Transaction details'), findsOneWidget);
            expect(
              find.text('Partner mandate awaiting signature.'),
              findsWidgets,
            );
            expect(
              adapter.requests.any(
                (r) => r.path == 'v2/business/pre-ipo/transaction/detail',
              ),
              isTrue,
            );
            expectPartnerRequests(adapter);
            expect(Get.currentRoute, Routes.myInquiries);
            expect(Get.isRegistered<PreIPOBuyTransactionPageCtrl>(), isFalse);
            await tap(tester, find.widgetWithText(OutlinedButton, 'Close'));
            expect(find.text('Converted to transaction'), findsOneWidget);
            await tap(tester, find.text('View transactions'));
            expect(Get.currentRoute, Routes.unlistedTransactionsPath());
            expect(
              Get.find<InvestorTransactionPageCtrl>().currentIndex.value,
              TransactionTypeEnum.preIpoBuy,
            );
            expect(
              adapter.requests.any(
                (r) => r.path == 'v2/business/pre-ipo/transaction-list',
              ),
              isTrue,
            );
            expectPartnerRequests(adapter);
            await tester.pump(const Duration(seconds: 5));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }

  for (final failure in ['kyc changed', 'already converted']) {
    testWidgets('WM approval handles $failure after investor selection', (
      tester,
    ) async {
      var investorReads = 0;
      var listReads = 0;
      final adapter = FakeAdapter((request) async {
        if (request.path == 'v2/business/investor') {
          investorReads++;
          return response({
            'status': 1,
            'data': [
              {
                'id': 70,
                'name': 'WM Investor',
                'preipo_kyc_status':
                    failure == 'kyc changed' && investorReads > 1 ? 0 : 1,
              },
            ],
          });
        }
        if (request.method == 'POST') {
          return response({
            'status': 0,
            'message': 'Enquiry already converted.',
          });
        }
        if (request.path == EnquiryApi.partnerPath) {
          listReads++;
          return response({
            'status': 1,
            'data': [
              inquiry(
                failure == 'already converted' && listReads > 1
                    ? 'converted'
                    : 'locked',
              ),
            ],
          });
        }
        return response({'status': 1, 'data': []});
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await mount(tester, 1440);
      await tap(tester, find.widgetWithText(FilledButton, 'Approve'));
      await tap(tester, find.text('WM Investor'));
      await tap(
        tester,
        find.descendant(
          of: find.byType(EnquiryDecisionDialog),
          matching: find.widgetWithText(FilledButton, 'Approve'),
        ),
      );
      expect(investorReads, 2);
      expect(listReads, 2);
      expect(find.text('Transaction created'), findsNothing);
      expect(Get.currentRoute, Routes.myInquiries);
      if (failure == 'kyc changed') {
        expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
        expect(
          find.textContaining('Complete KYC for WM Investor'),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Approve'), findsOneWidget);
      } else {
        expect(adapter.requests.where((r) => r.method == 'POST').length, 1);
        expect(find.text('Converted to transaction'), findsOneWidget);
        expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      }
      expectPartnerRequests(adapter);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
