import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_sections.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment_panel.dart';
import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

StartupModel _startup({
  String instrument = 'equity',
  String status = 'raisingnow',
  bool empty = false,
}) => StartupModel.fromJson({
  'id': 42,
  'brand_name': 'Northstar Technologies',
  'company_name': 'Northstar Technologies Private Limited',
  'url_slug': 'northstar',
  'brief_information': empty ? '' : 'Building the next generation of digital infrastructure for Indian businesses. Northstar brings payments, cloud operations, and customer insights together in one platform.',
  'city': {'name': 'Bengaluru'},
  'sector': {'name': 'Enterprise technology'},
  'legal_info': {
    'cin': 'U72900KA2020PTC123456',
    'incorporation_date': '2020-06-15',
  },
  'cms': empty
      ? <String, dynamic>{}
      : {
          'one_liner': 'The operating platform for ambitious businesses.',
          'idea': '<h3>Built for a connected economy</h3><p>Northstar helps businesses simplify their operations and serve customers at scale. Its products connect teams, data, and financial services.</p><p>With a focus on enterprise customers, the company is expanding its product suite and presence across India.</p>',
          'key_information': '<h3>Business model</h3><p>Recurring subscriptions and usage-based services support the company’s growth.</p><ul><li>Cloud software for enterprise teams</li><li>Growing customer relationships</li><li>Investment in product and distribution</li></ul>',
          'website': 'https://example.com/Northstar',
          'pitch_deck': 'https://example.com/PitchDeck.pdf?token=CaseSensitive',
        },
  'raising_round': {
    'id': 7,
    'name': 'Series A',
    'round_status': status,
    'instrument': instrument,
    'floor': 500000000,
    'cap': 750000000,
    'share_price': 1250,
    'equity_offered': 10,
    'minimum_investment': 250000,
    'fund_requirement': 10000000,
    'total_fund_requirement': 50000000,
  },
  if (!empty)
    'team_members': [
      {
        'name': 'Aarav Shah',
        'designation': 'Co-founder & Chief Executive Officer',
        'brief_information': 'A decade of experience building enterprise software and leading product teams.',
        'linkedin_url': 'https://example.com/Aarav',
      },
      {
        'name': 'Priya Mehta',
        'designation': 'Co-founder & Chief Technology Officer',
        'brief_information': 'Leads engineering and infrastructure with a focus on reliability and scale.',
      },
    ],
  if (!empty)
    'updates': [
      {
        'title': 'Expanding our product platform',
        'description': 'The team has launched a new suite of tools for growing businesses.',
        'created_at': '2026-09-01',
      },
    ],
  if (!empty)
    'portfolio': [
      {
        'name': 'Meridian Ventures',
        'total_invested': 1000000,
        'profile_visibility': 'public',
      },
      {
        'name': 'Private investor identity',
        'total_invested': 500000,
        'profile_visibility': 'private',
        'profile_photo': 'https://example.com/private.jpg',
      },
    ],
  if (!empty)
    'faqs': [
      {
        'question': 'How will the funds be used?',
        'answer':
            'The funds will support product development and market expansion.',
      },
    ],
});

class _Controller extends PrimaryDetailPageCtrl {
  _Controller(StartupModel model) {
    startupDetailModel(model);
  }
  int refreshes = 0;
  @override
  void onInit() {
    super.onInit();
    refreshes = 0;
  }

  @override
  Future<void> getData() async {
    refreshes++;
    loadError('');
  }
}

