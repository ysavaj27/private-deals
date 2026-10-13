import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart'
    as seller;
import 'package:private_deals/src/features/wealth_manager/presentation/desktop_sidebar.dart'
    as partner;
import 'package:private_deals/src/shared/widgets/custom_appbar.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

const company = {
  'id': 8,
  'slug': 'test-company',
  'brand_name': 'Test Company',
  'company_name': 'Test Company Ltd',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  late FakeAdapter adapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity());
    adapter = FakeAdapter((request) async {
      final data = switch (request.path) {
        'v1/get-home' => <String, dynamic>{},
        'v2/business/home/pre-ipo' => {
          'liquid_stocks': [company],
        },
        'v2/business/home/pre-ipo/news-sectors' => <String, dynamic>{},
        'v2/business/home/secondary' => {
          'all': [company],
        },
        'v2/business/company/list' => [company],
        'v2/business/company/detail' => company,
        'v2/business/startup/detail' => <String, dynamic>{},
        'master/get-blog' =>
          request.queryParameters.containsKey('url_slug')
              ? {'id': 1, 'url_slug': 'test-blog', 'title': 'Test Blog'}
              : [
                  {'id': 1, 'url_slug': 'test-blog', 'title': 'Test Blog'},
                ],
        'v2/business/institution/dashboard' => <String, dynamic>{},
        _ => <Object>[],
      };
      return response({'status': 1, 'data': data});
    });
    dioConfig.dio.httpClientAdapter = adapter;
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
    dioConfig.dio.httpClientAdapter = originalAdapter;
  });

  test(
    'catalog links and access stay in the authenticated workspace',
    () async {
      for (final slug in [
        'private-equity',
        'lp-secondary',
        'unlisted-shares',
      ]) {
        expect(Routes.catalogPath(slug), '/institution/$slug');
        expect(
          SessionNavigation.check('/institution/$slug'),
          AccessResult.allowed,
        );
        expect(
          SessionNavigation.check('/wealth-manager/$slug'),
          AccessResult.forbidden,
        );
        expect(
          RouteHierarchy.resolveParent('/institution/$slug/detail/test'),
          '/institution/$slug',
        );
        expect(
          RouteHierarchy.resolveParent('/institution/$slug/company-list/all'),
          '/institution/$slug',
        );
        expect(
          RouteHierarchy.resolveParent(
            '/institution/$slug/detail/test/investment',
          ),
          '/institution/$slug/detail/test',
        );
      }
      expect(
        RouteHierarchy.resolveParent(
          '/institution/private-equity/detail/test/investment/70',
        ),
        '/institution/private-equity/detail/test',
      );
      expect(
        Routes.unlistedTransactionsPath(),
        '/institution/unlisted-transactions',
      );
      expect(Routes.enquiriesPath(), '/institution/sell-enquiries');
      await app.setUser(prefUser: identity('Wealth Manager'));
      for (final slug in [
        'private-equity',
        'lp-secondary',
        'unlisted-shares',
      ]) {
        expect(Routes.catalogPath(slug), '/wealth-manager/$slug');
        expect(
          SessionNavigation.check('/institution/$slug'),
          AccessResult.forbidden,
        );
        expect(
          SessionNavigation.check('/wealth-manager/$slug'),
          AccessResult.allowed,
        );
      }
      expect(
        Routes.unlistedTransactionsPath(),
        '/wealth-manager/investor-transactions?asset=unlisted',
      );
      expect(Routes.enquiriesPath(), '/wealth-manager/my-inquiries');
    },
  );

  test(
    'seller catalog actions use existing APIs with the seller session',
    () async {
      for (final path in [
        AppUrl.wStartupDetail,
        AppUrl.wStartupList,
        AppUrl.wSecondaryLandingPage,
        AppUrl.wPreIPOHome,
        AppUrl.wPreIPOHomeNewsSector,
        AppUrl.wPreIPOCompanyList,
        AppUrl.wCompanyDetail,
        AppUrl.wPreIPONewsList,
        AppUrl.wInvestorList,
        AppUrl.wInvestorDetail,
        AppUrl.wTransaction,
      ]) {
        await dioConfig.get(path, {});
      }
      for (final path in [
        AppUrl.wPreIpoBuy,
        AppUrl.wPrimaryInvestment,
        AppUrl.wEnquiry,
        AppUrl.wAddInvestor,
        'v2/business/investor/kyc/cml/read',
        'v2/business/investor/kyc/cml/save',
      ]) {
        await dioConfig.post(path, {});
      }
      for (final request in adapter.requests) {
        expect(request.headers['Authorization'], 'Bearer test-token-7');
        expect(request.headers['userid'], 7);
      }
      final count = adapter.requests.length;
      await expectLater(dioConfig.get(AppUrl.wDashboard, {}), throwsException);
      await expectLater(
        dioConfig.post(AppUrl.wCompanyDetail, {}),
        throwsException,
      );
      await expectLater(dioConfig.get(AppUrl.wEnquiry, {}), throwsException);
      expect(adapter.requests, hasLength(count));
      await app.clear();
      await expectLater(
        dioConfig.get(AppUrl.wCompanyDetail, {}),
        throwsException,
      );
      expect(adapter.requests, hasLength(count));
    },
  );

  for (final width in [390.0, 1280.0]) {
    testWidgets('seller hides tabs and retains routes at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await app.setUser(
        prefUser: {
          ...identity(),
          'is_primary_access': 0,
          'is_secondary_access': 0,
          'is_preipo_access': 0,
        },
      );
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/institution/dashboard',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WAppbarOptionSegmented), findsNothing);
      for (final entry in [
        ('Private Equity', 'private-equity', 'v1/get-home'),
        ('LP Secondary', 'lp-secondary', 'v2/business/home/secondary'),
        ('Unlisted Shares', 'unlisted-shares', 'v2/business/home/pre-ipo'),
      ]) {
        Get.offAllNamed('/institution/${entry.$2}');
        await tester.pumpAndSettle();
        expect(find.byType(WAppbarOptionSegmented), findsNothing);
        expect(Get.currentRoute, '/institution/${entry.$2}');
        expect(Get.find<SellerHomePageCtrl>().appBarName, entry.$1);
        expect(adapter.requests.any((r) => r.path == entry.$3), isTrue);
        expect(find.byType(partner.DSideBarWidget), findsNothing);
        if (width > 600) {
          expect(find.byType(seller.DSideBarWidget), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'seller private equity blog links retain their routes at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/institution/private-equity/blog-list',
            getPages: Pages.pages,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Blog'));
        await tester.pumpAndSettle();
        expect(
          Get.currentRoute,
          '/institution/private-equity/blog-list/blog-detail/test-blog',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );

    for (final slug in ['unlisted-shares', 'lp-secondary']) {
      testWidgets('seller $slug list opens named company detail at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/institution/$slug/company-list/all',
            getPages: Pages.pages,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Company').first);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/institution/$slug/detail/test-company');
        expect(
          adapter.requests
              .lastWhere((r) => r.path == AppUrl.wCompanyDetail)
              .queryParameters['slug'],
          'test-company',
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Back').first);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/institution/$slug/company-list/all');
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('seller checkout refresh returns to seller offers at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute:
              '/institution/unlisted-shares/detail/test-company/investment',
          getPages: Pages.pages,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('View company offers'));
      await tester.pumpAndSettle();
      expect(
        Get.currentRoute,
        '/institution/unlisted-shares/detail/test-company',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
