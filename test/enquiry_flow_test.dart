import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_model.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

Map<String, dynamic> quotePayload({
  String uuid = 'quote-1',
  String status = 'pending',
  String institutionName = 'Institution',
}) => {
  'uuid': uuid,
  'institution': {'id': 8, 'name': institutionName},
  'quantity': 12,
  'base_price': 110,
  'share_price': 111.1,
  'settlement_days': 2,
  'settlement_label': 'T+2',
  'status': status,
};

Map<String, dynamic> inquiry(
  String status, {
  String side = 'buy',
  Map<String, dynamic>? myQuote,
  List<Map<String, dynamic>>? quotes,
}) => {
  'uuid': 'inquiry-1',
  'deal_type': side,
  'enquiry_status': status,
  'quantity': 10,
  'base_price': 100,
  'share_price': 101,
  'settlement_days': 1,
  'settlement_label': 'T+1',
  'notes': 'Please process',
  'partner_response_reason': null,
  'company': {'id': 12, 'brand_name': 'Test Company'},
  'partner': {'id': 7, 'name': 'Partner'},
  'accepted_by_institution': status == 'open'
      ? null
      : {'id': 8, 'name': 'Institution'},
  'created_at': '2026-10-05 10:00:00',
  if (myQuote != null) 'my_quote': myQuote,
  if (quotes != null) 'quotes': quotes,
};

