import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_pre_ipo_transaction_api.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;
import 'support/recording_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecordingAnalytics client;
  late HttpClientAdapter previousAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    client = RecordingAnalytics();
    await Analytics.init(client: client);
    previousAdapter = dioConfig.dio.httpClientAdapter;
  });
  tearDown(() async {
    await app.clear();
    await client.drain();
    dioConfig.dio.httpClientAdapter = previousAdapter;
    Get.reset();
  });

  for (final status in [0, 1]) {
    test(
      'seller deal and quote outcomes record success=$status once each',
      () async {
        await app.setUser(prefUser: identity());
        dioConfig.dio.httpClientAdapter = FakeAdapter(
          (_) async => response({
            'status': status,
            'data': {},
            'message': 'Server message excluded from analytics',
          }),
        );
        final results = [
          await DealApi.createDeal({
            'company_id': 12,
            'deal_type': 'sell',
            'is_hot_deal': 1,
          }),
          await DealApi.updateDeal({
            'uuid': 'private-deal',
            'deal_type': 'buy',
          }),
          await DealApi.deleteDeal('private-deal'),
          await DealApi.bulkDeals({
            'sell': [
              {'company_id': 12},
            ],
            'buy': [],
          }),
          await EnquiryApi.respond(
            institution: true,
            uuid: 'private-enquiry',
            action: 'reject',
            reason: 'Private reason',
          ),
          await EnquiryApi.sendQuote(
            uuid: 'private-enquiry',
            quantity: 10,
            sharePrice: 100,
            settlementDays: 2,
          ),
          await EnquiryApi.withdrawQuote(uuid: 'private-enquiry'),
        ];
        await client.drain();
        expect(
          results.every((result) => result.isSuccess == (status == 1)),
          true,
        );
        expect(client.events.map((e) => e.name), [
          'deal_create',
          'deal_update',
          'deal_delete',
          'share_price_update',
          'enquiry_response',
          'enquiry_quote_submit',
          'enquiry_quote_withdraw',
        ]);
        for (final event in client.events) {
          expect(event.parameters['success'], status);
          expect(event.parameters['partner_role'], 'Institution');
          expect(event.userId, '7');
          expect(
            event.parameters.toString().toLowerCase(),
            isNot(contains('private')),
          );
        }
        expect(client.events[3].parameters['company_count'], 1);
        expect(client.events[3].parameters['deal_side'], 'sell');
      },
    );
  }

  test('wealth-manager enquiry and both transaction flows retain actor and outcome', () async {
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'status': 1, 'data': {}}),
    );
    await app.setUser(prefUser: identity('Wealth Manager', 9));
    await EnquiryApi.respond(
      institution: false,
      uuid: 'enquiry',
      action: 'withdraw',
    );
    await WPreIpoTransactionApi.confirmPayment(transactionId: 101);
    await app.setUser(prefUser: identity());
    await PreIPOTransactionApi.approve(transactionId: 101);
    await PreIPOTransactionApi.confirmShareTransfer(transactionId: 101);
    await client.drain();
    expect(client.events.map((e) => e.name), [
      'enquiry_response',
      'transaction_action',
      'transaction_action',
      'transaction_action',
    ]);
    expect(client.events.map((e) => e.userId), ['9', '9', '7', '7']);
    expect(client.events.map((e) => e.parameters['action']), [
      'withdraw',
      'confirm_payment',
      'approve',
      'confirm_share_transfer',
    ]);
    expect(client.events.map((e) => e.parameters['actor']), [
      'partner',
      'partner',
      'institution',
      'institution',
    ]);
  });

  test(
    'transport failure is recorded once without exposing error content',
    () async {
      await app.setUser(prefUser: identity());
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async =>
            response({'status': 0, 'message': 'private@example.com'}, 500),
      );
      final result = await EnquiryApi.sendQuote(
        uuid: 'enquiry',
        quantity: 1,
        sharePrice: 100,
        settlementDays: 2,
      );
      await client.drain();
      expect(result.isSuccess, false);
      expect(client.events.single.parameters['success'], 0);
      expect(
        client.events.single.parameters.toString(),
        isNot(contains('private@example.com')),
      );
    },
  );

  test(
    'an outstanding seller request cannot emit after switching accounts',
    () async {
      await app.setUser(prefUser: identity());
      final pending = Completer<BaseModel<int>>();
      final work = Analytics.trackRequest(
        'deal_create',
        request: () => pending.future,
      );
      await app.clear();
      await app.setUser(prefUser: identity('Wealth Manager', 9));
      pending.complete(BaseModel(s: 1));
      await work;
      await client.drain();
      expect(client.events, isEmpty);
    },
  );
}
