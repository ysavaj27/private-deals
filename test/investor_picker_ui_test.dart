import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/select_investor_dialog.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

const investors = [
  {
    'id': 1,
    'name': 'Aarav Shah',
    'email': 'aarav.shah@example.com',
    'mobile_number': 9876543210,
    'investor_type': 'Individual',
    'is_self': 1,
    'is_preipo_access': 1,
    'preipo_kyc_status': 1,
  },
  {
    'id': 2,
    'name': 'Meera Kapoor',
    'email': 'meera.kapoor@example.com',
    'mobile_number': 9876543211,
    'investor_type': 'Individual',
    'is_preipo_access': 1,
    'preipo_kyc_status': 0,
  },
  {
    'id': 3,
    'name': 'Northstar Ventures',
    'email': 'investments@example.com',
    'investor_type': 'Corporate',
    'is_preipo_access': 1,
    'preipo_kyc_status': 1,
  },
];

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'status': 1, 'data': investors}),
    );
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  Future<void> loadFonts(WidgetTester tester) async {
    await tester.runAsync(() async {
      final loader = FontLoader('inter');
      for (final weight in ['Regular', 'Medium', 'Bold']) {
        loader.addFont(rootBundle.load('assets/fonts/Roboto-$weight.ttf'));
      }
      await loader.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
  }

  Future<void> showPicker(
    WidgetTester tester, {
    double width = 1280,
    double height = 1000,
    bool dark = true,
    double scale = 1,
    Widget dialog = const SelectInvestorDialog(selectedInvestorIds: [1]),
    ValueChanged<Object?>? onResult,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(
      GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => RepaintBoundary(
          key: const ValueKey('picker-preview'),
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showCustomDialog(dialog);
                  onResult?.call(result);
                },
                child: const Text('Open investors'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open investors'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'search and filters preserve selections and return multiple investors',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      Object? selected;
      await showPicker(tester, onResult: (result) => selected = result);
      expect(find.text('AS'), findsOneWidget);
      expect(find.text('aarav.shah@example.com'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('investor-picker-search')),
        'investments@',
      );
      await tester.pumpAndSettle();
      expect(find.byType(InvestorSelectionCard), findsOneWidget);
      await tester.tap(find.text('Northstar Ventures'));
      await tester.pumpAndSettle();
      expect(find.text('Continue (2)'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear investor search'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KYC pending  1'));
      await tester.pumpAndSettle();
      expect(find.byType(InvestorSelectionCard), findsOneWidget);
      expect(
        tester
            .widget<InvestorSelectionCard>(find.byType(InvestorSelectionCard))
            .onSelect,
        isNull,
      );
      expect(find.text('Continue (2)'), findsOneWidget);
      await tester.tap(find.text('Continue (2)'));
      await tester.pumpAndSettle();
      expect((selected as List<InvestorModel>).map((item) => item.id), [1, 3]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('primary picker returns one investor and replaces selection', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    Object? selected;
    await showPicker(
      tester,
      dialog: const InvestorListDialog(),
      onResult: (result) => selected = result,
    );
    await tester.tap(find.text('Aarav Shah'));
    await tester.ensureVisible(find.text('Northstar Ventures'));
    await tester.tap(find.text('Northstar Ventures'));
    await tester.pumpAndSettle();
    final cards = tester.widgetList<InvestorSelectionCard>(
      find.byType(InvestorSelectionCard),
    );
    expect(cards.where((card) => card.selected).single.investor.id, 3);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect((selected as InvestorModel).id, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed load retries and empty search can be cleared', (
    tester,
  ) async {
    var fail = true;
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response(
        fail
            ? {'status': 0, 'message': 'Unavailable'}
            : {'status': 1, 'data': investors},
      ),
    );
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await showPicker(tester);
    expect(find.text('Investors unavailable'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('investor-picker-search')),
      'no-match',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching investors'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.byType(InvestorSelectionCard), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive theme previews and large text have no overflow', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await loadFonts(tester);
    for (final width in [1280.0, 390.0, 320.0]) {
      for (final dark in [true, false]) {
        await showPicker(
          tester,
          width: width,
          height: width == 320 ? 568 : 1000,
          dark: dark,
        );
        expect(tester.takeException(), isNull);
        if (width != 320) {
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('picker-preview')),
            );
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/investor-picker-${dark ? 'dark' : 'light'}-${width.toInt()}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.tap(find.byTooltip('Close investor selection'));
        await tester.pumpAndSettle();
      }
    }
    await showPicker(tester, width: 320, height: 640, scale: 1.5);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close investor selection'));
    await tester.pumpAndSettle();
    await showPicker(tester, width: 320, height: 568);
    await tester.tap(find.byKey(const ValueKey('investor-picker-search')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(
      find.byKey(const ValueKey('investor-picker-search')),
      'Aarav',
    );
    await tester.pumpAndSettle();
    expect(find.byType(InvestorSelectionCard), findsOneWidget);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey('investor-picker-search')),
          )
          .controller!
          .text,
      'Aarav',
    );
    await tester.ensureVisible(find.byTooltip('Close investor selection'));
    await tester.tap(find.byTooltip('Close investor selection'));
    await tester.pumpAndSettle();
    await showPicker(
      tester,
      width: 390,
      height: 844,
      dialog: const EnquiryDecisionDialog(
        action: 'accept',
        institution: false,
        companyName: 'Northstar Technologies',
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
