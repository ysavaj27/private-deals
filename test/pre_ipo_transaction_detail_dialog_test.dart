import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_transaction_detail_dialog.dart';

PreIpoOrderModel sampleOrder() => PreIpoOrderModel.fromJson({
  'id': 965,
  'transaction_invoice_no': 'TN-02-NU',
  'order_step': 'completed',
  'current_step': 'Transaction completed.',
  'next_step': 'N/A',
  'company': {'brand_name': 'Example Company'},
  'investor': {'name': 'Example Investor'},
  'shares': 1500,
  'base_price': '15.00',
  'distributer_price': '15.15',
  'share_price': '20.00',
  'investment_amount': '30000.00',
  'payable_amount': '30000.00',
  'created_at': '2026-10-01T12:22:59.000000Z',
  'status_list': [
    for (final title in ['Transaction Initiated', 'Mandate Signed'])
      {
        'title': title,
        'description': '$title.',
        'date': '2026-10-01T12:23:00Z',
        'is_active': false,
      },
    {
      'title': 'Share Confirmed',
      'description': 'Share confirmed.',
      'date': null,
      'is_active': false,
    },
    {
      'title': 'Deal Slip Signed',
      'description': 'Deal slip signed.',
      'date': '2026-10-01T12:24:26Z',
      'document': {'name': 'Deal slip', 'url': 'https://example.com/slip.pdf'},
    },
    for (final title in ['Payment Completed', 'Shares Transferred'])
      {
        'title': title,
        'description': '$title.',
        'date': '2026-10-01T12:26:00Z',
      },
    {
      'title': 'Transaction Completed',
      'description': 'Transaction completed.',
      'date': null,
      'is_completed': true,
    },
  ],
  'documents': [
    {
      'name': 'Buy mandate',
      'type': 'BuyMandate',
      'url': 'https://example.com/mandate.pdf',
    },
  ],
  'payment_details': {
    'amount': '30000',
    'account': {
      'account_holder_name': 'Example Investor',
      'bank_name': 'Example Bank',
      'account_number': '0000000000',
      'ifsc_code': 'EXAM0000000',
    },
  },
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['inter', 'roboto']) {
      final prefix = family == 'inter' ? 'Inter' : 'Roboto';
      final font = FontLoader(family);
      for (final weight in ['Regular', 'Medium', 'Bold']) {
        final bytes = await rootBundle.load('assets/fonts/$prefix-$weight.ttf');
        font.addFont(
          bytes.lengthInBytes > 0
              ? Future.value(bytes)
              : rootBundle.load('assets/fonts/Roboto-$weight.ttf'),
        );
      }
      await font.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  test('updated API keys, completion flags and step documents parse', () {
    final order = sampleOrder();
    expect(order.current, 'Transaction completed.');
    expect(order.next, 'N/A');
    expect(order.statusList.last.completed, isTrue);
    expect(order.statusList.last.date, isNull);
    expect(order.statusList[2].completed, isFalse);
    expect(order.statusList[3].document?.url, 'https://example.com/slip.pdf');
    expect(order.percentage, isNull);
    expect(
      PreIpoOrderStatus.fromJson({
        'date': '2026-10-01',
        'is_completed': false,
      }).completed,
      isFalse,
    );
    final legacy = PreIpoOrderModel.fromJson({
      'current': 'Legacy status',
      'next': 'Legacy next',
    });
    expect(legacy.current, 'Legacy status');
    expect(legacy.next, 'Legacy next');
  });

  for (final width in [360.0, 1280.0]) {
    testWidgets('seller-style dialog at width $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundaryKey = GlobalKey();
      final order = sampleOrder();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: boundaryKey,
            child: Scaffold(
              body: PreIpoTransactionDetailDialog(
                initial: order,
                loadDetail: () async => order,
                onAction: (_) async {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('TN-02-NU'), findsOneWidget);
      expect(find.text('Amount breakdown'), findsOneWidget);
      expect(find.text('Transaction progress'), findsOneWidget);
      expect(find.text('Payment details'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(7));
      expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Processing fee'), findsNothing);
      final overview = tester.getTopLeft(find.text('Example Company'));
      final timeline = tester.getTopLeft(find.text('Transaction progress'));
      if (width > 1000) {
        expect(timeline.dx, greaterThan(overview.dx + 300));
      } else {
        expect(timeline.dy, greaterThan(overview.dy));
      }
      expect(tester.takeException(), isNull);
      if (Platform.environment['TRANSACTION_SCREENSHOTS'] == '1') {
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()
                  as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/transaction-detail-${width.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }

  testWidgets('existing action callback refreshes the detail', (tester) async {
    final actions = <String>[];
    var loads = 0;
    const initial = PreIpoOrderModel(
      orderStep: 'share_transfer_pending',
      action: ['confirm_share_transfer'],
    );
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: PreIpoTransactionDetailDialog(
            initial: initial,
            onAction: (action) async => actions.add(action),
            loadDetail: () async {
              loads++;
              return loads == 1 ? initial : sampleOrder();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirm transfer'));
    await tester.tap(find.text('Confirm transfer'));
    await tester.pumpAndSettle();
    expect(actions, ['confirm_share_transfer']);
    expect(loads, 2);
    expect(find.text('Confirm transfer'), findsNothing);
    expect(find.text('TN-02-NU'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
