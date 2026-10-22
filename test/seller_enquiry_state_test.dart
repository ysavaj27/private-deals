import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_model.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_quote_dialog.dart';
import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'enquiry_flow_test.dart'
    show inquiry, quotePayload, seedSettlementConfig;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

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

  test('only the enquiry owner can accept a pending quote on open terms', () {
    final owner = PartnerUser.fromJson(identity());
    final other = PartnerUser.fromJson(identity('Institution', 9));
    final quote = EnquiryQuote.fromJson(quotePayload());
    for (final status in [
      'open',
      'locked',
      'converted',
      'rejected',
      'withdrawn',
    ]) {
      final item = EnquiryModel.fromJson(
        inquiry(status, quotes: [quotePayload()]),
      );
      expect(item.canAcceptQuote(owner, quote), status == 'open');
      expect(item.canAcceptQuote(other, quote), false);
      expect(item.canAcceptQuote(PartnerUser.fromJson({}), quote), false);
    }
    final open = EnquiryModel.fromJson(
      inquiry('open', quotes: [quotePayload()]),
    );
    expect(
      open.canAcceptQuote(
        owner,
        EnquiryQuote.fromJson(quotePayload(uuid: 'unrelated-quote')),
      ),
      false,
    );
    expect(
      open.canAcceptQuote(
        owner,
        EnquiryQuote.fromJson(quotePayload(status: 'withdrawn')),
      ),
      false,
    );
  });

  test('malformed and already locked enquiries expose no open actions', () {
    final me = PartnerUser.fromJson(identity());
    final other = PartnerUser.fromJson(identity('Institution', 9));
    final quote = EnquiryQuote.fromJson(quotePayload());
    for (final payload in [
      inquiry('open', quotes: [quotePayload()])..['uuid'] = '  ',
      inquiry('open', quotes: [quotePayload()])..['deal_type'] = 'unknown',
      inquiry('open', quotes: [quotePayload()])
        ..['accepted_by_institution'] = {'id': 8},
    ]) {
      final item = EnquiryModel.fromJson(payload);
      expect(item.canSellerRespond, false);
      expect(item.canAcceptOriginal, false);
      expect(item.canSendQuote, false);
      expect(item.canWithdraw(me), false);
      expect(item.canAcceptCounterparty(other), false);
      expect(item.canAcceptQuote(me, quote), false);
      expect(item.actionableQuotes, isEmpty);
    }
    final locked = EnquiryModel.fromJson(
      inquiry('locked')..['deal_type'] = 'unknown',
    );
    expect(locked.canPartnerRespond(me), false);
    final normalized = EnquiryModel.fromJson(
      inquiry('open', side: ' SELL ')
        ..['enquiry_status'] = ' OPEN '
        ..['uuid'] = ' inquiry-1 ',
    );
    expect(normalized.canWithdraw(me), true);
    expect(normalized.typeLabel, 'Sell enquiry');
    expect(normalized.uuid, 'inquiry-1');
  });

  test(
    'relation managers on the same parent desk cannot cross their orders',
    () {
      final item = EnquiryModel.fromJson(
        inquiry('open')..['partner'] = {'id': 7, 'parent_id': 3},
      );
      final sibling = PartnerUser.fromJson({'id': 8, 'parent_id': 3});
      expect(item.isSameDesk(sibling), true);
      expect(item.canAcceptCounterparty(sibling), false);
      expect(
        item.canAcceptCounterparty(
          PartnerUser.fromJson({'id': 8, 'parent_id': 4}),
        ),
        true,
      );
      expect(item.canAcceptCounterparty(PartnerUser.fromJson({})), false);
      // An explicit server capability is authoritative for a different owner.
      final allowed = EnquiryModel.fromJson(
        inquiry('open')
          ..['partner'] = {'id': 7, 'parent_id': 3}
          ..['can_accept_counterparty'] = true,
      );
      expect(allowed.canAcceptCounterparty(sibling), true);
    },
  );

  test(
    'blank identifiers and unsupported actions never reach the API',
    () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async => response({'status': 1, 'message': 'Unexpected request'}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final results = [
        await EnquiryApi.respond(
          institution: false,
          uuid: ' ',
          action: 'withdraw',
        ),
        await EnquiryApi.respond(
          institution: false,
          uuid: 'inquiry-1',
          action: 'accept',
        ),
        await EnquiryApi.respond(
          institution: true,
          uuid: 'inquiry-1',
          action: 'withdraw',
        ),
        await EnquiryApi.sendQuote(
          uuid: ' ',
          quantity: 1,
          sharePrice: 1,
          settlementDays: 1,
        ),
        await EnquiryApi.withdrawQuote(uuid: '\n'),
        await EnquiryApi.accept(uuid: ' ', investorId: 70),
        await EnquiryApi.acceptCounterparty(uuid: ' ', investorId: 70),
        await EnquiryApi.acceptQuote(
          uuid: 'inquiry-1',
          quoteUuid: ' ',
          investorId: 70,
        ),
      ];
      expect(results.every((item) => !item.isSuccess), true);
      expect(adapter.requests, isEmpty);
    },
  );

  test('invalid quote terms cannot be posted', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter(
      (_) async => response({'status': 1, 'message': 'Unexpected request'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    for (final terms in [
      (quantity: 0, price: 100.0, days: 1),
      (quantity: -1, price: 100.0, days: 1),
      (quantity: 1, price: 0.0, days: 1),
      (quantity: 1, price: double.nan, days: 1),
      (quantity: 1, price: double.infinity, days: 1),
      (quantity: 1, price: 100.0, days: 0),
      (quantity: 1, price: 100.0, days: 31),
    ]) {
      final result = await EnquiryApi.sendQuote(
        uuid: 'inquiry-1',
        quantity: terms.quantity,
        sharePrice: terms.price,
        settlementDays: terms.days,
      );
      expect(result.isSuccess, false);
    }
    expect(adapter.requests, isEmpty);
  });

  for (final action in ['accept', 'accept-counterparty', 'quotes/accept']) {
    Future<BaseModel<PreIpoOrderModel>> accept(int investorId) =>
        switch (action) {
          'accept' => EnquiryApi.accept(
            uuid: ' inquiry-1 ',
            investorId: investorId,
          ),
          'accept-counterparty' => EnquiryApi.acceptCounterparty(
            uuid: ' inquiry-1 ',
            investorId: investorId,
          ),
          _ => EnquiryApi.acceptQuote(
            uuid: ' inquiry-1 ',
            quoteUuid: ' quote-1 ',
            investorId: investorId,
          ),
        };

    test('Institution $action rechecks own and client investor KYC', () async {
      await app.setUser(prefUser: identity());
      var kyc = true;
      final adapter = FakeAdapter((request) async {
        if (request.method == 'GET') {
          return response({
            'status': 1,
            'data': [
              {'id': 70, 'is_self': 1, 'preipo_kyc_status': kyc ? 1 : 0},
              {'id': 22, 'is_self': 0, 'preipo_kyc_status': kyc ? 1 : 0},
            ],
          });
        }
        return response({
          'status': 1,
          'data': {'id': 481, 'order_step': 'mandate_pending'},
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      for (final id in [70, 22]) {
        expect((await accept(id)).isSuccess, true);
        expect(adapter.requests.last.path, '${EnquiryApi.partnerPath}/$action');
        expect(adapter.requests.last.data, {
          'uuid': 'inquiry-1',
          if (action == 'quotes/accept') 'quote_uuid': 'quote-1',
          'investor_id': id,
        });
      }
      final writes = adapter.requests.where((r) => r.method == 'POST').length;
      kyc = false;
      expect((await accept(70)).isSuccess, false);
      expect((await accept(22)).isSuccess, false);
      expect((await accept(999)).isSuccess, false);
      expect(adapter.requests.where((r) => r.method == 'POST').length, writes);
    });

    test('Institution $action blocks on a failed KYC lookup', () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async =>
            response({'status': 0, 'message': 'Temporarily unavailable'}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final result = await accept(70);
      expect(result.isSuccess, false);
      expect(result.m, contains('Unable to verify investor KYC'));
      expect(adapter.requests.single.method, 'GET');
    });
  }

  testWidgets('seller approval includes self and client accounts with KYC', (
    tester,
  ) async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [
          {
            'id': 70,
            'is_self': 1,
            'name': 'Own Account',
            'preipo_kyc_status': 1,
          },
          {
            'id': 22,
            'is_self': 0,
            'name': 'Ready Client',
            'preipo_kyc_status': 1,
          },
          {
            'id': 23,
            'is_self': 0,
            'name': 'Pending Client',
            'preipo_kyc_status': 0,
          },
        ],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: EnquiryDecisionDialog(
            action: 'accept',
            institution: false,
            companyName: 'Company',
            sell: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('My account'), findsOneWidget);
    for (final id in [70, 22, 23]) {
      final card = tester.widget<InvestorSelectionCard>(
        find.byKey(ValueKey('investor-option-$id')),
      );
      expect(card.onSelect != null, id != 23);
    }
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'))
          .onPressed,
      isNull,
    );
    final self = tester.widget<InvestorSelectionCard>(
      find.byKey(const ValueKey('investor-option-70')),
    );
    self.onSelect!();
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'))
          .onPressed,
      isNotNull,
    );
    expect(adapter.requests.single.path, 'v2/business/investor');
    expect(tester.takeException(), isNull);
  });

  for (final institution in [false, true]) {
    testWidgets('overlong rejection stays editable for inbox=$institution', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: EnquiryDecisionDialog(
              action: 'reject',
              institution: institution,
              companyName: 'Company',
            ),
          ),
        ),
      );
      // The field counts graphemes, but the request limit counts code units.
      // Validate the request limit before dismissing and losing the draft.
      final reason = '📝' * 501;
      await tester.enterText(find.byType(TextFormField), reason);
      await tester.tap(find.widgetWithText(FilledButton, 'Reject'));
      await tester.pumpAndSettle();
      expect(
        find.text('Use a rejection reason of up to 1000 characters'),
        findsOneWidget,
      );
      expect(find.byType(EnquiryDecisionDialog), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        reason,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final replace in [false, true]) {
    testWidgets(
      'quote dialog preserves invalid terms before replace=$replace',
      (tester) async {
        seedSettlementConfig();
        EnquiryQuoteDraft? result;
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showDialog<EnquiryQuoteDraft>(
                      context: context,
                      builder: (_) => EnquiryQuoteDialog(
                        companyName: 'Company',
                        replace: replace,
                        enquiry: EnquiryModel.fromJson(inquiry('open')),
                        existing: replace
                            ? EnquiryQuote.fromJson(quotePayload())
                            : null,
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final fields = find.byType(TextFormField);
        expect(
          tester.widget<TextFormField>(fields.at(0)).controller!.text,
          replace ? '12' : '10',
        );
        expect(
          tester.widget<TextFormField>(fields.at(1)).controller!.text,
          replace ? '110' : '100',
        );
        await tester.enterText(fields.at(0), '0');
        await tester.enterText(fields.at(1), 'NaN');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(find.text('Quantity must be at least 1'), findsOneWidget);
        expect(find.text('Offer price must be greater than 0'), findsOneWidget);
        await tester.enterText(fields.at(0), '15');
        await tester.enterText(fields.at(1), '120.50');
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(result!.quantity, 15);
        expect(result!.sharePrice, 120.5);
        expect(result!.settlementDays, replace ? 2 : 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
