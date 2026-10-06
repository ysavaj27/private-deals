import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/unlisted_portfolio_view.dart';

PreIPOPortfolioListModel group(
  String name,
  String company,
  int id,
  double price,
) => PreIPOPortfolioListModel.fromJson({
  'investor': {'id': id, 'name': name},
  'holdings': [
    {
      'id': id,
      'shares': 100,
      'purchase_price': 1000,
      'current_share_price': price,
      'on_sell_shares': 100,
      'company': {'id': id, 'brand_name': company},
    },
  ],
});

void main() {
  var refreshes = 0;
  final data = [
    group('Aarav Shah', 'National Stock Exchange', 1, 1250),
    group('Priya Mehta', 'Bharat Infrastructure & Technology Limited', 2, 900),
  ];
  Future<void> show(
    WidgetTester tester, {
    double width = 1200,
    bool dark = false,
    List<PreIPOPortfolioListModel>? list,
    double scale = 1,
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

    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1100),
            textScaler: TextScaler.linear(scale),
          ),
          child: RepaintBoundary(
            key: const ValueKey('portfolio'),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: UnlistedPortfolioView(
                  list: list ?? data,
                  onRefresh: () async {
                    refreshes++;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('responsive themes and large text render without overflow', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [1200.0, 768.0, 390.0, 320.0]) {
      for (final dark in [false, true]) {
        await show(
          tester,
          width: width,
          dark: dark,
          scale: width == 320 ? 1.4 : 1,
        );
        expect(tester.takeException(), isNull);
        if (width == 1200 && !dark || width == 390 && dark) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('portfolio')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File('/tmp/unlisted-portfolio-${width.toInt()}.png');
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    }
  });
  testWidgets('search filters company and investor and clears', (tester) async {
    await show(tester);
    expect(find.text('−₹ 10,000 (-10.00%)'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'priya');
    await tester.pumpAndSettle();
    expect(find.text('National Stock Exchange'), findsNothing);
    expect(
      find.text('Bharat Infrastructure & Technology Limited'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('National Stock Exchange'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'no match');
    await tester.pumpAndSettle();
    expect(find.text('No matching holdings'), findsOneWidget);
  });
  testWidgets('investor chips combine with search and reset to all investors', (
    tester,
  ) async {
    await show(tester);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Cost of held shares'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('investor-id:2')));
    await tester.pumpAndSettle();
    expect(find.text('National Stock Exchange'), findsNothing);
    expect(
      find.text('Bharat Infrastructure & Technology Limited'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'National');
    await tester.pumpAndSettle();
    expect(find.text('No matching holdings'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('National Stock Exchange'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'All investors'));
    await tester.pumpAndSettle();
    expect(find.text('National Stock Exchange'), findsOneWidget);
    final before = refreshes;
    await tester.tap(find.byTooltip('Refresh portfolio'));
    await tester.pumpAndSettle();
    expect(refreshes, before + 1);
  });
  testWidgets(
    'investor identity is independent of name and resets if removed',
    (tester) async {
      final first = group('Same name', 'First company', 1, 1200);
      final second = group('Same name', 'Second company', 2, 900);
      await show(tester, list: [first, second]);
      await tester.tap(find.byKey(const ValueKey('investor-id:2')));
      await tester.pumpAndSettle();
      expect(find.text('First company'), findsNothing);
      expect(find.text('Second company'), findsOneWidget);
      await show(tester, list: [first]);
      expect(find.text('First company'), findsOneWidget);
      expect(
        tester
            .widget<ChoiceChip>(
              find.widgetWithText(ChoiceChip, 'All investors'),
            )
            .selected,
        isTrue,
      );
    },
  );
  testWidgets('missing prices and empty holdings have explicit states', (
    tester,
  ) async {
    await show(tester, list: [group('Aarav', 'Company', 1, 0)]);
    expect(find.text('Unavailable'), findsOneWidget);
    await show(tester, list: []);
    expect(find.text('Your portfolio starts here'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
