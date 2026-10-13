import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page.dart';
import 'package:private_deals/src/features/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:private_deals/src/features/investors/presentation/legacy_kyc/kyc_page.dart';
import 'package:private_deals/src/features/auth/presentation/login/login_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/notification/notification_page.dart';
import 'package:private_deals/src/app/bootstrap/init_screen.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/option/option_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/pre_ipo_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/blog_detail/blog_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/blog_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/primary_investment_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_detail_page/secondary_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page.dart';
import 'package:private_deals/src/app/routing/middleware/auth_middleware.dart';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/app/routing/session_pages.dart';
import 'package:private_deals/src/features/institution/institution_dashboard.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart'
    show InstitutionRoutes;
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/create_company/create_company_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/manage_promoters/manage_promoters_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/manage_shareholders/manage_shareholders_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/bulk_deals_page.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';

class Pages {
  /// Shell / tab routes — instant swap (no page transition).
  static GetPage privatePage(
    String name,
    Widget Function() builder, {
    AccessScope? scope,
  }) => GetPage(
    name: name,
    page: builder,
    transition: Transition.noTransition,
    middlewares: [AuthMiddleware(scope: scope)],
  );

  /// True page pushes (detail, forms, settings) — short fade.
  static GetPage privatePushPage(
    String name,
    Widget Function() builder, {
    AccessScope? scope,
  }) => GetPage(
    name: name,
    page: builder,
    transition: Transition.fadeIn,
    transitionDuration: AppMotion.normal,
    middlewares: [AuthMiddleware(scope: scope)],
  );

