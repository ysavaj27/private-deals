import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/startup_portfolio_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

StartupPortfolioListModel group(
  int id,
  String investor,
  String company,
  double price, {
  Map<String, dynamic> extra = const {},
}) => StartupPortfolioListModel.fromJson({
  'investor': {'id': id, 'name': investor},
  'holdings': [
    {
      'id': id,
      'startup_id': id,
      'shares': 100,
      'purchase_price': 1000,
      'current_share_price': price,
      'on_sell_shares': 100,
      'is_primary_transaction': true,
      'startup': {'id': id, 'brand_name': company},
      ...extra,
    },
  ],
});

void main() {
  final data = [
    group(1, 'Aarav Shah', 'Aster Technologies', 1250),
    group(2, 'Priya Mehta', 'Bharat Infrastructure & Technology', 900),
    group(3, 'Rohan Patel', 'Cedar Energy', 1450),
  ];
  int refreshes = 0;
  Future<void> show(
    WidgetTester tester, {
    double width = 1200,
    bool dark = false,
    EquityTypeEnum type = EquityTypeEnum.equity,
    double scale = 1,
    List<StartupPortfolioListModel>? list,
  }) async {
    await tester.runAsync(() async {
      for (final family in ['inter', 'roboto']) {
        final font = FontLoader(family);
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          final bytes = await rootBundle.load(
            'assets/fonts/${family == 'inter' ? 'Inter' : 'Roboto'}-$weight.ttf',
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
            key: const ValueKey('preview'),
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: StartupPortfolioView(
                  type: type,
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

  setUp(() {
    refreshes = 0;
  });
  testWidgets('responsive equity layout supports themes and large text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [1200.0, 768.0, 390.0, 320.0]) {
      for (final dark in [false, true]) {
        await tester.pumpWidget(const SizedBox());
        await show(
          tester,
          width: width,
          dark: dark,
          scale: width == 320 ? 1.4 : 1,
        );
        expect(tester.takeException(), isNull);
        if (width == 1200 || width == 390) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('preview')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/startup-portfolio-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.scrollUntilVisible(
          find.text('Cedar Energy'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('search and investor chips combine and reset', (tester) async {
    await show(tester);
    expect(find.byType(ExpansionTile), findsNothing);
    await tester.enterText(find.byType(TextField), 'bharat');
    await tester.pumpAndSettle();
    expect(find.text('Aster Technologies'), findsNothing);
    expect(find.text('Bharat Infrastructure & Technology'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    await tester.tap(find.byKey(const ValueKey('investor-id:1')));
    await tester.pumpAndSettle();
    expect(find.text('No matching holdings'), findsOneWidget);
    await tester.tap(find.text('Reset filters').first);
    await tester.pumpAndSettle();
    expect(find.text('Aster Technologies'), findsOneWidget);
    await tester.tap(find.byTooltip('Refresh portfolio'));
    await tester.pumpAndSettle();
    expect(refreshes, 1);
  });

  testWidgets(
    'investors with the same name filter independently and reset when removed',
    (tester) async {
      final first = group(1, 'Same name', 'First company', 1250);
      final second = group(2, 'Same name', 'Second company', 900);
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

  testWidgets(
    'reported returns and values are respected without a share quote',
    (tester) async {
      await show(
        tester,
        list: [
          group(
            1,
            'Aarav Shah',
            'Aster Technologies',
            0,
            extra: {
              'investment_amount': 110000,
              'current_value': 125000,
              'return_amount': 15000,
              'return_percentage': 13.64,
            },
          ),
        ],
      );
      expect(find.text('+₹ 15,000 (13.64%)'), findsOneWidget);
      expect(find.text('₹ 1,10,000'), findsOneWidget);
      expect(find.text('₹ 1,25,000'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('100 listed for sale'), findsOneWidget);
    },
  );

  testWidgets(
    'missing valuations do not appear as losses and empty state refreshes',
    (tester) async {
      await show(tester, list: [group(1, 'Aarav', 'Unpriced company', 0)]);
      expect(find.text('−₹ 1,00,000'), findsNothing);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(2));
      for (final type in [
        EquityTypeEnum.equity,
        EquityTypeEnum.ccps,
        EquityTypeEnum.ccd,
      ]) {
        await show(tester, list: [], type: type);
        expect(find.text('Your portfolio starts here'), findsOneWidget);
        expect(
          find.text(
            'Your ${type == EquityTypeEnum.equity ? 'equity' : type.name.toUpperCase()} holdings will appear here once available.',
          ),
          findsOneWidget,
        );
      }
      await tester.tap(find.widgetWithText(TextButton, 'Refresh portfolio'));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
    },
  );
  for (final width in [390.0, 1280.0]) {
    testWidgets('Equity, CCPS and CCD use the shared holding cards at $width', (
      tester,
    ) async {
      final originalAdapter = dioConfig.dio.httpClientAdapter;
      Get.testMode = true;
      app.persist = false;
      await app.clear();
      await app.setUser(prefUser: identity());
      dioConfig.dio.httpClientAdapter = FakeAdapter((request) async {
        final type = request.queryParameters['type'];
        return response({
          'status': 1,
          'data': request.path == AppUrl.wPortfolio
              ? [group(1, 'Test investor', '$type Company', 1250).toJson()]
              : <Object>[],
        });
      });
      addTearDown(() async {
        await app.clear();
        Get.reset();
        dioConfig.dio.httpClientAdapter = originalAdapter;
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        GetMaterialApp(
          initialBinding: BindingsBuilder(() {
            Get.put(PortfolioPageCtrl(), permanent: true);
          }),
          home: Scaffold(body: Builder(builder: (_) => PortfolioPage())),
        ),
      );
      await tester.pumpAndSettle();
      for (final type in [
        EquityTypeEnum.equity,
        EquityTypeEnum.ccps,
        EquityTypeEnum.ccd,
      ]) {
        await tester.tap(
          find
              .text(
                type == EquityTypeEnum.equity
                    ? 'Equity'
                    : type.name.toUpperCase(),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(find.byType(StartupPortfolioView), findsOneWidget);
        expect(find.text('${type.name} Company'), findsOneWidget);
        expect(find.text('Shares held'), findsOneWidget);
        expect(
          find.widgetWithText(ChoiceChip, 'All investors'),
          findsOneWidget,
        );
        expect(find.byType(ExpansionTile), findsNothing);
        await tester.enterText(find.byType(TextField), 'no match');
        await tester.pumpAndSettle();
        expect(find.text('No matching holdings'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