void seedSettlementConfig() {
  app.configModel(
    ConfigModel.fromJson({
      'settlement_days': [
        {'value': 1, 'label': 'T+1'},
        {'value': 2, 'label': 'T+2'},
      ],
    }),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  test('only supported partner roles can access My Inquiries', () {
    for (final role in PartnerRole.values) {
      final access = AccessPolicy.check(
        AccessSnapshot(hasToken: true, validated: true, role: role),
        AccessScope.enquiries,
      );
      expect(
        access == AccessResult.allowed,
        [
          PartnerRole.wealthManager,
          PartnerRole.distributor,
          PartnerRole.retailer,
        ].contains(role),
      );
    }
  });

  test('inquiry states permit only the correct participant actions', () {
    final owner = PartnerUser.fromJson({'id': 7});
    final other = PartnerUser.fromJson({'id': 9});
    for (final status in [
      'open',
      'locked',
      'withdrawn',
      'rejected',
      'converted',
      'unknown',
    ]) {
      final item = EnquiryModel.fromJson(inquiry(status, side: 'sell'));
      expect(item.canWithdraw(owner), status == 'open');
      expect(item.canSellerRespond, status == 'open');
      expect(item.canAcceptOriginal, status == 'open');
      expect(item.canSendQuote, status == 'open');
      expect(item.canReplaceQuote, false);
      expect(item.canWithdrawQuote, false);
      expect(item.canPartnerRespond(owner), status == 'locked');
      expect(item.canAcceptCounterparty(owner), false);
      expect(item.canWithdraw(other), false);
      expect(item.canPartnerRespond(other), false);
      expect(item.canAcceptCounterparty(other), status == 'open');
      expect(item.typeLabel, 'Sell enquiry');
      expect(item.basePrice, 100);
      expect(item.sharePrice, 101);
      expect(item.companyLogo, isEmpty);
    }
    final withPendingQuote = EnquiryModel.fromJson(
      inquiry('open', side: 'sell', myQuote: quotePayload()),
    );
    expect(withPendingQuote.hasPendingQuote, true);
    expect(withPendingQuote.canAcceptOriginal, false);
    expect(withPendingQuote.canSendQuote, false);
    expect(withPendingQuote.canReplaceQuote, true);
    expect(withPendingQuote.canWithdrawQuote, true);
    final withQuotes = EnquiryModel.fromJson(
      inquiry(
        'open',
        quotes: [
          quotePayload(),
          quotePayload(uuid: 'quote-2', status: 'withdrawn'),
        ],
      ),
    );
    expect(withQuotes.actionableQuotes.map((q) => q.uuid), ['quote-1']);
    final withLogo = EnquiryModel.fromJson(
      inquiry('open', side: 'sell')
        ..['company'] = {
          'id': 12,
          'brand_name': 'Test Company',
          'logo': 'https://cdn.example.com/logo.png',
        },
    );
    expect(withLogo.companyLogo, 'https://cdn.example.com/logo.png');
    final inconsistent = inquiry('open')
      ..['accepted_by_institution'] = {'id': 8};
    expect(EnquiryModel.fromJson(inconsistent).canWithdraw(owner), false);
  });

  test('accept-counterparty excludes the raiser and their own desk', () {
    final open = EnquiryModel.fromJson(
      inquiry('open')
        ..['partner'] = {'id': 7, 'name': 'Raiser RM', 'parent_id': 3},
    );
    // The raiser's own Wealth Manager and the raiser's Relation Manager.
    expect(open.canAcceptCounterparty(PartnerUser.fromJson({'id': 3})), false);
    expect(
      EnquiryModel.fromJson(
        inquiry('open')..['partner'] = {'id': 3, 'name': 'WM'},
      ).canAcceptCounterparty(PartnerUser.fromJson({'id': 7, 'parent_id': 3})),
      false,
    );
    expect(open.canAcceptCounterparty(PartnerUser.fromJson({'id': 9})), true);
    // An explicit server decision wins over local checks.
    expect(
      EnquiryModel.fromJson(
        inquiry('open')..['can_accept_counterparty'] = false,
      ).canAcceptCounterparty(PartnerUser.fromJson({'id': 9})),
      false,
    );
    // Legacy lists without a partner id only contain the caller's enquiries.
    final legacy = EnquiryModel.fromJson(inquiry('open')..remove('partner'));
    expect(legacy.canWithdraw(PartnerUser.fromJson({'id': 9})), true);
    expect(
      legacy.canAcceptCounterparty(PartnerUser.fromJson({'id': 9})),
      false,
    );
  });

  test('accept-counterparty posts uuid and investor after KYC check', () async {
    await app.setUser(prefUser: identity('Wealth Manager', 9));
    final adapter = FakeAdapter(
      (request) async => request.method == 'GET'
          ? response({
              'status': 1,
              'data': [
                {'id': 22, 'preipo_kyc_status': 1},
              ],
            })
          : response({
              'status': 1,
              'message': 'Enquiry accepted.',
              'data': {
                'id': 490,
                'order_step': 'mandate_pending',
                'order_source': 'enquiry',
                'order_case': 'partner_to_partner',
              },
            }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final result = await EnquiryApi.acceptCounterparty(
      uuid: 'inquiry-1',
      investorId: 22,
    );
    expect(result.isSuccess, true);
    expect(result.r!.orderCase, 'partner_to_partner');
    expect(
      adapter.requests.last.path,
      '${EnquiryApi.partnerPath}/accept-counterparty',
    );
    expect(adapter.requests.last.data, {
      'uuid': 'inquiry-1',
      'investor_id': 22,
    });
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('another partner sees Accept on an open enquiry at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await app.setUser(prefUser: identity('Wealth Manager', 9));
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [inquiry('open', side: 'sell')],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: EnquiriesPage())),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('enquiry-accept-counterparty-inquiry-1')),
        findsOneWidget,
      );
      expect(find.text('Accept & buy'), findsOneWidget);
      expect(find.textContaining('Raised by Partner'), findsOneWidget);
      expect(find.text('Withdraw'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      await tester.tap(find.text('Accept & buy'));
      await tester.pumpAndSettle();
      expect(find.text('Accept enquiry'), findsOneWidget);
      expect(find.textContaining('on your side'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test(
    'create uses the new company inquiry payload without deal or expiry',
    () async {
      await app.setUser(prefUser: identity('Wealth Manager'));
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'message': 'Enquiry submitted successfully',
          'data': inquiry('open'),
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final result = await WPreIpoTransactionApi.inquiry(
        type: InvestmentTypeEnum.sell,
        companySlug: 'test-company',
        quantity: 10,
        offerPrice: 100,
        notes: 'A note',
        settlementDays: 2,
      );
      expect(result.isSuccess, true);
      expect(adapter.requests.single.path, EnquiryApi.partnerPath);
      expect(adapter.requests.single.data, {
        'deal_type': 'sell',
        'company_slug': 'test-company',
        'quantity': 10,
        'share_price': 100.0,
        'settlement_days': 2,
        'notes': 'A note',
      });
      final buy = await WPreIpoTransactionApi.inquiry(
        type: InvestmentTypeEnum.buy,
        companySlug: 'test-company',
        quantity: 5,
        offerPrice: 50,
        settlementDays: 1,
      );
      expect(buy.isSuccess, true);
      expect(adapter.requests.last.data, {
        'deal_type': 'buy',
        'company_slug': 'test-company',
        'quantity': 5,
        'share_price': 50.0,
        'settlement_days': 1,
      });
    },
  );

  test('partner rejects with required trimmed reason and accepts with investor only', () async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter(
      (request) async => request.method == 'GET'
          ? response({
              'status': 1,
              'data': [
                {'id': 22, 'preipo_kyc_status': 1},
              ],
            })
          : response({
              'status': 1,
              'message':
                  'Enquiry accepted. The sell mandate could not be sent.',
              'data': {
                'id': 481,
                'order_step': 'mandate_pending',
                'trade_side': 'sell',
                'order_source': 'enquiry',
                'mandate_sent': false,
              },
            }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    expect(
      (await EnquiryApi.respond(
        institution: false,
        uuid: 'inquiry-1',
        action: 'reject',
        reason: '  ',
      )).isSuccess,
      false,
    );
    expect(
      (await EnquiryApi.respond(
        institution: false,
        uuid: 'inquiry-1',
        action: 'reject',
        reason: 'x' * 1001,
      )).isSuccess,
      false,
    );
    expect(adapter.requests, isEmpty);
    await EnquiryApi.respond(
      institution: false,
      uuid: 'inquiry-1',
      action: 'reject',
      reason: ' Terms changed ',
    );
    expect(adapter.requests.last.data, {
      'uuid': 'inquiry-1',
      'reason': 'Terms changed',
    });
    expect(adapter.requests.last.path, '${EnquiryApi.partnerPath}/reject');
    final accepted = await EnquiryApi.accept(uuid: 'inquiry-1', investorId: 22);
    expect(adapter.requests.last.data, {
      'uuid': 'inquiry-1',
      'investor_id': 22,
    });
    expect(accepted.isSuccess, true);
    expect(accepted.r!.mandateSent, false);
    expect(accepted.r!.tradeSide, 'sell');
    expect(accepted.r!.orderSource, 'enquiry');
    await EnquiryApi.respond(
      institution: false,
      uuid: 'inquiry-1',
      action: 'withdraw',
    );
    expect(adapter.requests.last.path, '${EnquiryApi.partnerPath}/withdraw');
    expect(adapter.requests.last.data, {'uuid': 'inquiry-1'});
  });

  test(
    'institution rejection accepts no reason and no data response',
    () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async => response({'status': 1, 'message': 'Enquiry rejected.'}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final result = await EnquiryApi.respond(
        institution: true,
        uuid: 'inquiry-1',
        action: 'reject',
      );
      expect(result.isSuccess, true);
      expect(
        adapter.requests.single.path,
        '${EnquiryApi.institutionPath}/reject',
      );
      expect(adapter.requests.single.data, {
        'uuid': 'inquiry-1',
        'reason': null,
      });
    },
  );

  test('institution accept sends uuid only without settlement_days', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter(
      (_) async => response({'status': 1, 'message': 'Enquiry accepted.'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final result = await EnquiryApi.respond(
      institution: true,
      uuid: 'inquiry-1',
      action: 'accept',
    );
    expect(result.isSuccess, true);
    expect(
      adapter.requests.single.path,
      '${EnquiryApi.institutionPath}/accept',
    );
    expect(adapter.requests.single.data, {'uuid': 'inquiry-1'});
  });

  test('institution quote send replace and withdraw payloads', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter(
      (_) async => response({'status': 1, 'message': 'Quote saved.'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final sent = await EnquiryApi.sendQuote(
      uuid: 'inquiry-1',
      quantity: 12,
      sharePrice: 110,
      settlementDays: 2,
    );
    expect(sent.isSuccess, true);
    expect(adapter.requests.last.path, '${EnquiryApi.institutionPath}/quote');
    expect(adapter.requests.last.data, {
      'uuid': 'inquiry-1',
      'quantity': 12,
      'share_price': 110.0,
      'settlement_days': 2,
    });
    final withdrawn = await EnquiryApi.withdrawQuote(uuid: 'inquiry-1');
    expect(withdrawn.isSuccess, true);
    expect(
      adapter.requests.last.path,
      '${EnquiryApi.institutionPath}/quote/withdraw',
    );
    expect(adapter.requests.last.data, {'uuid': 'inquiry-1'});
  });

  test('partner quote accept posts quote_uuid after KYC check', () async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter(
      (request) async => request.method == 'GET'
          ? response({
              'status': 1,
              'data': [
                {'id': 22, 'preipo_kyc_status': 1},
              ],
            })
          : response({
              'status': 1,
              'message': 'Quote accepted.',
              'data': {
                'id': 501,
                'order_step': 'mandate_pending',
                'trade_side': 'buy',
                'order_source': 'enquiry',
              },
            }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final result = await EnquiryApi.acceptQuote(
      uuid: 'inquiry-1',
      quoteUuid: 'quote-1',
      investorId: 22,
    );
    expect(result.isSuccess, true);
    expect(
      adapter.requests.last.path,
      '${EnquiryApi.partnerPath}/quotes/accept',
    );
    expect(adapter.requests.last.data, {
      'uuid': 'inquiry-1',
      'quote_uuid': 'quote-1',
      'investor_id': 22,
    });
  });

  test(
    'institution keeps pending mandates and filters out legacy orders',
    () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [
            {'id': 1, 'order_step': 'mandate_pending', 'status': 0},
            {'id': 2, 'order_step': 'share_confirmation_pending', 'status': 0},
            {'id': 3, 'order_step': 'payment_pending', 'status': 0},
            {'id': 4, 'order_step': 'completed', 'status': 0},
            {'id': 5, 'order_step': 'cancelled', 'status': 0},
            {'id': 6, 'status': 1},
          ],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final controller = PreIPOTransactionPageCtrl();
      await controller.fetch();
      expect(adapter.requests.single.queryParameters, isEmpty);
      expect(controller.transactions.map((order) => order.id), [1, 2, 3, 4, 5]);
      expect(controller.filter.value, PreIPOTransactionFilter.all);
      expect(controller.filtered.map((order) => order.id), [1, 2, 3, 4, 5]);
      controller.selectFilter(PreIPOTransactionFilter.pending);
      expect(controller.filtered.map((order) => order.id), [1, 2]);
      controller.selectFilter(PreIPOTransactionFilter.processing);
      expect(controller.filtered.single.id, 3);
      controller.selectFilter(PreIPOTransactionFilter.completed);
      expect(controller.filtered.single.id, 4);
      controller.selectFilter(PreIPOTransactionFilter.cancelled);
      expect(controller.filtered.single.id, 5);
      expect(adapter.requests.length, 1);
    },
  );

  test('sell transaction actions use participant-specific routes', () async {
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': {
          'id': 481,
          'trade_side': 'sell',
          'order_step': 'share_transfer_pending',
        },
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    await app.setUser(prefUser: identity('Wealth Manager'));
    await WPreIpoTransactionApi.confirmPayment(transactionId: 481);
    expect(
      adapter.requests.last.path,
      'v2/business/pre-ipo/transaction/confirm-payment',
    );
    final file = MediaModel(
      name: 'receipt.pdf',
      dataType: FileDataType.bytes,
      uint8list: Uint8List.fromList([1, 2, 3]),
    );
    await WPreIpoTransactionApi.uploadShareTransferReceipt(
      transactionId: 481,
      file: file,
    );
    expect(
      adapter.requests.last.path,
      'v2/business/pre-ipo/transaction/share-transfer-receipt',
    );
    expect(
      Map.fromEntries(
        (adapter.requests.last.data as FormData).fields,
      )['transaction_id'],
      '481',
    );
    await app.setUser(prefUser: identity());
    await PreIPOTransactionApi.uploadPaymentReceipt(
      transactionId: 481,
      file: file,
    );
    expect(
      adapter.requests.last.path,
      'v2/business/institution/pre-ipo/transaction/payment-receipt',
    );
    expect(
      (adapter.requests.last.data as FormData).files.single.value.filename,
      'receipt.pdf',
    );
  });

  for (final institution in [false, true]) {
    for (final width in [390.0, 1280.0]) {
      testWidgets(
        'inquiry types combine with search and status for institution=$institution at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await app.setUser(
            prefUser: institution ? identity() : identity('Wealth Manager'),
          );
          final adapter = FakeAdapter(
            (_) async => response({
              'status': 1,
              'data': [
                inquiry('open')..['company'] = {'brand_name': 'Alpha Buy'},
                inquiry('locked', side: 'sell')
                  ..['company'] = {'brand_name': 'Alpha Sell'},
                inquiry('open', side: 'sell')
                  ..['company'] = {'brand_name': 'Beta Sell'},
                inquiry('open', side: 'unknown')
                  ..['company'] = {'brand_name': 'Other Company'},
              ],
            }),
          );
          dioConfig.dio.httpClientAdapter = adapter;
          await tester.pumpWidget(
            GetMaterialApp(
              theme: width < 600 ? ThemeData.dark() : ThemeData.light(),
              home: Scaffold(body: EnquiriesPage(institution: institution)),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('All (4)'), findsOneWidget);
          expect(find.text('Buy (1)'), findsOneWidget);
          expect(find.text('Sell (2)'), findsOneWidget);

          await tester.tap(find.byKey(const ValueKey('inquiry-type-buy')));
          await tester.pumpAndSettle();
          expect(find.text('Buy enquiry'), findsOneWidget);
          expect(find.text('Sell enquiry'), findsNothing);
          expect(find.text('Alpha Buy'), findsOneWidget);
          expect(find.text('All statuses (1)'), findsOneWidget);

          await tester.tap(find.byKey(const ValueKey('inquiry-type-sell')));
          await tester.pumpAndSettle();
          expect(find.text('Buy enquiry'), findsNothing);
          expect(find.text('All statuses (2)'), findsOneWidget);
          await tester.tap(find.widgetWithText(ChoiceChip, 'Open (1)'));
          await tester.pumpAndSettle();
          expect(find.text('Beta Sell'), findsOneWidget);
          expect(find.text('Alpha Sell'), findsNothing);

          await tester.enterText(find.byType(TextField), 'Alpha');
          await tester.pumpAndSettle();
          expect(find.text('No enquiries found'), findsOneWidget);
          expect(find.text('Sell (1)'), findsOneWidget);
          await tester.tap(
            find.widgetWithText(ChoiceChip, 'Awaiting decision (1)'),
          );
          await tester.pumpAndSettle();
          expect(find.text('Alpha Sell'), findsOneWidget);
          expect(find.text('Sell enquiry'), findsOneWidget);

          await tester.tap(find.byTooltip('Refresh enquiries'));
          await tester.pumpAndSettle();
          expect(find.text('Alpha Sell'), findsOneWidget);
          expect(
            tester
                .widget<ChoiceChip>(
                  find.byKey(const ValueKey('inquiry-type-sell')),
                )
                .selected,
            isTrue,
          );
          await tester.tap(find.byKey(const ValueKey('inquiry-type-all')));
          await tester.enterText(find.byType(TextField), 'Other');
          await tester.pumpAndSettle();
          await tester.tap(find.widgetWithText(ChoiceChip, 'All statuses (1)'));
          await tester.pumpAndSettle();
          expect(find.text('Other Company'), findsOneWidget);
          expect(find.text('Enquiry'), findsOneWidget);
          expect(tester.takeException(), isNull);
          expect(adapter.requests.length, 2);
        },
      );
    }
  }

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'seller can reject without a reason and row disappears at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await app.setUser(prefUser: identity());
        bool rejected = false;
        final adapter = FakeAdapter((request) async {
          if (request.method == 'POST') {
            rejected = true;
            return response({'status': 1, 'message': 'Enquiry rejected.'});
          }
          return response({
            'status': 1,
            'data': rejected ? [] : [inquiry('open', side: 'sell')],
          });
        });
        dioConfig.dio.httpClientAdapter = adapter;
        await tester.pumpWidget(
          const GetMaterialApp(
            home: Scaffold(body: EnquiriesPage(institution: true)),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sell enquiry'), findsOneWidget);
        expect(find.text('Modify'), findsNothing);
        await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
        await tester.pumpAndSettle();
        expect(find.text('No enquiries found'), findsOneWidget);
        expect(adapter.requests.where((r) => r.method == 'POST').single.data, {
          'uuid': 'inquiry-1',
          'reason': null,
        });
        await tester.tap(find.byTooltip('Dismiss notification'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('partner cannot submit empty rejection reason', (tester) async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [inquiry('locked')],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: EnquiriesPage())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Withdraw'), findsNothing);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a rejection reason'), findsOneWidget);
    expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'racing seller approval refreshes stale actions and shows API message',
    (tester) async {
      await app.setUser(prefUser: identity());
      bool stale = false;
      final adapter = FakeAdapter((request) async {
        if (request.method == 'POST') {
          stale = true;
          return response({
            'status': 0,
            'message': 'This enquiry is no longer open.',
          });
        }
        return response({
          'status': 1,
          'data': stale ? [] : [inquiry('open')],
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(body: EnquiriesPage(institution: true)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(EnquiryDecisionDialog),
          matching: find.widgetWithText(FilledButton, 'Approve'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('This enquiry is no longer open.'), findsOneWidget);
      expect(find.text('No enquiries found'), findsOneWidget);
      expect(adapter.requests.where((r) => r.method == 'POST').length, 1);
      expect(adapter.requests.where((r) => r.method == 'POST').single.data, {
        'uuid': 'inquiry-1',
      });
      await tester.tap(find.byTooltip('Dismiss notification'));
      await tester.pumpAndSettle();
    },
  );

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'institution pending quote blocks approve and offers replace at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await app.setUser(prefUser: identity());
        seedSettlementConfig();
        final adapter = FakeAdapter(
          (_) async => response({
            'status': 1,
            'data': [
              inquiry('open', myQuote: quotePayload()),
            ],
          }),
        );
        dioConfig.dio.httpClientAdapter = adapter;
        await tester.pumpWidget(
          const GetMaterialApp(
            home: Scaffold(body: EnquiriesPage(institution: true)),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Your quote'), findsOneWidget);
        expect(find.text('Send quote'), findsNothing);
        expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
        expect(find.text('Replace quote'), findsOneWidget);
        expect(find.text('Withdraw quote'), findsOneWidget);
        expect(find.text('Transaction price ₹111.10'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'partner open enquiry shows quotes and accept action at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await app.setUser(prefUser: identity('Wealth Manager'));
        final adapter = FakeAdapter(
          (_) async => response({
            'status': 1,
            'data': [
              inquiry(
                'open',
                quotes: [
                  quotePayload(),
                  quotePayload(
                    uuid: 'quote-2',
                    status: 'withdrawn',
                    institutionName: 'Other Desk',
                  ),
                ],
              ),
            ],
          }),
        );
        dioConfig.dio.httpClientAdapter = adapter;
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: EnquiriesPage())),
        );
        await tester.pumpAndSettle();
        expect(find.text('Institution'), findsOneWidget);
        expect(find.text('Other Desk'), findsOneWidget);
        expect(find.text('Accept quote'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('enquiry-accept-quote-quote-1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('enquiry-accept-quote-quote-2')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'partner selects investor and gets transaction even when mandate delivery fails',
    (tester) async {
      await app.setUser(prefUser: identity('Wealth Manager'));
      bool converted = false;
      final adapter = FakeAdapter((request) async {
        if (request.path == 'v2/business/pre-ipo/transaction/detail') {
          return response({
            'status': 1,
            'data': {
              'id': 481,
              'transaction_invoice_no': 'TX-481',
              'order_step': 'mandate_pending',
              'trade_side': 'buy',
              'order_source': 'enquiry',
              'current_step': 'Transaction initiated. Buy mandate generated.',
              'next_step': 'Ask the investor to sign the mandate.',
            },
          });
        }
        if (request.path == 'v2/business/pre-ipo/transaction-list') {
          return response({'status': 1, 'data': []});
        }
        if (request.path == 'v2/business/investor') {
          return response({
            'status': 1,
            'data': [
              {'id': 22, 'name': 'Alex', 'preipo_kyc_status': 1},
            ],
          });
        }
        if (request.method == 'POST') {
          converted = true;
          return response({
            'status': 1,
            'message': 'Enquiry accepted. The buy mandate could not be sent.',
            'data': {
              'id': 481,
              'transaction_invoice_no': 'TX-481',
              'order_step': 'mandate_pending',
              'trade_side': 'buy',
              'order_source': 'enquiry',
              'mandate_sent': false,
            },
          });
        }
        return response({
          'status': 1,
          'data': [inquiry(converted ? 'converted' : 'locked')],
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: EnquiriesPage())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
      await tester.pumpAndSettle();
      final confirm = find.descendant(
        of: find.byType(EnquiryDecisionDialog),
        matching: find.widgetWithText(FilledButton, 'Approve'),
      );
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
      await tester.tap(find.text('Alex').last);
      await tester.pumpAndSettle();
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Transaction created'), findsOneWidget);
      expect(find.textContaining('TX-481'), findsOneWidget);
      expect(
        find.textContaining('The buy mandate could not be sent.'),
        findsWidgets,
      );
      expect(find.text('Converted to transaction'), findsOneWidget);
      expect(adapter.requests.where((r) => r.method == 'POST').single.data, {
        'uuid': 'inquiry-1',
        'investor_id': 22,
      });
      await tester.tap(find.widgetWithText(FilledButton, 'View transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Transaction details'), findsOneWidget);
      expect(
        find.text('Transaction initiated. Buy mandate generated.'),
        findsWidgets,
      );
      expect(adapter.requests.where((r) => r.method == 'POST').length, 1);
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('sell inquiry disables investors without completed KYC', (
    tester,
  ) async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    bool converted = false;
    final adapter = FakeAdapter((request) async {
      if (request.path == 'v2/business/investor') {
        return response({
          'status': 1,
          'data': [
            {'id': 22, 'name': 'Alex', 'preipo_kyc_status': 0},
            {'id': 23, 'name': 'Blake', 'preipo_kyc_status': 1},
          ],
        });
      }
      if (request.method == 'POST') {
        converted = true;
        return response({
          'status': 1,
          'message': 'Enquiry accepted.',
          'data': {
            'id': 482,
            'transaction_invoice_no': 'TX-482',
            'order_step': 'mandate_pending',
            'trade_side': 'sell',
            'order_source': 'enquiry',
          },
        });
      }
      return response({
        'status': 1,
        'data': [inquiry(converted ? 'converted' : 'locked', side: 'sell')],
      });
    });
    dioConfig.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: EnquiriesPage())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pumpAndSettle();
    final confirm = find.descendant(
      of: find.byType(EnquiryDecisionDialog),
      matching: find.widgetWithText(FilledButton, 'Approve'),
    );
    final disabledItem = tester.widget<InvestorSelectionCard>(
      find.byKey(const ValueKey('investor-option-22')),
    );
    expect(disabledItem.onSelect, isNull);
    expect(find.text('Complete KYC'), findsOneWidget);
    final enabledItem = tester.widget<InvestorSelectionCard>(
      find.byKey(const ValueKey('investor-option-23')),
    );
    expect(enabledItem.onSelect, isNotNull);
    await tester.ensureVisible(find.text('Blake'));
    await tester.tap(find.text('Blake').last);
    await tester.pumpAndSettle();
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(adapter.requests.where((r) => r.method == 'POST').single.data, {
      'uuid': 'inquiry-1',
      'investor_id': 23,
    });
    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
