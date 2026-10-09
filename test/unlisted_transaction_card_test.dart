import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/unlisted_transaction_card.dart';

void main() {
  final order = PreIpoOrderModel(
    id: 481,
    orderStep: 'payment_pending',
    current: 'Awaiting payment from the investor',
    next: 'Transfer the payable amount and upload your receipt.',
    shares: 100,
    sharePrice: 1250,
    payableAmount: 125500,
    createdAt: DateTime(2026, 10, 5),
    transactionInvoiceNo: 'PRE-IPO-481',
    company: const PreIpoOrderCompany(
      brandName: 'National Stock Exchange of India Limited',
    ),
    investor: const PreIpoOrderInvestor(name: 'Aarav Shah', isSelf: true),
    action: [
      PreIpoOrderAction.viewPaymentDetails,
      PreIpoOrderAction.uploadPaymentReceipt,
      PreIpoOrderAction.cancel,
    ],
  );
  var details = 0;
  final actions = <String>[];
  Future<void> show(
    WidgetTester tester, {
    double width = 1200,
    bool dark = false,
    bool loading = false,
    PreIpoOrderModel? model,
  }) async {
    await tester.runAsync(() async {
      // Load the app's real fonts, including its Roboto fallback. Some of the
      // repository's Inter assets are empty placeholders.
      for (final family in ['inter', 'roboto']) {
        final font = FontLoader(family);
        final prefix = family == 'inter' ? 'Inter' : 'Roboto';
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          final bytes = await rootBundle.load(
            'assets/fonts/$prefix-$weight.ttf',
          );
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
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: RepaintBoundary(
          key: const ValueKey('transaction-preview'),
          child: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(width == 320 ? 1.4 : 1),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: UnlistedTransactionCard(
                    order: model ?? order,
                    isActionLoading: loading,
                    onDetails: () => details++,
                    onAction: (action) async {
                      actions.add(action);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (loading) {
      await tester.pump();
    } else {
      await tester.pumpAndSettle();
    }
  }

  testWidgets('card adapts to narrow widths, themes and large text', (
    tester,
  ) async {
    for (final width in [1200.0, 768.0, 390.0, 320.0]) {
      for (final dark in [false, true]) {
        await show(tester, width: width, dark: dark);
        expect(tester.takeException(), isNull);
        if ((width == 1200 && !dark) || (width == 390 && dark)) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('transaction-preview')),
            );
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/unlisted-transaction-${width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    }
  });
  testWidgets(
    'shows authoritative payable and routes details and server actions',
    (tester) async {
      await show(tester);
      expect(find.text('₹ 1,25,500'), findsOneWidget);
      expect(find.text('Payment pending'), findsOneWidget);
      expect(find.text('#PRE-IPO-481'), findsOneWidget);
      expect(find.text('Order #481'), findsNothing);
      expect(find.text('#481'), findsNothing);
      expect(find.text('Placed 05 Oct 2026'), findsOneWidget);
      await tester.tap(find.text('View details'));
      await tester.tap(find.text('Upload receipt'));
      expect(details, 1);
      expect(actions, [PreIpoOrderAction.uploadPaymentReceipt]);
      await show(tester, loading: true);
      expect(find.text('Upload receipt'), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'View details'),
            )
            .onPressed,
        isNull,
      );
    },
  );
  testWidgets(
    'terminal states suppress next step and missing optional fields',
    (tester) async {
      for (final step in ['completed', 'cancelled']) {
        await show(
          tester,
          model: PreIpoOrderModel(
            id: 987654,
            orderStep: step,
            next: 'Stale next step',
            cancellationReason: step == 'cancelled'
                ? 'Investor requested cancellation'
                : null,
          ),
        );
        expect(find.text('Next: Stale next step'), findsNothing);
        expect(find.textContaining('987654'), findsNothing);
        expect(find.text('₹ 0'), findsNWidgets(2));
        expect(find.text('Upload receipt'), findsNothing);
        if (step == 'cancelled') {
          expect(
            find.text('Reason: Investor requested cancellation'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      }
    },
  );
}
