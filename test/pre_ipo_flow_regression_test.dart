import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/desktop_pre_ipo_buy_transaction_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/phone_pre_ipo_investment_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _Checkout extends PreIPOInvestmentPageCtrl {
  @override
  void getData() {}
  @override
  void onReady() {}
}

Map<String, dynamic> orderJson(
  String kind, {
  String step = 'mandate_pending',
}) => {
  'id': 481,
  'order_case': kind,
  'order_step': step,
  'order_source': kind == 'partner_to_partner' ? 'enquiry' : 'direct',
  'buyer': {
    'name': 'Buyer',
    'partner': {'id': 7},
    'side': 'buy',
  },
  'seller': {
    'name': 'Seller',
    'partner': {'id': 8},
    'side': 'sell',
  },
  'investor': {'id': 70, 'name': 'Own investor', 'is_self': 1},
  'company': {'brand_name': 'Test Company'},
  'shares': 10,
  'share_price': 120,
  'payable_amount': 1200,
  'sign_link': 'https://example.test/mandate',
  'action': ['show_mandate_sign_link'],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpClientAdapter previousAdapter;
  const launcherChannel = MethodChannel('plugins.flutter.io/url_launcher');
  final launchedUrls = <String>[];
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    previousAdapter = dioConfig.dio.httpClientAdapter;
    launchedUrls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, (call) async {
          if (call.method == 'launch') {
            launchedUrls.add(call.arguments['url'] as String);
          }
          return true;
        });
    await app.setUser(prefUser: identity('Institution'));
  });
  tearDown(() async {
    dioConfig.dio.httpClientAdapter = previousAdapter;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(launcherChannel, null);
    await app.clear();
    Get.reset();
  });

  for (final kind in [
    'partner_buys',
    'institution_buys',
    'partner_to_partner',
    'institution_to_institution',
  ]) {
    test(
      '$kind preserves buyer and seller ownership of settlement actions',
      () {
        final order = PreIpoOrderModel.fromJson({
          ...orderJson(kind),
          'action': [
            'upload_payment_receipt',
            'confirm_payment',
            'upload_share_transfer_receipt',
            'confirm_share_transfer',
            'approve',
            'reject',
          ],
        });
        expect(order.viewerSide(7), PreIpoOrderSide.buyer);
        expect(order.viewerSide(8), PreIpoOrderSide.seller);
        expect(
          order.visibleActions(7),
          containsAll(['upload_payment_receipt', 'confirm_share_transfer']),
        );
        expect(order.visibleActions(7), isNot(contains('confirm_payment')));
        expect(
          order.visibleActions(7),
          isNot(contains('upload_share_transfer_receipt')),
        );
        expect(
          order.visibleActions(8),
          containsAll(['confirm_payment', 'upload_share_transfer_receipt']),
        );
        expect(
          order.visibleActions(8),
          isNot(contains('upload_payment_receipt')),
        );
        expect(
          order.visibleActions(8),
          isNot(contains('confirm_share_transfer')),
        );
        if (kind == 'partner_to_partner') {
          expect(order.visibleActions(7), isNot(contains('approve')));
          expect(order.visibleActions(8), isNot(contains('reject')));
        }
      },
    );
  }

  for (final roles in [
    ('partner_buys', 'Wealth Manager', 'Institution'),
    ('institution_buys', 'Institution', 'Wealth Manager'),
    ('partner_to_partner', 'Wealth Manager', 'Wealth Manager'),
    ('institution_to_institution', 'Institution', 'Institution'),
  ]) {
    test('${roles.$1} settlement API uses each acting account and namespace', () async {
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': orderJson(roles.$1, step: 'completed'),
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final file = MediaModel(
        name: 'receipt.pdf',
        dataType: FileDataType.bytes,
        uint8list: Uint8List.fromList([1, 2, 3]),
      );
      final buyerInstitution = roles.$2 == 'Institution';
      final sellerInstitution = roles.$3 == 'Institution';
      String prefix(bool institution) =>
          'v2/business/${institution ? 'institution/' : ''}pre-ipo/transaction';
      await app.setUser(prefUser: identity(roles.$2, 7));
      final payment = buyerInstitution
          ? await PreIPOTransactionApi.uploadPaymentReceipt(
              transactionId: 481,
              file: file,
            )
          : await WPreIpoTransactionApi.uploadPaymentReceipt(
              transactionId: 481,
              file: file,
            );
      expect(payment.isSuccess, true);
      expect(
        adapter.requests.last.path,
        '${prefix(buyerInstitution)}/payment-receipt',
      );
      expect(adapter.requests.last.headers['userid'], 7);
      expect((adapter.requests.last.data as FormData).files.single.key, 'file');

      await app.setUser(prefUser: identity(roles.$3, 8));
      final confirmed = sellerInstitution
          ? await PreIPOTransactionApi.confirmPayment(transactionId: 481)
          : await WPreIpoTransactionApi.confirmPayment(transactionId: 481);
      expect(confirmed.isSuccess, true);
      expect(
        adapter.requests.last.path,
        '${prefix(sellerInstitution)}/confirm-payment',
      );
      expect(adapter.requests.last.headers['userid'], 8);
      final transfer = sellerInstitution
          ? await PreIPOTransactionApi.uploadShareTransferReceipt(
              transactionId: 481,
              file: file,
            )
          : await WPreIpoTransactionApi.uploadShareTransferReceipt(
              transactionId: 481,
              file: file,
            );
      expect(transfer.isSuccess, true);
      expect(
        adapter.requests.last.path,
        '${prefix(sellerInstitution)}/share-transfer-receipt',
      );
      expect(adapter.requests.last.headers['userid'], 8);

      await app.setUser(prefUser: identity(roles.$2, 7));
      final completed = buyerInstitution
          ? await PreIPOTransactionApi.confirmShareTransfer(transactionId: 481)
          : await WPreIpoTransactionApi.confirmShareTransfer(
              transactionId: 481,
            );
      expect(completed.isSuccess, true);
      expect(
        adapter.requests.last.path,
        '${prefix(buyerInstitution)}/confirm-share-transfer',
      );
      expect(adapter.requests.last.headers['userid'], 7);
      expect(adapter.requests.last.data, {'transaction_id': 481});
      expect(adapter.requests.length, 4);
    });
  }

  test('Institution buyer can see its pending mandate order', () async {
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [orderJson('institution_to_institution')],
      }),
    );
    final result = await PreIPOTransactionApi.getTransactions();
    expect(result.isSuccess, true);
    expect(result.r!.map((order) => order.id), contains(481));
  });

  testWidgets('Institution buyer can open its mandate signing action', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
    final controller = PreIPOTransactionPageCtrl();
    final order = PreIpoOrderModel.fromJson(
      orderJson('institution_to_institution'),
    );
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (request) async => response({
        'status': 1,
        'data': request.path.endsWith('/detail')
            ? orderJson('institution_to_institution')
            : [orderJson('institution_to_institution')],
      }),
    );
    await tester.runAsync(
      () =>
          controller.handleAction(order, PreIpoOrderAction.showMandateSignLink),
    );
    await tester.pump();
    final urls = launchedUrls.toList();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(urls, contains('https://example.test/mandate'));
  });

  testWidgets(
    'Partner details use the fresh signing link after an external action',
    (tester) async {
      await app.setUser(prefUser: identity('Wealth Manager'));
      final initial = orderJson('partner_buys');
      final fresh = {
        ...initial,
        'order_step': 'deal_slip_pending',
        'sign_link': 'https://example.test/deal-slip',
        'action': ['show_deal_slip_sign_link'],
      };
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (request) async => response({
          'status': 1,
          'data': request.path.endsWith('/detail') ? fresh : [initial],
        }),
      );
      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: DesktopPreIPOBuyTransactionView())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('View details'));
      await tester.pumpAndSettle();
      final signButton = find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Sign deal slip'),
      );
      expect(signButton, findsOneWidget);
      await tester.ensureVisible(signButton);
      await tester.pumpAndSettle();
      await tester.tap(signButton);
      await tester.pumpAndSettle();
      expect(launchedUrls, ['https://example.test/deal-slip']);
    },
  );

  for (final marketPrice in [120.0, 120.75]) {
    testWidgets(
      'Returning to Market submits the displayed price $marketPrice',
      (tester) async {
        await app.setUser(prefUser: identity('Wealth Manager'));
        final c = Get.put<PreIPOInvestmentPageCtrl>(_Checkout());
        c.selectedOffer.value = PreIPOOffer.fromDeal(
          DealModel.fromJson({
            'id': 31,
            'deal_type': 'sell',
            'share_price': marketPrice,
            'minimum_qty': 1,
            'seller': {'id': 8},
          }),
        );
        final draft = SelectInvestorModel(
          investorId: 22,
          investorName: 'Test client',
          isMarket: true,
          price: marketPrice,
          quantityCTRL: TextEditingController(text: '10'),
          priceCTRL: TextEditingController(text: marketPrice.toString()),
        );
        draft.quantity(10);
        c.investorList.add(draft);
        final adapter = FakeAdapter(
          (request) async => response({
            'status': 1,
            'data': request.method == 'GET'
                ? [
                    {'id': 22, 'preipo_kyc_status': 1},
                  ]
                : [orderJson('partner_buys')],
          }),
        );
        dioConfig.dio.httpClientAdapter = adapter;
        await tester.pumpWidget(
          GetMaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: CardView(model: draft)),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Market', findRichText: true));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).last, '130');
        await tester.pump();
        await tester.tap(find.textContaining('Limit', findRichText: true));
        await tester.pumpAndSettle();
        expect(double.parse(draft.priceCTRL!.text), marketPrice);
        expect(draft.totalPrice(), marketPrice * 10);
        await tester.runAsync(
          () => WPreIpoTransactionApi.buy(list: [draft], dealId: 31),
        );
        final payload = adapter.requests.last.data as Map;
        expect(payload['orders'][0]['share_price'], marketPrice);
      },
    );
  }
}
