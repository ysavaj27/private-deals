import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_view.dart';

import 'session_and_api_test.dart' show identity;

class _UploadController extends UploadPortfolioCtrl {
  int submissions = 0;
  int? submittedCompany;
  int? submittedInvestor;
  Completer<void>? pending;

  @override
  Future<void> getData() async {}

  @override
  Future<void> addData() async {
    submissions++;
    submittedCompany = selectedCompany().id;
    submittedInvestor = selectedInvestor().id;
    isUploading(true);
    if (pending != null) await pending!.future;
    isUploading(false);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _UploadController c;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    c = Get.put<UploadPortfolioCtrl>(_UploadController()) as _UploadController;
    c.investorList.assignAll([
      InvestorModel.fromJson({'id': 12, 'name': 'Aarav Shah'}),
    ]);
    c.model(
      CompanyStartupModel(
        startup: [CompanyStartup(id: 21, brandName: 'Northstar Technologies')],
        company: [CompanyStartup(id: 31, brandName: 'Summit Consumer Brands')],
      ),
    );
  });

  tearDown(() async {
    Get.reset();
    await app.clear();
  });

  Future<void> show(
    WidgetTester tester, {
    double width = 1280,
    double height = 1100,
    bool dark = false,
    double scale = 1,
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
          child: const RepaintBoundary(
            key: ValueKey('capture'),
            child: UploadPortfolioView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  void fill() {
    c.investorCTRL.text = 'Aarav Shah';
    c.companyCTRL.text = 'Northstar Technologies';
    c.qtyCTRL.text = '1000';
    c.sharePriceCTRL.text = '125.50';
    c.purchaseDateCTRL.text = '08-10-2026';
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).first);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Live summary calculates the purchase amount and reset clears it',
    (tester) async {
      await show(tester);
      fill();
      await tester.pumpAndSettle();
      expect(find.text('₹1,25,500.00'), findsOneWidget);
      expect(find.text('1,000 shares × ₹125.50'), findsOneWidget);
      expect(find.text('08-10-2026'), findsNWidgets(2));
      await tap(tester, 'Clear form');
      expect(c.qtyCTRL.text, isEmpty);
      expect(c.investorCTRL.text, isEmpty);
      expect(find.text('₹ —'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Invalid fields block submission and valid custom names clear stale IDs',
    (tester) async {
      await show(tester);
      await tap(tester, 'Add to portfolio');
      expect(c.submissions, 0);
      expect(find.text('Select an investor'), findsOneWidget);
      fill();
      c.investorCTRL.text = 'Someone else';
      await tap(tester, 'Add to portfolio');
      expect(c.submissions, 0);
      expect(
        find.text('Choose an investor from the search results'),
        findsOneWidget,
      );
      c.investorCTRL.text = ' Aarav Shah ';
      await tap(tester, 'Add to portfolio');
      expect(c.submissions, 1);
      expect(c.submittedInvestor, 12);
      expect(c.submittedCompany, 21);
      c.companyCTRL.text = 'Another Private Business';
      await tap(tester, 'Add to portfolio');
      expect(c.submissions, 2);
      expect(c.submittedCompany, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Switching asset class refreshes search and clears the previous holding on mobile',
    (tester) async {
      await show(tester, width: 390, height: 844);
      fill();
      await tester.pumpAndSettle();
      await tap(tester, 'Unlisted Company');
      expect(c.currentIndex(), DashboardTypeEnum.preIpo);
      expect(c.companyCTRL.text, isEmpty);
      expect(c.qtyCTRL.text, isEmpty);
      expect(find.text('Search unlisted companies'), findsOneWidget);
      expect(find.text('₹ —'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Access restrictions apply on mobile and no access has no submit action',
    (tester) async {
      app.wUser.isPrimaryAccess = false;
      app.wUser.isSecondaryAccess = false;
      c.currentIndex(DashboardTypeEnum.preIpo);
      await show(tester, width: 390);
      expect(find.text('Private Equity'), findsNothing);
      expect(find.text('Unlisted Company'), findsNWidgets(2));
      app.wUser.isPreIpoAccess = false;
      await tester.pumpWidget(const SizedBox());
      await show(tester, width: 390);
      expect(
        find.text('Portfolio upload is not available for your account.'),
        findsOneWidget,
      );
      expect(find.text('Add to portfolio'), findsNothing);
    },
  );

  testWidgets('Submission disables editing and repeat submit while pending', (
    tester,
  ) async {
    await show(tester);
    fill();
    c.pending = Completer<void>();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to portfolio'));
    await tester.pump();
    expect(c.submissions, 1);
    expect(find.text('Adding holding…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<AbsorbPointer>(
            find
                .descendant(
                  of: find.byType(UploadPortfolioView),
                  matching: find.byType(AbsorbPointer),
                )
                .first,
          )
          .absorbing,
      isTrue,
    );
    c.pending!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Add to portfolio'), findsOneWidget);
  });

  testWidgets('Date picker reopens on the chosen date', (tester) async {
    await show(tester);
    c.purchaseDateCTRL.text = '15-06-2024';
    await tester.ensureVisible(find.byKey(const ValueKey('portfolio-date')));
    await tester.tap(find.byKey(const ValueKey('portfolio-date')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DatePickerDialog>(find.byType(DatePickerDialog))
          .initialDate,
      DateTime(2024, 6, 15),
    );
    await tap(tester, 'Cancel');
    expect(c.purchaseDateCTRL.text, '15-06-2024');
  });

  testWidgets('Responsive layouts support light, dark and enlarged text', (
    tester,
  ) async {
    fill();
    c.companyCTRL.text =
        'Northstar Technologies and Financial Services Private Limited';
    for (final width in [320.0, 600.0, 1024.0, 1440.0]) {
      for (final dark in [false, true]) {
        await show(tester, width: width, height: 900, dark: dark, scale: 1.5);
        await tester.ensureVisible(find.text('Add to portfolio'));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'width=$width dark=$dark',
        );
      }
    }
  });

  testWidgets('Capture portfolio previews when requested', (tester) async {
    if (!const bool.fromEnvironment('PORTFOLIO_PREVIEWS')) return;
    await tester.runAsync(() async {
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        await (FontLoader(
          'inter',
        )..addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'))).load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    fill();
    for (final width in [390.0, 1280.0]) {
      for (final dark in [false, true]) {
        await show(
          tester,
          width: width,
          height: width == 390 ? 2100 : 1180,
          dark: dark,
        );
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('capture')),
          );
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('build/portfolio-previews')
            ..createSync(recursive: true);
          File(
            '${directory.path}/${width.toInt()}-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
        expect(tester.takeException(), isNull);
      }
    }
  });
}
