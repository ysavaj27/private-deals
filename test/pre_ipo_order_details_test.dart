import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_order_detail_panels.dart';

Map<String, dynamic> detailPayload() => {
  'order_step': 'payment_pending',
  'current': 'Awaiting payment',
  'next': 'Upload receipt',
  'action': ['upload_payment_receipt'],
  'transaction_invoice_no': 'PRE-IPO-481',
  'created_at': '2026-10-01T10:00:00Z',
  'settlement_days': 2,
  'settlement_label': 'T+2',
  'settlement_date': '2026-10-06',
  'payment_mode': 'Bank transfer',
  'instrument': 'Equity shares',
  'investment_amount': '10000.50',
  'processing_fee': 0,
  'coupon_discount_amount': '0.00',
  'percentage': '40.5',
  'current_status': 'Payment pending',
  'next_step': 'Upload the payment receipt.',
  'status_list': [
    {
      'title': 'Order placed',
      'description': 'Your order has been created.',
      'date': '2026-10-01T10:00:00Z',
      'is_active': false,
    },
    {
      'title': 'Payment',
      'description': 'Transfer payment and upload your payment receipt.',
      'date': null,
      'is_active': 1,
      'action': {'type': 'legacy_action'},
    },
    {
      'title': 'Share transfer',
      'description': 'The institution will transfer the shares.',
      'date': null,
      'is_active': false,
    },
  ],
};

void main() {
  test('optional seller details coexist with the current action flow', () {
    final order = PreIpoOrderModel.fromJson(detailPayload());
    expect(order.transactionInvoiceNo, 'PRE-IPO-481');
    expect(order.createdAt, DateTime.utc(2026, 10, 1, 10));
    expect(order.settlementDays, 2);
    expect(order.settlementLabel, 'T+2');
    expect(order.settlementDate, DateTime(2026, 10, 6));
    expect(order.paymentMode, 'Bank transfer');
    expect(order.instrument, 'Equity shares');
    expect(order.investmentAmount, 10000.50);
    expect(order.processingFee, 0);
    expect(order.couponDiscountAmount, 0);
    expect(order.percentage, 40.5);
    expect(order.currentStatus, 'Payment pending');
    expect(order.nextStep, 'Upload the payment receipt.');
    expect(order.statusList.map((step) => step.title), [
      'Order placed',
      'Payment',
      'Share transfer',
    ]);
    expect(order.statusList.first.date, DateTime.utc(2026, 10, 1, 10));
    expect(order.statusList[1].isActive, isTrue);
    expect(order.statusList.last.date, isNull);
    expect(order.orderStep, 'payment_pending');
    expect(order.current, 'Awaiting payment');
    expect(order.next, 'Upload the payment receipt.');
    expect(order.action, ['upload_payment_receipt']);
  });

  test('missing and invalid details do not fabricate amounts or progress', () {
    for (final payload in <Map<String, dynamic>>[
      {},
      {
        'processing_fee': null,
        'investment_amount': '',
        'coupon_discount_amount': 'unknown',
        'percentage': 'NaN',
        'created_at': 'invalid',
        'settlement_date': null,
        'status_list': null,
      },
    ]) {
      final order = PreIpoOrderModel.fromJson(payload);
      expect(order.processingFee, isNull);
      expect(order.investmentAmount, isNull);
      expect(order.couponDiscountAmount, isNull);
      expect(order.percentage, isNull);
      expect(order.createdAt, isNull);
      expect(order.settlementDate, isNull);
      expect(order.statusList, isEmpty);
    }
    final order = PreIpoOrderModel.fromJson({
      'status_list': [
        null,
        'invalid',
        {'title': 'Pending', 'date': 'invalid'},
      ],
    });
    expect(order.statusList.single.title, 'Pending');
    expect(order.statusList.single.date, isNull);
  });

  Future<void> showDetails(WidgetTester tester, PreIpoOrderModel order) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  PreIpoOrderOverview(order: order),
                  PreIpoOrderAmountDetails(order: order),
                  PreIpoOrderProgress(order: order),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets('steps before the active step are completed without dates', (
    tester,
  ) async {
    final order = PreIpoOrderModel.fromJson({
      'order_step': 'payment_pending',
      'status_list': [
        {'title': 'Initiated'},
        {'title': 'Mandate signed', 'is_completed': false},
        {'title': 'Payment', 'is_active': true, 'date': '2026-10-01'},
        {'title': 'Transfer shares'},
      ],
    });
    await showDetails(tester, order);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
  });

  testWidgets('completed orders show all undated steps as completed', (
    tester,
  ) async {
    await showDetails(
      tester,
      PreIpoOrderModel.fromJson({
        'order_step': 'completed',
        'status_list': [
          {'title': 'Share confirmed'},
          {'title': 'Transaction completed', 'is_completed': true},
        ],
      }),
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
  });

  testWidgets('no active step does not imply a cancelled order is completed', (
    tester,
  ) async {
    await showDetails(
      tester,
      PreIpoOrderModel.fromJson({
        'order_step': 'cancelled',
        'status_list': [
          {'title': 'Initiated', 'date': '2026-10-01'},
          {'title': 'Payment'},
          {'title': 'Transfer shares'},
        ],
      }),
    );
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
    expect(find.byIcon(Icons.radio_button_checked), findsNothing);
  });

  testWidgets('current responses do not show empty extra sections', (
    tester,
  ) async {
    await showDetails(
      tester,
      PreIpoOrderModel.fromJson({
        'order_step': 'payment_pending',
        'current': 'Awaiting payment',
      }),
    );
    expect(find.text('Transaction overview'), findsNothing);
    expect(find.text('Transaction progress'), findsNothing);
    expect(find.text('Processing fee'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  for (final width in [320.0, 1000.0]) {
    testWidgets('details and timeline fit a $width wide view', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await showDetails(tester, PreIpoOrderModel.fromJson(detailPayload()));
      expect(find.text('PRE-IPO-481'), findsOneWidget);
      expect(find.text('Processing fee'), findsOneWidget);
      expect(find.text('₹0.00'), findsNWidgets(2));
      expect(find.text('41%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('progress clamps out-of-range percentages', (tester) async {
    for (final percentage in [-10.0, 150.0]) {
      await showDetails(tester, PreIpoOrderModel(percentage: percentage));
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, percentage < 0 ? 0 : 1);
      expect(tester.takeException(), isNull);
    }
  });
}
