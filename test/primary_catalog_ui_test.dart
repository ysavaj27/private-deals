import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter/rendering.dart';
import 'package:private_deals/src/features/catalog/presentation/widgets/catalog_article_card.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/blog_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart'
    show AutoScrollSectorList, CustomTabBar;
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/phone_pre_ipo_landing_view.dart'
    show PhoneNewsWidget;
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_content.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_startup_card.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/blog_detail/blog_detail_page.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;
import 'controller_lifecycle_test.dart' show pumpRequest;

StartupRoundModel _round(
  String name, {
  String status = 'Raising Now',
  String sector = 'Technology',
}) => StartupRoundModel.fromJson({
  'id': 7,
  'round_status': status,
  'startup': {
    'id': 42,
    'brand_name': name,
    'url_slug': name.toLowerCase().replaceAll(' ', '-'),
    'company_name': '$name Private Limited',
    'brief_information': 'Building products that simplify everyday business and create new opportunities for growth.',
    'sector': {'name': sector},
    'city': {'name': 'Bengaluru'},
    'raising_round': {
      'instrument': 'equity',
      'minimum_investment': 250000,
      'share_price': 1250,
      'total_fund_requirement': 50000000,
    },
  },
});

final _blogJson = <String, dynamic>{
  'id': 1,
  'url_slug': 'understanding-startups',
  'title': 'Understanding the startup journey',
  'short_description':
      'A closer look at the stages of building and funding a business.',
  'long_description': '<h2>From idea to growth</h2><p>Every company has a story. Understand the business, the team, and the opportunity.</p>',
  'created_at': '2026-10-01',
};

class _Landing extends PrimaryLandingPageCtrl {
  _Landing() {
    model(LandingPageModel.fromJson({}));
    model().raisingNow = [
      _round('Northstar Technologies'),
      _round('Greenfield Energy', sector: 'Clean energy'),
      _round('Atlas Health', sector: 'Healthcare'),
    ];
    model().comingSoon = [_round('Orbit Labs', status: 'Coming Soon')];
    model().completed = [_round('Meridian Ventures', status: 'Completed')];
    sectors.assignAll([
      SectorModel(
        name: 'Technology',
        slug: 'technology',
        companyCount: 8,
        companies: List.generate(
          5,
          (i) => SectorCompanyModel(brandName: 'Company $i'),
        ),
      ),
      SectorModel(name: 'Clean energy', slug: 'clean-energy'),
      SectorModel(name: 'Healthcare', slug: 'healthcare'),
    ]);
    blogs.assignAll([BlogModel.fromJson(_blogJson)]);
  }
  @override
  Future<void> getData() async {}
  @override
  Future<void> blogList() async {}
  @override
  Future<void> sectorList() async {}
}

class _List extends PrimaryListPageCtrl {
  _List() {
    list.assignAll([
      _round('Northstar Technologies'),
      _round('Greenfield Energy', sector: 'Clean energy'),
    ]);
  }
  @override
  Future<void> getData() async {}
}

