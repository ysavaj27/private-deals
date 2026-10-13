import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart'
    as seller;
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  late FakeAdapter adapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity());
    adapter = FakeAdapter((request) async {
      final data = request.path == AppUrl.wPreIpoPortfolio
          ? [
              {
                'investor': {'id': 70, 'name': 'Test Investor'},
                'holdings': [
                  {
                    'id': 1,
                    'shares': 100,
                    'purchase_price': 1000,
                    'current_share_price': 1200,
                    'company': {'id': 8, 'brand_name': 'Test Company'},
                  },
                ],
              },
            ]
          : request.path == 'v2/business/institution/dashboard'
          ? <String, dynamic>{}
          : <Object>[];
      return response({'status': 1, 'data': data});
    });
    dioConfig.dio.httpClientAdapter = adapter;
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('seller opens shared portfolio from navigation at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/institution/dashboard',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Portfolio'));
      await tester.pumpAndSettle();

      expect(Get.currentRoute, '/institution/portfolio');
      expect(find.byType(PortfolioPage), findsOneWidget);
      expect(find.text('Test Company'), findsWidgets);
      expect(Get.find<SellerHomePageCtrl>().appBarName, 'Portfolio');
      expect(app.token, 'test-token-7');
      final request = adapter.requests.firstWhere(
        (request) => request.path == AppUrl.wPreIpoPortfolio,
      );
      expect(request.headers['Authorization'], 'Bearer test-token-7');
      if (width > 600) {
        expect(find.byType(seller.DSideBarWidget), findsOneWidget);
      } else {
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          4,
        );
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(Drawer),
            matching: find.text('Portfolio'),
          ),
          findsOneWidget,
        );
        Navigator.of(tester.element(find.byType(Drawer))).pop();
        await tester.pumpAndSettle();
      }

      // Switching asset types uses the same startup portfolio API.
      await tester.tap(find.text('Equity').first);
      await tester.pumpAndSettle();
      expect(
        adapter.requests.any(
          (request) =>
              request.path == AppUrl.wPortfolio &&
              request.queryParameters['type'] == 'equity',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);

      // Leaving and reopening recreates the shared controller safely.
      Get.find<SellerHomePageCtrl>().onPhoneNavTap(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Portfolio'));
      await tester.pumpAndSettle();
      expect(find.byType(PortfolioPage), findsOneWidget);
      expect(Get.find<PortfolioPageCtrl>().isLoading.value, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('seller portfolio supports direct links', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/institution/portfolio',
        getPages: Pages.pages,
      ),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, '/institution/portfolio');
    expect(find.byType(PortfolioPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test('seller portfolio access does not grant portfolio writes', () async {
    await expectLater(
      dioConfig.post(AppUrl.wAddPortfolio, {}),
      throwsException,
    );
    expect(adapter.requests, isEmpty);
  });
}
