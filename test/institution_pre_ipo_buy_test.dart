import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/investor_draft_lifecycle.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _Drafts extends GetxController with InvestorDraftLifecycle {}

DealModel deal({int sellerId = 8, String sellerUuid = ''}) =>
    DealModel.fromJson({
      'id': 31,
      'uuid': 'deal-31',
      'deal_type': 'sell',
      'share_price': 120,
      'minimum_qty': 10,
      'status': 'available',
      'seller': {'id': sellerId, 'uuid': sellerUuid, 'company_name': 'Seller'},
    });

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

  test('an Institution cannot buy its own deal', () async {
    await app.setUser(prefUser: identity('Institution', 8));
    final own = PreIPOOffer.fromDeal(deal());
    expect(own.isOwnDeal, true);
    expect(own.canBuy, false);
    expect(own.buyBlockedReason, contains('your own deal'));

    final other = PreIPOOffer.fromDeal(deal(sellerId: 9));
    expect(other.isOwnDeal, false);
    expect(other.canBuy, true);
    expect(other.buyBlockedReason, isNull);

    final me = PartnerUser.fromJson({'id': 8, 'uuid': 'inst-a'});
    expect(
      PreIPOOffer.fromDeal(deal(sellerUuid: 'inst-a')).isOwnDealFor(me),
      true,
    );
    expect(
      PreIPOOffer.fromDeal(deal(sellerUuid: 'inst-b')).isOwnDealFor(me),
      false,
    );
  });

  test('an Institution buys with its self investor only', () async {
    await app.setUser(prefUser: identity('Institution', 8));
    final drafts = _Drafts();
    expect(drafts.buysAsSelf, true);
    expect(drafts.seedSelfInvestor(120), true);
    expect(drafts.investorList.single.investorId, 70);
    expect(drafts.investorList.single.isSelf, true);
    expect(drafts.investorList.single.priceCTRL!.text, '120.0');
    final seeded = drafts.investorList.single;
    expect(drafts.seedSelfInvestor(120), true);
    expect(drafts.investorList.single, same(seeded));
    expect(drafts.seedSelfInvestor(150), true);
    expect(drafts.investorList.single.price(), 150);

    await app.setUser(prefUser: identity('Wealth Manager'));
    expect(_Drafts().buysAsSelf, false);
  });

  testWidgets('an Institution without a self investor is told and blocked', (
    tester,
  ) async {
    await app.setUser(
      prefUser: {...identity('Institution', 8), 'self_investor_id': null},
    );
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final missing = _Drafts();
    expect(missing.seedSelfInvestor(120), false);
    expect(missing.investorList, isEmpty);
    await tester.pump();
    expect(find.textContaining('self investor is not set up'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  test(
    'Institution confirm-share-transfer uses the institution route',
    () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'message': 'Shares confirmed.',
          'data': {'id': 481, 'order_step': 'completed'},
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final res = await PreIPOTransactionApi.confirmShareTransfer(
        transactionId: 481,
      );
      expect(res.isSuccess, true);
      expect(res.r!.isCompleted, true);
      expect(
        adapter.requests.single.path,
        'v2/business/institution/pre-ipo/transaction/confirm-share-transfer',
      );
      expect(adapter.requests.single.data, {'transaction_id': 481});
    },
  );
}
