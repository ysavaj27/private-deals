import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_table.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';

class _DetailController extends PreIPODetailPageCtrl {
  _DetailController(CompanyModel company) {
    model.value = company;
  }
  int investorSelections = 0;
  int submissions = 0;

  @override
  Future<void> getData() async {}

  @override
  Future<void> addInvestor() async {
    investorSelections++;
    investorList.add(
      SelectInvestorModel(
        investorId: investorSelections,
        investorName: 'An investor with a long name that should wrap correctly',
        isSelf: true,
        isMarket: true,
        price: purchasePrice,
        priceCTRL: TextEditingController(text: purchasePrice.toString()),
        quantityCTRL: TextEditingController(),
      ),
    );
  }

  @override
  Future<void> onPress() async {
    submissions++;
  }
}

CompanyModel _company() {
  final model = CompanyModel.fromJson({
    'id': 12,
    'slug': 'northstar',
    'brand_name': 'Northstar Technologies',
    'company_name': 'Northstar Technologies Limited',
    'sector': 'Technology',
    'category': 'Unlisted',
    'share_price': 1250,
    'distributer_price': 1240,
    'about':
        'Northstar Technologies builds software and digital infrastructure for growing businesses. '
        'The company serves enterprise customers across India through a portfolio of cloud, payments and data products. '
        'Its business combines long-term customer relationships with a focus on product development and operational efficiency.',
    'fundamentals': {
      'lot_size': 100,
      'market_cap': 8400,
      'pe_ratio': 24.6,
      'pb_ratio': 3.2,
      'roe': 18.4,
      'debt_to_equity': 0.24,
      'book_value': 390.6,
      'face_value': 10,
      'fifty_two_week_high': 1380,
      'fifty_two_week_low': 960,
      'depository': 'NSDL / CDSL',
      'pan_number': 'ABCDE1234F',
      'isin_number': 'INE000A01000',
      'cin_number': 'U12345MH2000PLC123456',
      'rta':
          'A registrar with a long descriptive name for wrapping verification',
      'total_shares': 67200000,
    },
    'deals': [
      for (var i = 0; i < 3; i++)
        {
          'id': 42 + i,
          'uuid': 'offer-$i',
          'status': 'available',
          'deal_type': 'sell',
          'share_price': 1240 + i * 10,
          'minimum_qty': 100,
          'available_quantity': 2000,
          'is_hot_deal': i == 0,
          'seller': {
            'id': i + 1,
            'company_name': [
              'Meridian Capital',
              'Oakwood Securities',
              'Crescent Investments',
            ][i],
          },
        },
    ],
    'seller_share_prices': [
      {
        'sell_price': 1270,
        'min_qty': 500,
        'seller': {'id': 19, 'company_name': 'Harbour Securities'},
      },
    ],
    'share_holders': [
      {
        'year': 2025,
        'shareholders': [
          {'name': 'Promoters', 'percentage': 62.5},
          {'name': 'Public', 'percentage': 37.5},
        ],
      },
      {
        'year': 2024,
        'shareholders': [
          {'name': 'Promoters', 'percentage': 65},
          {'name': 'Public', 'percentage': 35},
        ],
      },
    ],
    'promoters': [
      {
        'name': 'Aarav Shah',
        'designation': 'Managing Director',
        'experience': '20 years of experience',
        'url': 'https://example.com/profile',
      },
    ],
    'events': [
      {
        'title': 'Annual report',
        'description': 'Company performance and financial statements.',
        'date': '2025-09-01',
        'file': 'https://example.com/report.pdf',
      },
    ],
    'peerratio': [
      {'perticular': 'Company'},
      {
        'perticular': 'Comparison company',
        'revenue': 1100,
        'eps': 50,
        'market_cap': 9000,
        'pe': '25',
      },
    ],
  });
  model.customData = [
    for (final label in [
      'Income statement',
      'Earnings per share',
      'Balance sheet',
      'Cash flow',
    ])
      CustomDataModel(
        label: label,
        values: [
          ['Particulars', 'FY 2023', 'FY 2024', 'FY 2025'],
          ['Revenue', 950, 1100, 1280],
          ['Profit after tax', 120, null, 180],
        ],
      ),
  ];
  model.sharePrices = [
    for (var i = 0; i < 6; i++)
      SharePriceModel(date: DateTime(2025, i + 1), price: 1000 + i * 50),
  ];
  return model;
}