Future<void> _pump(
  WidgetTester tester, {
  bool list = false,
  double width = 1280,
  bool dark = false,
  double scale = 1,
}) async {
  addTearDown(() => tester.pumpWidget(const SizedBox()));
  await tester.pumpWidget(const SizedBox());
  Get.reset();
  tester.view.physicalSize = Size(width, 1000);
  tester.view.devicePixelRatio = 1;
  Get.put<PrimaryLandingPageCtrl>(_Landing());
  Get.put<PrimaryListPageCtrl>(_List());
  await tester.pumpWidget(
    GetMaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/catalog',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(
          key: const ValueKey('catalog-preview'),
          child: child!,
        ),
      ),
      getPages: [
        GetPage(
          name: '/catalog',
          page: () =>
              list ? const PrimaryListView() : const PrimaryLandingView(),
        ),
        GetPage(
          name: '/wealth-manager/private-equity/detail/:slug',
          page: () => const Scaffold(body: Text('Startup detail destination')),
        ),
        GetPage(
          name: '/wealth-manager/private-equity/startup-list/:slug',
          page: () => const PrimaryListView(),
        ),
        GetPage(
          name: '/catalog/blog-detail/:slug',
          page: () => const BlogDetailPage(),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _revealLanding(WidgetTester tester, Finder target) async {
  final scroll = Get.find<PrimaryLandingPageCtrl>().scrollController;
  for (var attempt = 0; target.evaluate().isEmpty && attempt < 30; attempt++) {
    scroll.jumpTo(
      (scroll.offset + 500).clamp(0, scroll.position.maxScrollExtent),
    );
    await tester.pump();
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_PRIMARY_CATALOG')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('catalog-preview')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('/tmp/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  final adapter = dioConfig.dio.httpClientAdapter;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'status': 1, 'data': _blogJson}),
    );
  });
  tearDown(() async {
    Get.reset();
    await app.clear();
    dioConfig.dio.httpClientAdapter = adapter;
  });

  testWidgets('landing and list adapt to mobile, desktop, themes and large text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      for (final family in ['inter', 'roboto']) {
        final fonts = FontLoader(family);
        for (final weight in ['Regular']) {
          fonts.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
        }
        await fonts.load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    for (final list in [false, true]) {
      for (final width in [320.0, 390.0, 800.0, 1280.0, 1600.0]) {
        for (final dark in [false, true]) {
          await _pump(
            tester,
            list: list,
            width: width,
            dark: dark,
            scale: width == 320 ? 1.4 : 1,
          );
          expect(find.text('Northstar Technologies'), findsOneWidget);
          expect(find.text('Share price'), findsWidgets);
          expect(tester.takeException(), isNull);
          if (width == 390 || width == 1280) {
            await _capture(
              tester,
              'primary-${list ? 'list' : 'landing'}-${width.toInt()}-${dark ? 'dark' : 'light'}',
            );
          }
          if (!list) {
            await _revealLanding(tester, find.byType(PrimaryArticles));
            expect(tester.takeException(), isNull);
            if (width == 390 || width == 1280) {
              await _capture(
                tester,
                'primary-sections-${width.toInt()}-${dark ? 'dark' : 'light'}',
              );
            }
          }
        }
      }
    }
  });

  testWidgets(
    'large startup lists build on demand and retain search after scrolling',
    (tester) async {
      await _pump(tester, list: true, width: 390);
      final c = Get.find<PrimaryListPageCtrl>();
      c.list.assignAll(List.generate(1000, (i) => _round('Startup $i')));
      await tester.pumpAndSettle();
      expect(find.byType(PrimaryStartupCard).evaluate().length, lessThan(10));
      expect(find.text('Startup 999'), findsNothing);
      c.scrollController.jumpTo(c.scrollController.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(find.text('Startup 999'), findsOneWidget);
      expect(find.byType(PrimaryStartupCard).evaluate().length, lessThan(10));
      await tester.enterText(
        find.byKey(const ValueKey('primary-list-search')),
        'Startup 42',
      );
      await tester.pumpAndSettle();
      c.scrollController.jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('11 startups'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PrimaryStartupCard),
          matching: find.text('Startup 42'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'landing keeps its preview bounded and builds later sections on scroll',
    (tester) async {
      await _pump(tester, width: 390);
      final c = Get.find<PrimaryLandingPageCtrl>();
      c.model().raisingNow = List.generate(1000, (i) => _round('Startup $i'));
      c.model.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(PrimaryStartupCard).evaluate().length, lessThan(6));
      expect(find.byType(PrimaryBlogCard), findsNothing);
      await _revealLanding(tester, find.byType(PrimaryBlogCard));
      expect(find.byType(CatalogArticleCard), findsOneWidget);
      expect(find.text('Startup 999'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'empty tabs hide and selection falls back without search hiding tabs',
    (tester) async {
      await _pump(tester);
      final c = Get.find<PrimaryLandingPageCtrl>();
      c.tab(PrimaryCatalogTab.comingSoon);
      c.model().comingSoon.clear();
      c.model.refresh();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('primary-tab-comingsoon')),
        findsNothing,
      );
      expect(c.selectedTab, PrimaryCatalogTab.raisingNow);
      expect(find.text('Northstar Technologies'), findsOneWidget);
      c.model().raisingNow.clear();
      c.model.refresh();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('primary-tab-raisingnow')),
        findsNothing,
      );
      expect(c.selectedTab, PrimaryCatalogTab.completed);
      await tester.enterText(
        find.byKey(const ValueKey('primary-catalog-search')),
        'absent',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('primary-tab-completed')),
        findsOneWidget,
      );
      c.model().completed.clear();
      c.model.refresh();
      await tester.pumpAndSettle();
      expect(find.byType(CustomTabBar<PrimaryCatalogTab>), findsNothing);
      expect(find.text('Explore completed'), findsNothing);
    },
  );

  testWidgets(
    'missing descriptions and completed metrics keep equal card heights',
    (tester) async {
      await _pump(tester, list: true);
      final c = Get.find<PrimaryListPageCtrl>();
      final missing = _round('Completed company', status: 'Completed');
      missing.startup.briefInformation = '';
      missing.startup.raisingRound.totalFundRequirement = 0;
      missing.startup.raisingRound.minimumInvestment = 0;
      missing.startup.raisingRound.sharePrice = 0;
      c.list.assignAll([_round('Described company'), missing]);
      await tester.pumpAndSettle();
      final cards = find.byType(PrimaryStartupCard);
      expect(
        tester.getSize(cards.at(0)).height,
        tester.getSize(cards.at(1)).height,
      );
      final completedCard = find.descendant(
        of: cards.at(1),
        matching: find.text('Round size'),
      );
      expect(completedCard, findsNothing);
      expect(find.text('Investors'), findsNothing);
      expect(find.text('Round details are not available yet.'), findsOneWidget);
      // A price provided on the actual round is still useful when raising_round is empty.
      missing.sharePrice = 750;
      c.list.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Share price'), findsNWidgets(2));
      expect(find.text('Round details are not available yet.'), findsNothing);
    },
  );

  testWidgets(
    'sector strip auto-scrolls, pauses after dragging and disposes timers',
    (tester) async {
      await _pump(tester, width: 390);
      final strip = find.byType(AutoScrollSectorList);
      await _revealLanding(tester, strip);
      await tester.pumpAndSettle();
      final horizontal = find.descendant(
        of: strip,
        matching: find.byType(ListView),
      );
      final controller = tester.widget<ListView>(horizontal).controller!;
      final initial = controller.offset;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 1300));
      expect(controller.offset, greaterThan(initial));
      await tester.drag(horizontal, const Offset(80, 0));
      await tester.pumpAndSettle();
      final paused = controller.offset;
      await tester.pump(const Duration(seconds: 2));
      expect(controller.offset, closeTo(paused, .01));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('blog landing, blog list and news use the same article card', (
    tester,
  ) async {
    await _pump(tester);
    await _revealLanding(tester, find.byType(PrimaryBlogCard));
    expect(
      find.descendant(
        of: find.byType(PrimaryBlogCard),
        matching: find.byType(CatalogArticleCard),
      ),
      findsOneWidget,
    );
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [_blogJson],
      }),
    );
    await tester.pumpWidget(const SizedBox());
    Get.reset();
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const BlogListPage()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CatalogArticleGrid), findsOneWidget);
    expect(find.byType(PrimaryBlogCard), findsOneWidget);
    expect(find.byType(CatalogArticleCard), findsOneWidget);
    expect(find.text('Read More'), findsOneWidget);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhoneNewsWidget(
            list: [
              NewsModel.fromJson({
                'title': 'News title',
                'description': 'News description',
                'created_at': '2026-10-01',
              }),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CatalogArticleCard), findsOneWidget);
    expect(find.text('Read More'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status tabs and search keep company groups separate', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.byType(CustomTabBar<PrimaryCatalogTab>), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('primary-tab-comingsoon')));
    await tester.pumpAndSettle();
    expect(find.text('Orbit Labs'), findsOneWidget);
    expect(find.text('Northstar Technologies'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('primary-tab-completed')));
    await tester.pumpAndSettle();
    expect(find.text('Meridian Ventures'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('primary-tab-raisingnow')));
    await tester.enterText(
      find.byKey(const ValueKey('primary-catalog-search')),
      'clean energy',
    );
    await tester.pumpAndSettle();
    expect(find.byType(PrimaryStartupCard), findsOneWidget);
    expect(find.text('Greenfield Energy'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('primary-catalog-search')),
      'missing',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching startups'), findsOneWidget);
  });

  testWidgets('list filters by company and sector and opens startup detail', (
    tester,
  ) async {
    await _pump(tester, list: true);
    await tester.enterText(
      find.byKey(const ValueKey('primary-list-search')),
      'Northstar',
    );
    await tester.pumpAndSettle();
    expect(find.byType(PrimaryStartupCard), findsOneWidget);
    await tester.tap(find.text('View startup'));
    await tester.pumpAndSettle();
    expect(
      Get.currentRoute,
      '/wealth-manager/private-equity/detail/northstar-technologies',
    );
    expect(find.text('Startup detail destination'), findsOneWidget);
  });

  testWidgets('coming-soon cards without a pitch use startup details', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byKey(const ValueKey('primary-tab-comingsoon')));
    await tester.pumpAndSettle();
    expect(find.text('Watch pitch'), findsNothing);
    await tester.tap(find.text('View startup'));
    await tester.pumpAndSettle();
    expect(
      Get.currentRoute,
      '/wealth-manager/private-equity/detail/orbit-labs',
    );
  });

  testWidgets('explore and sector links retain the correct list context', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('Explore Raising now'));
    await tester.pumpAndSettle();
    expect(
      Get.currentRoute,
      '/wealth-manager/private-equity/startup-list/raisingnow',
    );
    expect(Get.parameters['slug'], 'raisingnow');
    await _pump(tester);
    final sector = find.text('Technology');
    await _revealLanding(tester, sector);
    await tester.tap(sector);
    await tester.pumpAndSettle();
    expect(
      Get.currentRoute,
      '/wealth-manager/private-equity/startup-list/technology',
    );
    expect(Get.parameters['slug'], 'technology');
  });

  testWidgets('failed and empty sections stay usable independently', (
    tester,
  ) async {
    await _pump(tester);
    final c = Get.find<PrimaryLandingPageCtrl>();
    c.loadError('Load failed');
    await tester.pumpAndSettle();
    expect(find.text('Startups are unavailable'), findsOneWidget);
    expect(find.byType(PrimaryBlogCard), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    c.loadError('');
    c.model(LandingPageModel.fromJson({}));
    c.blogs.clear();
    c.sectors.clear();
    await tester.pumpAndSettle();
    expect(find.text('No startups here yet'), findsOneWidget);
    expect(find.text('New insights are on the way'), findsOneWidget);
    c.isLoading(true);
    await tester.pump();
    expect(find.byType(Loader), findsOneWidget);
    c.isLoading(false);
    await tester.pumpAndSettle();
  });

  testWidgets('blog cards open the detail route with fetched full content', (
    tester,
  ) async {
    await _pump(tester, width: 390);
    final card = find.byType(PrimaryBlogCard);
    await _revealLanding(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(
      Get.currentRoute,
      '/catalog/blog-detail/understanding-startups',
    );
    expect(find.byType(BlogDetailPage), findsOneWidget);
    expect(find.text('From idea to growth'), findsOneWidget);
    await _capture(tester, 'primary-blog-mobile');
    await tester.tap(find.byTooltip('Back to startups'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/catalog');
    expect(find.byType(BlogArticleReader), findsNothing);
  });

  testWidgets(
    'blog deep links fetch the article and failed requests can retry',
    (tester) async {
      var attempts = 0;
      dioConfig.dio.httpClientAdapter = FakeAdapter((options) async {
        expect(options.queryParameters['url_slug'], 'understanding-startups');
        attempts++;
        return response(
          attempts == 1
              ? {'status': 0, 'message': 'Unavailable'}
              : {'status': 1, 'data': _blogJson},
        );
      });
      await _pump(tester);
      Get.toNamed('/catalog/blog-detail/understanding-startups');
      await tester.pumpAndSettle();
      expect(find.text('This article is unavailable'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('From idea to growth'), findsOneWidget);
      expect(attempts, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'closing a blog during its request does not update disposed state',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final started = Completer<void>();
      dioConfig.dio.httpClientAdapter = FakeAdapter((_) {
        started.complete();
        return pending.future;
      });
      await _pump(tester);
      final c = Get.find<PrimaryLandingPageCtrl>();
      showBlogDetailBottomSheet(
        tester.element(find.byType(PrimaryLandingView)),
        blog: c.blogs.first,
      );
      await pumpRequest(tester, started.future);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byTooltip('Close article'));
      await tester.pumpAndSettle();
      pending.complete(response({'status': 1, 'data': _blogJson}));
      await tester.pumpAndSettle();
      expect(find.byType(BlogArticleReader), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