  static final List<GetPage> pages = [
    GetPage(name: '/', page: () => InitScreen()),
    GetPage(name: Routes.init, page: () => InitScreen()),
    GetPage(
      name: Routes.signIn,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
      transitionDuration: AppMotion.normal,
    ),
    GetPage(
      name: Routes.forgotPasswordPage,
      page: () => ForgotPasswordPage(),
      transition: Transition.fadeIn,
      transitionDuration: AppMotion.normal,
    ),
    GetPage(
      name: '/session',
      page: () => const SessionRetryPage(),
      transition: Transition.fadeIn,
      transitionDuration: AppMotion.normal,
    ),
    GetPage(
      name: '/access-denied',
      page: () => const AccessDeniedPage(),
      transition: Transition.fadeIn,
      transitionDuration: AppMotion.normal,
    ),
    GetPage(name: '/not-found', page: () => const NotFoundPage()),
    // Shell / product select — option is a push; home tabs stay instant.
    privatePushPage(Routes.option, () => OptionPage()),
    privatePage(Routes.home, () => HomePage()),
    privatePage(
      Routes.primaryListPage,
      () => PrimaryListPage(),
      scope: AccessScope.primary,
    ),
    privatePage(
      Routes.preIPOList,
      () => PreIPOListPage(),
      scope: AccessScope.unlisted,
    ),
    privatePushPage(Routes.addInvestorPage, () => AddInvestorPage()),
    privatePushPage(Routes.kycPage, () => KYCPage()),
    privatePushPage(Routes.notificationPage, () => NotificationPage()),
    privatePushPage(
      Routes.primaryDetailPage,
      () => PrimaryDetailPage(),
      scope: AccessScope.primary,
    ),
    privatePushPage(
      Routes.secondaryDetailPage,
      () => SecondaryDetailPage(),
      scope: AccessScope.secondary,
    ),
    privatePushPage(
      Routes.preIPOInvestmentPage,
      () => PreIPOInvestmentPage(),
      scope: AccessScope.unlisted,
    ),
    privatePushPage(
      '${Routes.secondaryDetailPage}/investment',
      () => PreIPOInvestmentPage(),
      scope: AccessScope.secondary,
    ),
    privatePushPage(
      Routes.primaryInvestmentPage,
      () => PrimaryInvestmentPage(),
      scope: AccessScope.primary,
    ),
    privatePushPage(
      Routes.changePassword,
      () => ChangePasswordPage(),
      scope: AccessScope.account,
    ),
    privatePushPage(Routes.blogDetailPage, () => BlogDetailPage()),
    privatePushPage(Routes.blogListPage, () => const BlogListPage()),
    privatePushPage(Routes.blogListDetailPage, () => BlogDetailPage()),
    privatePushPage(
      Routes.newsListPage,
      () => NewsListPage(),
      scope: AccessScope.unlisted,
    ),
    privatePage(
      Routes.secondary,
      () => SecondaryLandingPage(),
      scope: AccessScope.secondary,
    ),
    privatePushPage(
      Routes.preIPODetailPage,
      () => PreIPODetailPage(),
      scope: AccessScope.unlisted,
    ),
    privatePushPage(
      '/account',
      () => const AccountPage(),
      scope: AccessScope.account,
    ),
    privatePage(
      '/institution/dashboard',
      () => const InstitutionDashboard(),
      scope: AccessScope.institution,
    ),
    // Seller catalog routes reuse the catalog UI and APIs, with a separate
    // middleware boundary for future seller-specific validation.
    for (final path in [
      InstitutionRoutes.privateEquity,
      InstitutionRoutes.lpSecondary,
      InstitutionRoutes.unlistedShares,
    ]) ...[
      privatePage(
        path,
        () => const InstitutionDashboard(),
        scope: AccessScope.institution,
      ),
      privatePushPage(
        '$path/detail/:slug',
        path == InstitutionRoutes.privateEquity
            ? () => PrimaryDetailPage()
            : path == InstitutionRoutes.lpSecondary
            ? () => SecondaryDetailPage()
            : () => PreIPODetailPage(),
        scope: AccessScope.institution,
      ),
      privatePushPage(
        path == InstitutionRoutes.privateEquity
            ? '$path/detail/:slug/investment/:id'
            : '$path/detail/:slug/investment',
        path == InstitutionRoutes.privateEquity
            ? () => PrimaryInvestmentPage()
            : () => const PreIPOInvestmentPage(),
        scope: AccessScope.institution,
      ),
      if (path == InstitutionRoutes.privateEquity) ...[
        privatePushPage(
          '$path/blog-list',
          () => const BlogListPage(),
          scope: AccessScope.institution,
        ),
        privatePage(
          '$path/startup-list/:slug',
          () => PrimaryListPage(),
          scope: AccessScope.institution,
        ),
        privatePushPage(
          '$path/blog-detail/:slug',
          () => BlogDetailPage(),
          scope: AccessScope.institution,
        ),
        privatePushPage(
          '$path/blog-list/blog-detail/:slug',
          () => BlogDetailPage(),
          scope: AccessScope.institution,
        ),
      ] else ...[
        privatePage(
          '$path/company-list/:type',
          () => PreIPOListPage(),
          scope: AccessScope.institution,
        ),
        privatePushPage(
          '$path/news-list',
          () => NewsListPage(),
          scope: AccessScope.institution,
        ),
      ],
    ],
    for (final tab in [
      'sell-enquiries',
      'unlisted-transactions',
      'secondary-transactions',
      'profile',
      'change-password',
    ])
      privatePage(
        '/institution/$tab',
        () => const InstitutionDashboard(),
        scope: AccessScope.institution,
      ),
    // Enumerated company types avoid accepting arbitrary types through URL parameters.
    for (final type in ['unlisted', 'secondary']) ...[
      privatePage(
        '/institution/companies/$type',
        () => PartnerShell(
          title: 'Companies',
          child: CompanyListPage(key: ValueKey(type)),
        ),
        scope: AccessScope.institution,
      ),
      privatePushPage(
        '/institution/companies/$type/create',
        () => CreateCompanyPage(),
        scope: AccessScope.institution,
      ),
      privatePushPage(
        '/institution/companies/$type/:slug/promoters',
        () => CompanyPromotersPage(),
        scope: AccessScope.institution,
      ),
      privatePushPage(
        '/institution/companies/$type/:slug/shareholders',
        () => CompanyShareholdersPage(),
        scope: AccessScope.institution,
      ),
    ],
    for (final section in ['hot', 'manage'])
      for (final type
          in section == 'hot' ? ['unlisted', 'secondary'] : ['secondary']) ...[
        privatePage(
          '/institution/deals/$section/$type',
          () => PartnerShell(
            title: section == 'hot' ? 'Deal of the day' : 'Manage Deals',
            child: DealListView(key: ValueKey('$section-$type')),
          ),
          scope: AccessScope.institution,
        ),
        privatePushPage(
          '/institution/deals/$section/$type/create',
          () => CreateDealPage(),
          scope: AccessScope.institution,
        ),
      ],
    privatePushPage(
      '/institution/bulk-deals',
      () => const BulkDealsPage(),
      scope: AccessScope.institution,
    ),
  ];
}
