import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_charts.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_debug_data.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_sections.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_insights.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_view.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

class _DashboardController extends DashboardPageCtrl {
  @override
  Future<void> getAllData() async {}
}

Map<String, dynamic> dashboardFixture({int size = 3}) => {
  'total_amount_invested': 12500000,
  'average_ticket_size': 1250000,
  'total_investors': 10,
  'total_startups': size,
  'pending_kyc': 2,
  'pending_document_sign': 1,
  'pending_payment': 500000,
  'sectors': [
    for (var i = 0; i < size; i++)
      {
        'id': i + 1,
        'name': [
          'Financial services',
          'Healthcare',
          'Consumer technology',
        ][i % 3],
        'total_investment': 3000000 / (i + 1),
        'startups': [
          {
            'startup_id': i + 1,
            'startup_name': 'Company ${i + 1}',
            'investor_name': 'Aarav Shah',
            'investment_amount': 1000000,
          },
          {
            'startup_id': i + 1,
            'startup_name': 'Company ${i + 1}',
            'investor_name': 'Priya Mehta',
            'investment_amount': 500000,
          },
        ],
      },
  ],
  'investment_growth': [
    for (var i = 0; i < size; i++)
      {
        'startup_id': i + 1,
        'startup_name': [
          'Northstar Technologies',
          'Bharat Healthcare',
          'Summit Consumer Brands',
        ][i % 3],
        'total_invested_amount': 2000000 / (i + 1),
        'current_value': i == 2
            ? null
            : i == 1
            ? 850000
            : 2450000,
      },
  ],
  'investments': {
    'monthly': [
      for (var i = 0; i < size; i++)
        {
          'month': '2026-${(i + 1).toString().padLeft(2, '0')}',
          'total_investment': (i + 1) * 500000,
        },
    ],
    'quarterly': [
      {
        'quater': 'Q1 2026',
        'start': '2026-01-01',
        'end': '2026-03-31',
        'total_investment': 3000000,
      },
    ],
  },
  'investor_chart': {
    'active': [
      {
        'id': 1,
        'name': 'Aarav Shah',
        'email': 'aarav@example.com',
        'is_active': 1,
        'kyc_status': 0,
      },
      {'id': 2, 'name': 'Priya Mehta', 'is_active': 0, 'kyc_status': 1},
    ],
    'kyc': [
      {
        'id': 1,
        'name': 'Aarav Shah',
        'email': 'aarav@example.com',
        'is_active': 1,
        'kyc_status': 0,
      },
      {'id': 2, 'name': 'Priya Mehta', 'is_active': 0, 'kyc_status': 1},
    ],
  },
  'top_investors': [
    {'name': 'Priya Mehta', 'amount_invested': 2500000, 'total_startups': 2},
  ],
  'investors': [
    {'name': 'Priya Mehta', 'amount_invested': 2500000, 'total_startups': 2},
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
  });
  tearDown(() async {
    Get.reset();
    await app.clear();
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  test(
    'Activity uses is_active independently of KYC; unknown is not pending',
    () {
      final data = dashboardFixture();
      (data['investor_chart'] as Map)['active'].add({'name': 'Unknown'});
      (data['investor_chart'] as Map)['kyc'].add({
        'name': 'Other',
        'kyc_status': 2,
      });
      final insights = DashboardInsights(WDashboardModel.fromJson(data));
      expect(insights.active.single.name, 'Aarav Shah');
      expect(insights.inactive.single.name, 'Priya Mehta');
      expect(insights.unknownActivity.single.name, 'Unknown');
      expect(insights.verified.single.name, 'Priya Mehta');
      expect(insights.pendingKyc.single.name, 'Aarav Shah');
      expect(insights.otherKyc.single.name, 'Other');
    },
  );

  test('Missing valuation differs from zero; change and company counts are accurate', () {
    final insights = DashboardInsights(
      WDashboardModel.fromJson(dashboardFixture()),
    );
    expect(insights.companies.first.change, 450000);
    expect(insights.companies.first.changePercent, 22.5);
    expect(insights.companies[1].change, -150000);
    expect(insights.companies[2].change, isNull);
    expect(insights.sectors.first.companies, 1);
    final zero = CompanyPerformance(
      InvestmentGrowthModel.fromJson({
        'total_invested_amount': 100,
        'current_value': 0,
      }),
    );
    expect(zero.changePercent, -100);
    final noBasis = CompanyPerformance(
      InvestmentGrowthModel.fromJson({
        'total_invested_amount': 0,
        'current_value': 100,
      }),
    );
    expect(noBasis.changePercent, isNull);
    expect(dashboardMoney(0), '₹0');
    expect(dashboardMoney(-150000), '−₹1.5L');
    expect(dashboardMoney(double.nan), 'Unavailable');
  });

  test('Periods sort only with dates and support both quarter spellings', () {
    final model = WDashboardModel.fromJson({
      'investments': {
        'monthly': [
          {'month': '2026-09', 'total_investment': 10},
          {'month': '2026-01', 'total_investment': 0},
        ],
        'quarterly': [
          {'quarter': 'Q2', 'start': '2026-04-01', 'end': '2026-06-30'},
          {'quater': 'Q1', 'start': '2026-01-01', 'end': '2026-03-31'},
        ],
      },
    });
    final insights = DashboardInsights(model);
    expect(insights.periods(monthly: true).first.label, '2026-01');
    expect(insights.periods(monthly: false).first.label, 'Q1');
    expect(insights.periods(monthly: false).first.range, contains('2026'));
    model.investments.monthly = [
      MonthlyInvestmentModel(month: 'December'),
      MonthlyInvestmentModel(month: 'January'),
    ];
    expect(insights.periods(monthly: true).first.label, 'December');
  });

  test('Late response cannot replace a different portfolio, and refresh errors preserve data', () async {
    final late = Completer<ResponseBody>();
    final started = Completer<void>();
    var fail = false;
    dioConfig.dio.httpClientAdapter = FakeAdapter((request) async {
      if (request.path == AppUrl.wPreIPODashboard) {
        started.complete();
        return late.future;
      }
      return response(
        fail
            ? {'status': 0}
            : {
                'status': 1,
                'data': {'total_investors': 42},
              },
      );
    });
    final c = DashboardPageCtrl();
    final oldRequest = c.getData();
    await started.future;
    await c.changeTab(DashboardTypeEnum.primary);
    late.complete(
      response({
        'status': 1,
        'data': {'total_investors': 1},
      }),
    );
    await oldRequest;
    expect(c.model().totalInvestors, 42);
    expect(c.isLoading(), false);
    fail = true;
    await c.getData();
    expect(c.isData(), true);
    expect(c.model().totalInvestors, 42);
    expect(c.error(), isNotEmpty);
    c.onDelete();
  });

  Future<void> show(
    WidgetTester tester,
    Widget child, {
    double width = 1280,
    bool dark = false,
    double scale = 1,
    double height = 1100,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            textScaler: TextScaler.linear(scale),
          ),
          child: RepaintBoundary(
            key: const ValueKey('capture'),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Empty portfolio has a clear next step and no fabricated charts',
    (tester) async {
      final c = Get.put<DashboardPageCtrl>(_DashboardController());
      c.isData(true);
      await show(tester, const WealthDashboardView(), width: 360);
      expect(find.text('No investments to show yet'), findsOneWidget);
      expect(find.text('Explore opportunities'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsNothing);
      expect(find.text('₹0'), findsNWidgets(2));
      expect(find.text('No KYC records available yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Single period is a value card; single sector is 100%; zero data does not divide by zero',
    (tester) async {
      final c = Get.put<DashboardPageCtrl>(_DashboardController());
      c.model(WDashboardModel.fromJson(dashboardFixture(size: 1)));
      c.isData(true);
      await show(tester, const WealthDashboardView(), width: 360);
      expect(find.text('One period available'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsNothing);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('1 company'), findsOneWidget);
      final zero = dashboardFixture(size: 1);
      (zero['sectors'] as List).first['total_investment'] = 0;
      c.model(WDashboardModel.fromJson(zero));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Sector amounts are ₹0; allocation percentages are unavailable.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Two periods render, quarterly is a single value, and records remain available',
    (tester) async {
      final model = WDashboardModel.fromJson(dashboardFixture(size: 2));
      await show(
        tester,
        SingleChildScrollView(child: DashboardActivityChart(model: model)),
        width: 360,
      );
      expect(find.byType(SfCartesianChart), findsOneWidget);
      await tester.tap(find.text('Quarterly'));
      await tester.pumpAndSettle();
      expect(find.text('One period available'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsNothing);
      await tester.tap(find.text('View all period details (1)'));
      await tester.pumpAndSettle();
      expect(find.text('₹30,00,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Sector and activity statuses open the correct detail records', (
    tester,
  ) async {
    final model = WDashboardModel.fromJson(dashboardFixture());
    await show(
      tester,
      SingleChildScrollView(
        child: Column(
          children: [
            DashboardSectorChart(model: model),
            DashboardInvestorChart(model: model),
          ],
        ),
      ),
      width: 760,
    );
    await tester.tap(find.text('Financial services'));
    await tester.pumpAndSettle();
    expect(find.text('Company 1'), findsNWidgets(2));
    expect(find.text('Aarav Shah'), findsOneWidget);
    await tester.tap(find.byTooltip('Close details'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Active'));
    await tester.tap(find.text('Active'));
    await tester.pumpAndSettle();
    expect(find.text('Aarav Shah'), findsOneWidget);
    expect(find.text('Priya Mehta'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [360.0, 760.0, 1280.0]) {
    for (final dark in [false, true]) {
      testWidgets(
        'Dashboard responsive layout $width dark=$dark with larger text',
        (tester) async {
          final c = Get.put<DashboardPageCtrl>(_DashboardController());
          c.model(WDashboardModel.fromJson(dashboardFixture(size: 3)));
          c.isData(true);
          await show(
            tester,
            const WealthDashboardView(),
            width: width,
            dark: dark,
            scale: width == 760 ? 1.5 : 1,
          );
          expect(find.text('Current value unavailable'), findsOneWidget);
          expect(find.text('−₹1.5L'), findsOneWidget);
          expect(find.text('Review'), findsOneWidget);
          expect(find.text('500003'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Many sectors and companies expand without hiding totals', (
    tester,
  ) async {
    final model = WDashboardModel.fromJson(dashboardFixture(size: 8));
    await show(
      tester,
      SingleChildScrollView(
        child: Column(
          children: [
            DashboardSectorChart(model: model),
            DashboardPerformanceChart(model: model),
          ],
        ),
      ),
      width: 1280,
    );
    expect(find.text('View all 8 sectors'), findsOneWidget);
    await tester.tap(find.text('View all 8 sectors'));
    await tester.pumpAndSettle();
    expect(find.text('Show fewer sectors'), findsOneWidget);
    await tester.ensureVisible(find.text('View all 8 companies'));
    await tester.tap(find.text('View all 8 companies'));
    await tester.pumpAndSettle();
    expect(find.text('Show fewer companies'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loading and error are distinct from an empty success', (
    tester,
  ) async {
    final c = Get.put<DashboardPageCtrl>(_DashboardController());
    c.isLoading(true);
    await show(tester, const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: WealthDashboardView()),
      ),
    );
    await tester.pump();
    expect(find.text('Loading your portfolio…'), findsOneWidget);
    expect(find.text('No investments to show yet'), findsNothing);
    c.isLoading(false);
    c.error('Unable to fetch the portfolio.');
    await tester.pumpAndSettle();
    expect(find.text('Unable to load dashboard'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('₹0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Zero timeline and unavailable chart sections remain informative',
    (tester) async {
      final model = WDashboardModel.fromJson({
        'investments': {
          'monthly': [
            {'month': '2026-01', 'total_investment': 0},
            {'month': '2026-02', 'total_investment': 0},
          ],
        },
      });
      await show(
        tester,
        SingleChildScrollView(
          child: Column(
            children: [
              DashboardActivityChart(model: model),
              DashboardSectorChart(model: model),
              DashboardPerformanceChart(model: model),
            ],
          ),
        ),
        width: 360,
      );
      expect(
        find.text('No investment recorded in these periods'),
        findsOneWidget,
      );
      expect(find.text('No sector allocation yet'), findsOneWidget);
      expect(find.text('No company performance yet'), findsOneWidget);
      expect(find.byType(SfCartesianChart), findsNothing);
      await tester.tap(find.text('Quarterly'));
      await tester.pumpAndSettle();
      expect(find.text('No quarterly history yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Very large text fits a narrow dashboard', (tester) async {
    final c = Get.put<DashboardPageCtrl>(_DashboardController());
    c.model(WDashboardModel.fromJson(dashboardFixture(size: 1)));
    c.isData(true);
    await show(tester, const WealthDashboardView(), width: 360, scale: 2);
  });

  test(
    'Debug sample totals agree across charts and both portfolios are populated',
    () {
      for (final primary in [false, true]) {
        final sample = createDashboardDebugData(isPrimary: primary);
        final insights = DashboardInsights(sample);
        expect(sample.totalStartups, 8);
        expect(sample.totalInvestors, 12);
        expect(sample.sectors.length, 6);
        expect(sample.investments.monthly.length, 12);
        expect(sample.investments.quarterly.length, 4);
        expect(
          sample.investments.monthly.fold<double>(
            0,
            (sum, p) => sum + p.totalInvestment,
          ),
          sample.totalAmountInvested,
        );
        expect(
          sample.investments.quarterly.fold<double>(
            0,
            (sum, p) => sum + p.totalInvestment,
          ),
          sample.totalAmountInvested,
        );
        expect(insights.sectorTotal, sample.totalAmountInvested);
        expect(
          sample.investors.fold<double>(0, (sum, i) => sum + i.amountInvested),
          sample.totalAmountInvested,
        );
        expect(insights.companies.any((c) => (c.change ?? 0) > 0), true);
        expect(insights.companies.any((c) => (c.change ?? 0) < 0), true);
        expect(insights.companies.any((c) => c.change == null), true);
      }
    },
  );

  test('Preview survives in-flight responses and switching off restores actual data', () async {
    final pending = Completer<ResponseBody>();
    final started = Completer<void>();
    final adapter = FakeAdapter((_) async {
      started.complete();
      return pending.future;
    });
    dioConfig.dio.httpClientAdapter = adapter;
    final c = DashboardPageCtrl();
    final request = c.getData();
    await started.future;
    await c.setShowDummyData(true);
    expect(c.displayedModel.totalInvestors, 12);
    pending.complete(
      response({
        'status': 1,
        'data': {'total_investors': 42},
      }),
    );
    await request;
    expect(c.displayedModel.totalInvestors, 12);
    expect(c.model().totalInvestors, 42);
    await c.setShowDummyData(false);
    expect(c.displayedModel.totalInvestors, 42);
    expect(adapter.requests.length, 1);
    c.onDelete();
  });

  test('Preview tab changes do not call APIs and leaving preview loads the selected portfolio', () async {
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': {'total_investors': 7},
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final c = DashboardPageCtrl();
    await c.setShowDummyData(true);
    await c.changeTab(DashboardTypeEnum.primary);
    await c.getData();
    expect(adapter.requests, isEmpty);
    expect(c.displayedModel.investmentGrowth.first.startupName, 'Cedar Cloud');
    await c.setShowDummyData(false);
    expect(adapter.requests.single.path, AppUrl.wDashboard);
    expect(c.displayedModel.totalInvestors, 7);
    c.onDelete();
  });

  testWidgets(
    'Debug checkbox stays hidden; preview can still be exercised programmatically',
    (tester) async {
      final c = Get.put<DashboardPageCtrl>(_DashboardController());
      c.isData(true);
      await show(tester, const WealthDashboardView(), width: 360);
      expect(find.text('Show dummy data'), findsNothing);
      await c.setShowDummyData(true);
      await tester.pumpAndSettle();
      expect(find.text('No investments to show yet'), findsNothing);
      expect(find.text('Unlisted portfolio · Sample data'), findsOneWidget);
      expect(find.text('View all 6 sectors'), findsOneWidget);
      expect(find.text('View all 8 companies'), findsOneWidget);
      final priorityActions = tester.widgetList<InkWell>(
        find.descendant(
          of: find.byType(DashboardPriorities),
          matching: find.byType(InkWell),
        ),
      );
      expect(priorityActions.every((action) => action.onTap == null), true);
      expect(tester.takeException(), isNull);
      await c.setShowDummyData(false);
      await tester.pumpAndSettle();
      expect(find.text('No investments to show yet'), findsOneWidget);
      expect(c.model().totalInvestors, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Preview can be enabled on an error and sample KYC is read-only',
    (tester) async {
      final c = Get.put<DashboardPageCtrl>(_DashboardController());
      c.error('Dashboard unavailable');
      await show(tester, const WealthDashboardView());
      await c.setShowDummyData(true);
      await tester.pumpAndSettle();
      expect(find.text('Unable to load dashboard'), findsNothing);
      final status = find.descendant(
        of: find.byType(DashboardInvestorChart),
        matching: find.text('KYC pending'),
      );
      await tester.ensureVisible(status);
      await tester.tap(status);
      await tester.pumpAndSettle();
      expect(find.text('Sample data · 3 investors'), findsOneWidget);
      expect(find.text('Complete KYC'), findsNothing);
      expect(find.text('sample.investor.1@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Capture dashboard previews', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_DASHBOARD')) return;
    await tester.runAsync(() async {
      for (final family in ['inter', 'roboto']) {
        final loader = FontLoader(family);
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          loader.addFont(
            rootBundle.load(
              'assets/fonts/${family == 'inter' ? 'Inter' : 'Roboto'}-$weight.ttf',
            ),
          );
        }
        await loader.load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final c = Get.put<DashboardPageCtrl>(_DashboardController());
    c.isData(true);
    c.lastUpdated(DateTime(2026, 10, 8, 15, 30));
    for (final state in ['populated', 'empty', 'single']) {
      c.model(
        WDashboardModel.fromJson(
          state == 'empty'
              ? {}
              : dashboardFixture(size: state == 'single' ? 1 : 3),
        ),
      );
      for (final width in [360.0, 1280.0]) {
        for (final dark in [false, true]) {
          await show(
            tester,
            const WealthDashboardView(),
            width: width,
            dark: dark,
            height: width == 360 ? 2400 : 2050,
          );
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('capture')),
            );
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/dashboard-previews')
              ..createSync(recursive: true);
            File(
              '${directory.path}/$state-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
