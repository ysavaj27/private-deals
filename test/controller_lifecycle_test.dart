import 'dart:async';

import 'package:dio/dio.dart' show ResponseBody;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/auth/presentation/inquiry/inquiry_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/pre_ipo_list_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/investor_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void expectDisposed(ChangeNotifier notifier) {
  expect(() => notifier.addListener(() {}), throwsFlutterError);
}

Future<void> pumpRequest(WidgetTester tester, Future<void> request) async {
  var completed = false;
  final tracked = request.whenComplete(() => completed = true);
  for (var attempt = 0; attempt < 100 && !completed; attempt++) {
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  }
  expect(completed, isTrue, reason: 'Fake HTTP request did not finish');
  await tracked;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalAdapter = dioConfig.dio.httpClientAdapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'status': 1, 'data': <Object>[]}),
    );
  });

  tearDown(() async {
    Get.reset();
    await app.clear();
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  test('closing forms releases their owned text controllers', () {
    final inquiry = InquiryPageCtrl();
    final upload = UploadPortfolioCtrl();
    final fields = [
      inquiry.nameCTRL,
      inquiry.emailCTRL,
      inquiry.mobileNoCTRL,
      inquiry.otpCTRL,
      upload.investorCTRL,
      upload.companyCTRL,
      upload.sharePriceCTRL,
      upload.qtyCTRL,
      upload.purchaseDateCTRL,
    ];
    inquiry.onDelete();
    upload.onDelete();
    for (final field in fields) {
      expectDisposed(field);
    }
  });

  test(
    'closing catalog and dashboard releases scroll, page and focus resources',
    () {
      final primary = PrimaryLandingPageCtrl();
      final dashboard = DashboardPageCtrl();
      final detail = PreIPODetailPageCtrl();
      final list = PreIPOListPageCtrl();
      final resources = <ChangeNotifier>[
        primary.scrollController,
        primary.controller,
        primary.liveDealController,
        primary.completedDealController,
        primary.blogController,
        dashboard.scrollController,
        dashboard.trendingPageController,
        dashboard.chartPageController,
        detail.scrollController,
        detail.amountCTRL,
        list.scrollController,
        list.searchFocusNode,
      ];
      primary.onDelete();
      dashboard.onDelete();
      detail.onDelete();
      list.onDelete();
      for (final resource in resources) {
        expectDisposed(resource);
      }
    },
  );

  testWidgets('transaction tabs can close during an animation', (tester) async {
    final controller = InvestorTransactionPageCtrl();
    controller.setData();
    controller.tabController.animateTo(1);
    controller.onDelete();
    await tester.pump(const Duration(seconds: 1));
    expectDisposed(controller.controller);
    expectDisposed(controller.tabController);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'portfolio refresh replaces and releases the previous tab controller',
    (tester) async {
      final controller = PortfolioPageCtrl();
      await pumpRequest(tester, controller.getData());
      final first = controller.tabController;
      first.animateTo(1);
      await pumpRequest(tester, controller.getData());
      expect(controller.tabController, isNot(same(first)));
      expectDisposed(first);
      controller.onDelete();
      await tester.pump(const Duration(seconds: 1));
      expectDisposed(controller.tabController);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'carousel refresh keeps one timer and route deletion cancels it',
    (tester) async {
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [{}, {}, {}],
        }),
      );
      final controller = PrimaryListPageCtrl();
      await pumpRequest(tester, controller.getData());
      await tester.pump(const Duration(seconds: 3));
      expect(controller.currentPage, 1);
      final firstTimer = controller.timer!;

      await pumpRequest(tester, controller.getData());
      expect(firstTimer.isActive, isFalse);
      await tester.pump(const Duration(seconds: 3));
      expect(controller.currentPage, 2);
      controller.onDelete();
      expect(controller.timer!.isActive, isFalse);
      await tester.pump(const Duration(seconds: 6));
      expect(controller.currentPage, 2);
      expectDisposed(controller.pageController);
    },
  );

  testWidgets('late carousel response cannot restart a timer after leaving', (
    tester,
  ) async {
    final pending = Completer<ResponseBody>();
    final started = Completer<void>();
    dioConfig.dio.httpClientAdapter = FakeAdapter((_) {
      started.complete();
      return pending.future;
    });
    final controller = PrimaryListPageCtrl();
    final loading = controller.getData();
    await pumpRequest(tester, started.future);
    controller.onDelete();
    pending.complete(
      response({
        'status': 1,
        'data': [{}, {}],
      }),
    );
    await pumpRequest(tester, loading);
    await tester.pump(const Duration(seconds: 6));
    expect(controller.timer, isNull);
    expect(controller.list, isEmpty);
  });
}
