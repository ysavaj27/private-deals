import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/pending_tasks_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/earnings_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_view.dart';

class _PendingController extends KycPendingInvestorPageCtrl {
  @override
  Future<void> selectType(PendingTaskEnum selected) async => type(selected);
  @override
  Future<void> refreshData() async {
    error('');
  }
}

class _EarningsController extends MyEarningPageCtrl {
  @override
  Future<void> selectType(MyEarningTypeEnum selected) async =>
      currentIndex(selected);
  @override
  Future<void> refreshData() async {
    error('');
  }
}

class _MisController extends MISPageCtrl {
  @override
  Future<void> getData() async {
    error('');
  }
}

void main() {
  late _PendingController pending;
  late _EarningsController earnings;
  late _MisController mis;
  setUp(() {
    Get.testMode = true;
    pending = _PendingController();
    earnings = _EarningsController();
    mis = _MisController();
    Get.put<KycPendingInvestorPageCtrl>(pending);
    Get.put<MyEarningPageCtrl>(earnings);
    Get.put<MISPageCtrl>(mis);
    pending.pendingTask(
      PendingTaskModel(pendingKyc: 2, documentSign: 1, pendingPayment: 1),
    );
    pending.investorList.assignAll([
      InvestorModel(
        name: 'Aarav Shah',
        email: 'aarav@example.com',
        mobileNumber: 9876543210,
        investorType: 'Individual',
      ),
      InvestorModel(
        name: 'Priya Mehta',
        email: 'priya.mehta@example.com',
        mobileNumber: 9876543211,
        investorType: 'Individual',
      ),
    ]);
    pending.transactions.assignAll([
      PrimaryTransactionModel.fromJson({
        'startup': {'brand_name': 'Northstar Technologies'},
        'investor': {'name': 'Priya Mehta'},
        'investment_amount': 1250000,
        'current_status': 'Awaiting investor signature',
        'next_step': 'Sign the subscription agreement',
        'percentage': 45,
      }),
    ]);
    earnings.investor(
      InvestorEarningModel.fromJson({
        'total_investors': 2,
        'total_investment': 7500000,
        'commission_earned': 150000,
        'investors_list': [
          {
            'name': 'Aarav Shah',
            'total_investment': 2500000,
            'commission_earned': 50000,
          },
          {
            'name': 'Priya Mehta',
            'total_investment': 5000000,
            'commission_earned': 100000,
          },
        ],
      }),
    );
    earnings.partner(
      PartnerEarningModel.fromJson({
        'total_partners': 1,
        'total_investment': 10000000,
        'total_commission_earned': 80000,
        'list': [
          {
            'name': 'Summit Wealth Partners',
            'partner_total_investment': 10000000,
            'commission_earned_from_this_partner': 80000,
          },
        ],
      }),
    );
    mis.list.assignAll([
      WMisModel.fromJson({
        'startup_id': 1,
        'startup_name': 'Northstar Technologies',
        'approved_mis': [
          {
            'id': 1,
            'title': 'Quarterly business update',
            'description':
                'Operating performance, company milestones and financial highlights.',
            'created_at': '2026-09-30',
            'document': '',
          },
          {
            'id': 2,
            'title': 'Annual review',
            'description': 'A review of the year.',
            'created_at': '2026-03-31',
            'document': 'https://example.com/report.pdf',
          },
        ],
      }),
      WMisModel(startupId: 2, startupName: 'Bharat Infrastructure'),
    ]);
  });
  tearDown(() => Get.reset());

  Future<void> show(
    WidgetTester tester,
    Widget child, {
    double width = 1200,
    bool dark = false,
    double scale = 1,
  }) async {
    await tester.runAsync(() async {
      for (final family in ['inter', 'roboto']) {
        final loader = FontLoader(family);
        for (final weight in ['Regular', 'Medium', 'Bold']) {
          final bytes = await rootBundle.load(
            'assets/fonts/${family == 'inter' ? 'Inter' : 'Roboto'}-$weight.ttf',
          );
          loader.addFont(
            bytes.lengthInBytes > 0
                ? Future.value(bytes)
                : rootBundle.load('assets/fonts/Roboto-$weight.ttf'),
          );
        }
        await loader.load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1100),
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

  for (final width in [360.0, 760.0, 1280.0]) {
    for (final dark in [false, true]) {
      testWidgets('Workspace screens render at $width, dark=$dark', (
        tester,
      ) async {
        for (final entry in <String, Widget>{
          'pending': const PendingTasksView(),
          'earnings': const EarningsView(),
          'mis': const MisView(),
        }.entries) {
          await show(
            tester,
            entry.value,
            width: width,
            dark: dark,
            scale: width == 760 ? 1.5 : 1,
          );
          expect(tester.takeException(), isNull, reason: entry.key);
          if (const bool.fromEnvironment('CAPTURE_WORKSPACE')) {
            await tester.runAsync(() async {
              final boundary = tester.renderObject<RenderRepaintBoundary>(
                find.byKey(const ValueKey('capture')),
              );
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final directory = Directory('build/workspace-previews')
                ..createSync(recursive: true);
              File(
                '${directory.path}/${entry.key}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
              ).writeAsBytesSync(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    }
  }

  testWidgets(
    'Pending categories show real investor and progress; counts update',
    (tester) async {
      await show(tester, const PendingTasksView());
      expect(find.text('Aarav Shah'), findsOneWidget);
      await tester.tap(find.text('Document signing'));
      await tester.pumpAndSettle();
      expect(find.text('Priya Mehta'), findsOneWidget);
      expect(find.text('Kedar Dave'), findsNothing);
      expect(find.text('45% completed'), findsOneWidget);
      expect(find.text('Sign the subscription agreement'), findsOneWidget);
      pending.pendingTask(PendingTaskModel(pendingKyc: 18));
      await tester.pump();
      expect(find.text('18'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'missing company');
      await tester.pumpAndSettle();
      expect(find.text('No matching tasks'), findsOneWidget);
    },
  );

  testWidgets('Earnings switch source, filter and sort', (tester) async {
    await show(tester, const EarningsView());
    expect(
      tester.getTopLeft(find.text('Priya Mehta')).dy,
      lessThan(tester.getTopLeft(find.text('Aarav Shah')).dy),
    );
    await tester.tap(find.byType(DropdownButton<bool>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name: A–Z').last);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Aarav Shah')).dy,
      lessThan(tester.getTopLeft(find.text('Priya Mehta')).dy),
    );
    await tester.tap(find.text('From channel partners'));
    await tester.pumpAndSettle();
    expect(find.text('Summit Wealth Partners'), findsOneWidget);
    expect(find.text('Aarav Shah'), findsNothing);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching results'), findsOneWidget);
  });

  testWidgets('MIS search opens matching reports, disabled files and filters', (
    tester,
  ) async {
    await show(tester, const MisView(), width: 360);
    await tester.enterText(find.byType(TextField), 'quarterly');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Quarterly business update'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quarterly business update'), findsOneWidget);
    expect(find.text('Annual review'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('File unavailable'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'File unavailable'),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 1000));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('With reports'));
    await tester.pumpAndSettle();
    expect(find.text('Bharat Infrastructure'), findsNothing);
  });

  testWidgets('Error retry and empty report library', (tester) async {
    mis.error('Reports are unavailable.');
    await show(tester, const MisView());
    expect(find.text('Unable to load data'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Northstar Technologies'), findsOneWidget);
    mis.list.clear();
    await tester.pumpAndSettle();
    expect(find.text('No reports yet'), findsOneWidget);
    mis.isLoading(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No reports yet'), findsNothing);
    mis.isLoading(false);
    await tester.pumpAndSettle();
  });
}