Future<_DetailController> _pump(
  WidgetTester tester,
  double width, {
  bool dark = true,
  CompanyModel? company,
  GlobalKey? captureKey,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.runAsync(() async {
    // Load the app's real fonts, including its Roboto fallback. Some of the
    // repository's Inter assets are empty placeholders.
    for (final family in ['inter', 'roboto']) {
      final font = FontLoader(family);
      final prefix = family == 'inter' ? 'Inter' : 'Roboto';
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
  final c = _DetailController(company ?? _company());
  Get.put<PreIPODetailPageCtrl>(c);
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/detail/northstar',
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        getPages: [
          GetPage(
            name: '/detail/northstar',
            page: () => PreIPODetailView(phone: width < 600),
          ),
          GetPage(
            name: '/detail/northstar/investment',
            page: () => const Scaffold(body: Text('Investment page')),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_PRE_IPO_UI')) return;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/tmp/pre-ipo-$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUp(() {
    Get.testMode = true;
  });
  tearDown(() {
    Get.reset();
  });

  for (final width in [320.0, 390.0, 800.0, 1280.0, 1600.0]) {
    testWidgets('Responsive details and seller dialog at $width', (
      tester,
    ) async {
      final capture = GlobalKey();
      final c = await _pump(tester, width, captureKey: capture);
      expect(tester.takeException(), isNull);
      expect(find.text('Minimum quantity'), findsNothing);
      expect(find.text('Min. 100 shares'), findsNWidgets(3));
      expect(find.text('Min. 500 shares'), findsOneWidget);
      expect(find.byType(SellerProfileWidget), findsNWidgets(4));
      expect(find.text('SHARE PRICE'), findsNothing);
      expect(find.text('Price per equity share'), findsNothing);
      expect(find.text('Share price history'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsOneWidget);
      expect(find.text('MANAGING DIRECTOR'), findsOneWidget);
      await _capture(tester, capture, '${width.toInt()}-dark');
      await tester.ensureVisible(find.text('Meridian Capital'));
      await tester.tap(find.text('Meridian Capital'));
      await tester.pumpAndSettle();
      expect(find.text('Offer details'), findsOneWidget);
      expect(find.text('Minimum quantity'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _capture(tester, capture, '${width.toInt()}-dialog');
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(c.selectedOffer.value, isNull);
      // Visit the complete long page to exercise tables and footer cards.
      for (
        double offset = 0;
        offset < c.scrollController.position.maxScrollExtent;
        offset += 650
      ) {
        c.scrollController.jumpTo(offset);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      c.scrollController.jumpTo(c.scrollController.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Only marked available hot deals appear above regular offers and seller slots',
    (tester) async {
      final model = _company();
      model.deals.add(
        model.deals.first.copyWith(id: 99, uuid: 'sold-hot', status: 'sold'),
      );
      final c = await _pump(tester, 1280, company: model);
      final hot = find.byKey(const ValueKey('hot-deals-section'));
      final regular = find.byKey(const ValueKey('available-offers-section'));
      expect(
        find.descendant(of: hot, matching: find.text('Meridian Capital')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hot, matching: find.text('Oakwood Securities')),
        findsNothing,
      );
      expect(
        find.descendant(of: regular, matching: find.text('Meridian Capital')),
        findsNothing,
      );
      expect(
        find.descendant(of: regular, matching: find.text('Oakwood Securities')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: regular, matching: find.text('Harbour Securities')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(hot).dy,
        lessThan(tester.getTopLeft(regular).dy),
      );
      expect(find.text('Meridian Capital'), findsOneWidget);
      c.model.update((company) {
        company!.deals = company.deals
            .map((deal) => deal.copyWith(isHotDeal: false))
            .toList();
      });
      await tester.pumpAndSettle();
      expect(hot, findsNothing);
      expect(
        find.descendant(of: regular, matching: find.text('Meridian Capital')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: regular, matching: find.text('Harbour Securities')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Direct desktop buy preserves selection and validation', (
    tester,
  ) async {
    final c = await _pump(tester, 1280);
    await tester.tap(find.text('Buy').first);
    await tester.pumpAndSettle();
    expect(find.text('Offer details'), findsNothing);
    expect(c.selectedOffer.value?.dealId, 42);
    expect(c.investorSelections, 1);
    await tester.tap(find.text('Invest'));
    await tester.pumpAndSettle();
    expect(c.submissions, 0);
    await tester.ensureVisible(find.byType(TextFormField).first);
    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Invest'));
    await tester.pumpAndSettle();
    expect(c.submissions, 1);
    expect(c.investorList.single.totalPrice.value, 124000);
    await tester.ensureVisible(find.byTooltip('Remove investor'));
    await tester.tap(find.byTooltip('Remove investor'));
    await tester.pumpAndSettle();
    expect(c.investorList, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Direct phone buy preserves investment route and arguments', (
    tester,
  ) async {
    final c = await _pump(tester, 390);
    await tester.ensureVisible(find.text('Buy').first);
    await tester.tap(find.text('Buy').first);
    await tester.pumpAndSettle();
    expect(find.text('Investment page'), findsOneWidget);
    final selection = Get.arguments as PreIPOInvestmentSelection;
    expect(selection.offer.dealId, 42);
    expect(c.investorSelections, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Financial tabs, year selection, and empty sections remain usable',
    (tester) async {
      final c = await _pump(tester, 1280);
      await tester.tap(find.text('Financials').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Balance Sheet'));
      await tester.pumpAndSettle();
      expect(c.financialTab.value, 2);
      expect(find.text('Balance sheet'), findsOneWidget);
      await tester.tap(find.text('Shareholding'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2024'));
      await tester.pumpAndSettle();
      expect(c.shareHoldingTab.value, 1);
      expect(find.text('65.0%'), findsOneWidget);
      c.model.value = CompanyModel.fromJson({'brand_name': 'Empty company'});
      await tester.pumpAndSettle();
      for (final label in [
        'Overview',
        'Fundamentals',
        'Financials',
        'Shareholding',
        'Peers',
        'Events',
        'Management',
      ]) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('Partial financial data and wide tables preserve blank cells', (
    tester,
  ) async {
    final model = _company();
    model.customData = [model.customData.first];
    final c = await _pump(tester, 390, company: model, dark: false);
    c.scrollToSection(2);
    await tester.pumpAndSettle();
    expect(find.text('—'), findsWidgets);
    final table = find.byType(PreIPODetailTable).first;
    await tester.drag(table, const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('FY 2025'), findsOneWidget);
    await tester.tap(find.text('Cash Flow'));
    await tester.pumpAndSettle();
    expect(find.text('This statement is not available yet.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Light theme and enlarged text fit narrow screens', (
    tester,
  ) async {
    final capture = GlobalKey();
    await _pump(tester, 390, dark: false, captureKey: capture, textScale: 1.4);
    await _capture(tester, capture, '390-light-large-text');
    await tester.ensureVisible(find.text('Meridian Capital'));
    await tester.tap(find.text('Meridian Capital'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seller slots show terms only in a dialog and retain enquiry', (
    tester,
  ) async {
    final model = _company();
    model.deals = [];
    model.sellerSharePrices = [
      SellerSharePriceModel.fromJson({
        'sell_price': 1260,
        'min_qty': 500,
        'total_qty': 2000,
        'seller': {'id': 18, 'company_name': 'Legacy Seller'},
      }),
    ];
    await _pump(tester, 390, company: model);
    expect(find.text('Minimum quantity'), findsNothing);
    await tester.ensureVisible(find.text('Legacy Seller'));
    await tester.tap(find.text('Legacy Seller'));
    await tester.pumpAndSettle();
    expect(find.text('Seller details'), findsOneWidget);
    expect(find.text('500 shares'), findsOneWidget);
    expect(find.text('Buy Now'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.widgetWithText(OutlinedButton, 'Enquire'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