Future<_Controller> _pump(
  WidgetTester tester, {
  double width = 1280,
  double height = 1000,
  bool dark = true,
  double scale = 1,
  StartupModel? model,
}) async {
  await tester.pumpWidget(const SizedBox());
  Get.reset();
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  await tester.runAsync(() async {
    for (final family in ['inter', 'roboto']) {
      final fonts = FontLoader(family);
      for (final weight in ['Regular', 'Medium', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
      }
      await fonts.load();
    }
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  final c = _Controller(model ?? _startup());
  Get.put<PrimaryDetailPageCtrl>(c, permanent: true);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/startup/northstar',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: RepaintBoundary(
          key: const ValueKey('primary-preview'),
          child: child!,
        ),
      ),
      getPages: [
        GetPage(
          name: '/startup/northstar',
          page: () => PrimaryDetailView(phone: width < 600),
        ),
        GetPage(
          name: '/startup/northstar/investment/:id',
          page: () => const Scaffold(body: Text('Existing investment flow')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> _navigate(WidgetTester tester, int index) async {
  final tab = find.byKey(ValueKey('primary-nav-$index'));
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

void main() {
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  final originalConfig = app.config;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    app.configModel(
      ConfigModel.fromJson({
        'enum': {
          'instrument_type': {'equity': 'equity', 'ccps': 'ccps', 'ccd': 'ccd'},
          'startup_primary_round_status': {
            'raisingnow': 'raisingnow',
            'completed': 'completed',
          },
          'investor_profile_visibility': {
            'Private': 'private',
            'public': 'public',
          },
        },
      }),
    );
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': [
          {
            'id': 1,
            'uuid': 'investor-1',
            'name': 'Aarav Shah',
            'investor_type': 'Individual',
            'is_preipo_access': 1,
            'preipo_kyc_status': 1,
          },
        ],
      }),
    );
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
    app.configModel(originalConfig);
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  testWidgets('responsive themes, section navigation and enlarged text', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final width in [320.0, 390.0, 800.0, 1280.0, 1600.0]) {
      for (final dark in [false, true]) {
        await _pump(
          tester,
          width: width,
          dark: dark,
          scale: width == 320 ? 1.4 : 1,
        );
        expect(find.text('Northstar Technologies'), findsOneWidget);
        expect(find.byType(PrimaryInvestmentPanel), findsOneWidget);
        expect(tester.takeException(), isNull);
        if ((width == 1280 || width == 390) &&
            const bool.fromEnvironment('CAPTURE_PRIMARY_UI')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('primary-preview')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/primary-detail-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await _navigate(tester, 6);
        final documentsY = tester.getTopLeft(find.text('Documents').last).dy;
        expect(documentsY, greaterThan(80));
        expect(documentsY, lessThan(400));
        expect(tester.takeException(), isNull);
        await _navigate(tester, 0);
        expect(
          tester.getTopLeft(find.text('Northstar Technologies')).dy,
          lessThan(200),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets(
    'bottom scrolling and section navigation do not rebuild page content',
    (tester) async {
      await _pump(tester, width: 1280);
      var contentRebuilds = 0;
      var tabRebuilds = 0;
      final previousCallback = debugOnRebuildDirtyWidget;
      debugOnRebuildDirtyWidget = (element, builtOnce) {
        previousCallback?.call(element, builtOnce);
        // Installed after the initial frame, so every callback is subsequent work.
        if (element.widget is PrimaryDetailView ||
            element.widget is PrimaryDetailSections)
          contentRebuilds++;
        if (element.widget is ValueListenableBuilder<int>) tabRebuilds++;
      };
      addTearDown(() => debugOnRebuildDirtyWidget = previousCallback);
      await _navigate(tester, 6);
      final scroll = tester
          .widget<SingleChildScrollView>(
            find.byKey(const ValueKey('primary-details-scroll')),
          )
          .controller!;
      for (var i = 0; i < 4; i++) {
        scroll.jumpTo(scroll.position.maxScrollExtent - 120);
        await tester.pump();
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await tester.pump();
      }
      expect(tabRebuilds, greaterThan(0));
      expect(contentRebuilds, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('round types and unavailable rounds keep their correct terms', (
    tester,
  ) async {
    for (final instrument in ['equity', 'ccps', 'ccd']) {
      await _pump(tester, model: _startup(instrument: instrument));
      expect(
        find.text(instrument == 'equity' ? 'Valuation' : 'Valuation floor'),
        findsOneWidget,
      );
      expect(
        find.text('Valuation cap'),
        instrument == 'equity' ? findsNothing : findsOneWidget,
      );
      expect(find.byKey(const ValueKey('primary-invest-now')), findsOneWidget);
    }
    for (final status in [
      'completed',
      'pending',
      'comingsoon',
      'unknown',
      '',
    ]) {
      final c = await _pump(tester, model: _startup(status: status));
      expect(find.byKey(const ValueKey('primary-invest-now')), findsNothing);
      await c.startInvestment();
      await tester.pumpAndSettle();
      expect(find.byType(InvestorPickerDialog), findsNothing);
    }
  });

  testWidgets('preserves investor privacy, FAQs, and document availability', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Private investor identity'), findsNothing);
    expect(find.text('Anonymous'), findsOneWidget);
    expect(find.text('Meridian Ventures'), findsOneWidget);
    await _navigate(tester, 5);
    await tester.tap(find.text('How will the funds be used?'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'The funds will support product development and market expansion.',
      ),
      findsOneWidget,
    );
    await _navigate(tester, 6);
    expect(find.text('View document'), findsOneWidget);
    expect(find.text('Not available'), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'document cards keep equal sizes and missing files are disabled',
    (tester) async {
      for (final width in [320.0, 1280.0, 1600.0]) {
        await _pump(tester, width: width, scale: width == 320 ? 1.4 : 1);
        await _navigate(tester, 6);
        final cards = find.byWidgetPredicate(
          (widget) =>
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>).value.startsWith(
                'primary-document-card-',
              ),
        );
        expect(cards, findsNWidgets(6));
        final sizes = tester
            .widgetList(cards)
            .map((widget) => tester.getSize(find.byKey(widget.key!)))
            .toList();
        expect(sizes.every((size) => size == sizes.first), isTrue);
        if (const bool.fromEnvironment('CAPTURE_PRIMARY_UI')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('primary-preview')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('/tmp/primary-documents-${width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        final missing = tester.widget<TextButton>(
          find.byKey(const ValueKey('primary-document-Financial projections')),
        );
        expect(missing.onPressed, isNull);
        final available = tester.widget<TextButton>(
          find.byKey(const ValueKey('primary-document-Pitch deck')),
        );
        expect(available.onPressed, isNotNull);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets('scroll selection does not rebuild the detail content', (
    tester,
  ) async {
    await _pump(tester);
    final sections = tester.widget<PrimaryDetailSections>(
      find.byType(PrimaryDetailSections),
    );
    await _navigate(tester, 6);
    expect(
      identical(
        tester.widget<PrimaryDetailSections>(
          find.byType(PrimaryDetailSections),
        ),
        sections,
      ),
      isTrue,
    );
    final scroll = tester
        .widget<SingleChildScrollView>(
          find.byKey(const ValueKey('primary-details-scroll')),
        )
        .controller!;
    scroll.jumpTo(0);
    await tester.pumpAndSettle();
    expect(
      identical(
        tester.widget<PrimaryDetailSections>(
          find.byType(PrimaryDetailSections),
        ),
        sections,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty sections and load failures have usable states', (
    tester,
  ) async {
    final c = await _pump(tester, model: _startup(empty: true));
    expect(find.text('Team profiles are not available yet.'), findsOneWidget);
    expect(find.text('There are no company updates yet.'), findsOneWidget);
    expect(find.text('Not available'), findsNWidgets(6));
    c.loadError('Could not load startup');
    await tester.pumpAndSettle();
    expect(find.text('Startup details are unavailable'), findsOneWidget);
    expect(find.byType(PrimaryInvestmentPanel), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(c.refreshes, 1);
    expect(find.byType(PrimaryInvestmentPanel), findsOneWidget);
    c.isLoading(true);
    await tester.pump();
    expect(find.byType(Loader), findsOneWidget);
    c.isLoading(false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('investment guards loading, errors and missing identifiers', (
    tester,
  ) async {
    final c = await _pump(tester);
    for (final state in ['loading', 'error', 'startup', 'round', 'config']) {
      c.isLoading(state == 'loading');
      c.loadError(state == 'error' ? 'Unavailable' : '');
      final model = _startup();
      if (state == 'startup') model.id = 0;
      if (state == 'round') model.raisingRound.id = 0;
      if (state == 'config') app.configModel(ConfigModel.fromJson({}));
      c.startupDetailModel(model);
      expect(c.canInvest, isFalse, reason: state);
      await c.startInvestment();
      await tester.pump();
      expect(find.byType(InvestorPickerDialog), findsNothing);
    }
    c.isLoading(false);
    await tester.pumpAndSettle();
  });

  testWidgets('rechecks round and investor eligibility after selection', (
    tester,
  ) async {
    for (final scenario in [
      'closed',
      'changed-round',
      'pending-kyc',
      'missing-uuid',
      'cancelled',
    ]) {
      final c = await _pump(tester);
      final opening = c.startInvestment();
      await tester.pumpAndSettle();
      await c.startInvestment(); // A second click must not open another picker.
      expect(find.byType(InvestorPickerDialog), findsOneWidget);
      if (scenario == 'closed') {
        c.startupDetailModel(_startup(status: 'completed'));
      }
      if (scenario == 'changed-round') {
        final changed = _startup();
        changed.raisingRound.id = 8;
        c.startupDetailModel(changed);
      }
      Get.back(
        result: scenario == 'cancelled'
            ? null
            : InvestorModel.fromJson({
                'id': 1,
                'uuid': scenario == 'missing-uuid' ? '' : 'investor-1',
                'preipo_kyc_status': scenario == 'pending-kyc' ? 0 : 1,
              }),
      );
      await tester.pumpAndSettle();
      await opening;
      expect(Get.currentRoute, '/startup/northstar', reason: scenario);
      expect(c.isOpeningInvestment.value, isFalse);
      expect(find.text('Existing investment flow'), findsNothing);
    }
  });

  testWidgets('investment retains investor selection and refreshes on return', (
    tester,
  ) async {
    final c = await _pump(tester);
    final invest = find.byKey(const ValueKey('primary-invest-now'));
    await tester.ensureVisible(invest);
    await tester.tap(invest);
    await tester.pumpAndSettle();
    expect(find.byType(InvestorPickerDialog), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(InvestorPickerDialog),
        matching: find.text('Aarav Shah'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Existing investment flow'), findsOneWidget);
    expect(Get.currentRoute, '/startup/northstar/investment/investor-1');
    Get.back(result: true);
    await tester.pumpAndSettle();
    expect(c.refreshes, 1);
    expect(c.isOpeningInvestment.value, isFalse);
    expect(tester.takeException(), isNull);
  });
}
