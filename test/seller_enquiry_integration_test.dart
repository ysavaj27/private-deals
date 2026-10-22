import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart'
    as institution;
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/sell_enquiries/sell_enquiries_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'enquiry_flow_test.dart' show inquiry, quotePayload;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  late HttpClientAdapter originalAdapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    app.configModel(ConfigModel.fromJson({}));
    originalAdapter = dioConfig.dio.httpClientAdapter;
    await app.setUser(prefUser: identity());
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  Future<void> mountSellerEnquiries(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/institution/sell-enquiries',
        getPages: Pages.pages,
      ),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/institution/sell-enquiries');
    expect(find.byType(SellEnquiriesPage), findsOneWidget);
  }

  test(
    'phone enquiries tab preserves Share Price under Company navigation',
    () {
      final controller = SellerHomePageCtrl();
      controller.currentTab(institution.WTabBarEnum.sellEnquiries);
      expect(controller.phoneNavIndex, 3);
      controller.currentTab(institution.WTabBarEnum.priceUpdate);
      expect(controller.isCompanyTab, isTrue);
      expect(controller.phoneNavIndex, 2);
    },
  );

  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'seller My Enquiries keeps converted transactions in seller workspace at $width',
      (tester) async {
        final adapter = FakeAdapter(
          (request) async => response({
            'status': 1,
            'data': request.path == EnquiryApi.partnerPath
                ? [inquiry('converted', side: 'sell')]
                : [],
          }),
        );
        dioConfig.dio.httpClientAdapter = adapter;
        await mountSellerEnquiries(tester, width);

        final link = find.text('View transactions');
        await tester.ensureVisible(link);
        await tester.pumpAndSettle();
        await tester.tap(link);
        await tester.pumpAndSettle();

        expect(Get.currentRoute, '/institution/unlisted-transactions');
        expect(find.byType(PreIPOTransactionPage), findsOneWidget);
        expect(
          adapter.requests.any(
            (request) => request.path == EnquiryApi.partnerPath,
          ),
          isTrue,
        );
        expect(
          adapter.requests.any(
            (request) => request.path == InstitutionEndpoints.preIpoTransaction,
          ),
          isTrue,
        );
        expect(
          adapter.requests.any(
            (request) => request.path == 'v2/business/pre-ipo/transaction-list',
          ),
          isFalse,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );

    for (final flow in ['approval', 'quote', 'counterparty']) {
      testWidgets(
        'seller $flow opens created order and runs seller payment action at $width',
        (tester) async {
          var converted = false;
          var paymentConfirmed = false;
          final order = <String, dynamic>{
            'id': 481,
            'transaction_invoice_no': 'SELL-481',
            'order_step': 'payment_confirmation_pending',
            'trade_side': 'sell',
            'order_source': 'enquiry',
            'mandate_sent': false,
            'shares': 10,
            'share_price': 100,
            'payable_amount': 1000,
            'company': {'id': 12, 'brand_name': 'Test Company'},
            'seller': {'name': 'Institution', 'partner_id': 7},
            'buyer': {'name': 'Buyer', 'partner_id': 9},
            'action': ['confirm_payment'],
          };
          final adapter = FakeAdapter((request) async {
            if (request.path == 'v2/business/investor') {
              return response({
                'status': 1,
                'data': [
                  {'id': 70, 'name': 'Seller Investor', 'preipo_kyc_status': 1},
                ],
              });
            }
            if (request.path == InstitutionEndpoints.preIpoConfirmPayment) {
              paymentConfirmed = true;
              return response({
                'status': 1,
                'message': 'Payment confirmed.',
                'data': {...order, 'action': <String>[]},
              });
            }
            if (request.path == InstitutionEndpoints.preIpoTransactionDetail) {
              return response({
                'status': 1,
                'data': {
                  ...order,
                  'current_step': paymentConfirmed
                      ? 'Payment confirmed. Transfer the shares.'
                      : 'Seller payment confirmation is pending.',
                  if (paymentConfirmed) 'action': <String>[],
                },
              });
            }
            if (request.path == InstitutionEndpoints.preIpoTransaction) {
              return response({
                'status': 1,
                'data': [order],
              });
            }
            if (request.method == 'POST') {
              converted = true;
              return response({
                'status': 1,
                'message':
                    'Enquiry accepted. The sell mandate could not be sent.',
                'data': order,
              });
            }
            if (request.path == EnquiryApi.partnerPath) {
              final item = inquiry(
                converted
                    ? 'converted'
                    : (flow == 'approval' ? 'locked' : 'open'),
                side: flow == 'counterparty' ? 'buy' : 'sell',
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
          await mountSellerEnquiries(tester, width);

          final action = switch (flow) {
            'quote' => find.byKey(
              const ValueKey('enquiry-accept-quote-quote-1'),
            ),
            'counterparty' => find.byKey(
              const ValueKey('enquiry-accept-counterparty-inquiry-1'),
            ),
            _ => find.widgetWithText(FilledButton, 'Approve'),
          };
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          await tester.tap(action);
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Seller Investor'));
          await tester.tap(find.text('Seller Investor'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(EnquiryDecisionDialog),
              matching: find.widgetWithText(
                FilledButton,
                flow == 'counterparty' ? 'Accept' : 'Approve',
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Transaction created'), findsOneWidget);
          expect(
            find.textContaining('sell mandate could not be sent'),
            findsWidgets,
          );
          final accept = adapter.requests
              .where((request) => request.method == 'POST')
              .single;
          expect(
            accept.path,
            '${EnquiryApi.partnerPath}/${switch (flow) {
              'quote' => 'quotes/accept',
              'counterparty' => 'accept-counterparty',
              _ => 'accept',
            }}',
          );
          expect(accept.data, {
            'uuid': 'inquiry-1',
            'investor_id': 70,
            if (flow == 'quote') 'quote_uuid': 'quote-1',
          });

          await tester.tap(
            find.widgetWithText(FilledButton, 'View transaction'),
          );
          await tester.pumpAndSettle();
          expect(find.text('Transaction details'), findsOneWidget);
          expect(
            find.text('Seller payment confirmation is pending.'),
            findsWidgets,
          );
          expect(
            adapter.requests.any(
              (request) =>
                  request.path == InstitutionEndpoints.preIpoTransactionDetail,
            ),
            isTrue,
          );

          final confirmPayment = find.text('Confirm payment');
          await tester.ensureVisible(confirmPayment);
          await tester.pumpAndSettle();
          await tester.tap(confirmPayment);
          await tester.pumpAndSettle();
          expect(paymentConfirmed, isTrue);
          expect(
            adapter.requests
                .where((request) => request.method == 'POST')
                .length,
            2,
          );
          expect(
            adapter.requests.any(
              (request) =>
                  request.path.startsWith('v2/business/pre-ipo/transaction'),
            ),
            isFalse,
          );
          expect(find.text('Confirm payment'), findsNothing);
          expect(Get.currentRoute, '/institution/sell-enquiries');
          expect(Get.isRegistered<PreIPOTransactionPageCtrl>(), isFalse);
          expect(Get.isRegistered<PreIPOBuyTransactionPageCtrl>(), isFalse);
          // Let both queued success notices finish without cancelling a
          // snackbar whose animation controller has not been created yet.
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
