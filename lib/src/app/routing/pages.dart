import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/change_password_page.dart';
import 'package:private_deals/src/features/auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:private_deals/src/features/auth/presentation/inquiry/inquiry_page.dart';
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
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/create_company/create_company_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/manage_promoters/manage_promoters_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/manage_shareholders/manage_shareholders_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/bulk_deals_page.dart';
import 'package:private_deals/src/features/investors/presentation/partner_investors_page.dart';
import 'package:private_deals/src/features/investors/presentation/cml_page.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';

class Pages {
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

  static final List<GetPage> pages = [
    GetPage(name: '/', page: () => InitScreen()),
    GetPage(name: Routes.init, page: () => InitScreen()),
    GetPage(name: Routes.signIn, page: () => LoginPage()),
    GetPage(name: Routes.forgotPasswordPage, page: () => ForgotPasswordPage()),
    GetPage(name: Routes.inquiryPage, page: () => InquiryPage()),
    GetPage(name: '/session', page: () => const SessionRetryPage()),
    GetPage(name: '/access-denied', page: () => const AccessDeniedPage()),
    GetPage(name: '/not-found', page: () => const NotFoundPage()),
    privatePage(Routes.option, () => OptionPage()),
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
    privatePage(Routes.addInvestorPage, () => AddInvestorPage()),
    privatePage(Routes.kycPage, () => KYCPage()),
    privatePage(Routes.notificationPage, () => NotificationPage()),
    privatePage(
      Routes.primaryDetailPage,
      () => PrimaryDetailPage(),
      scope: AccessScope.primary,
    ),
    privatePage(
      Routes.secondaryDetailPage,
      () => SecondaryDetailPage(),
      scope: AccessScope.secondary,
    ),
    privatePage(
      Routes.preIPOInvestmentPage,
      () => PreIPOInvestmentPage(),
      scope: AccessScope.unlisted,
    ),
    privatePage(
      '${Routes.secondaryDetailPage}/investment',
      () => PreIPOInvestmentPage(),
      scope: AccessScope.secondary,
    ),
    privatePage(
      Routes.primaryInvestmentPage,
      () => PrimaryInvestmentPage(),
      scope: AccessScope.primary,
    ),
    privatePage(
      Routes.changePassword,
      () => ChangePasswordPage(),
      scope: AccessScope.account,
    ),
    privatePage(Routes.blogDetailPage, () => BlogDetailPage()),
    privatePage(Routes.blogListDetailPage, () => BlogDetailPage()),
    privatePage(
      Routes.newsListPage,
      () => NewsListPage(),
      scope: AccessScope.unlisted,
    ),
    privatePage(
      Routes.secondary,
      () => SecondaryLandingPage(),
      scope: AccessScope.secondary,
    ),
    privatePage(
      Routes.preIPODetailPage,
      () => PreIPODetailPage(),
      scope: AccessScope.unlisted,
    ),
    privatePage(
      '/account',
      () => const AccountPage(),
      scope: AccessScope.account,
    ),
    privatePage(
      '/investors',
      () => app.role == PartnerRole.institution
          ? const PartnerInvestorsPage()
          : HomePage(),
      scope: AccessScope.investors,
    ),
    privatePage(
      '/investors/create',
      () => const CreateInvestorPage(),
      scope: AccessScope.investors,
    ),
    privatePage(
      '/investors/:id/cml',
      () => const CmlPage(),
      scope: AccessScope.investors,
    ),
    privatePage(
      '/institution/dashboard',
      () => const InstitutionDashboard(),
      scope: AccessScope.institution,
    ),
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
      privatePage(
        '/institution/companies/$type/create',
        () => CreateCompanyPage(),
        scope: AccessScope.institution,
      ),
      privatePage(
        '/institution/companies/$type/:slug/promoters',
        () => CompanyPromotersPage(),
        scope: AccessScope.institution,
      ),
      privatePage(
        '/institution/companies/$type/:slug/shareholders',
        () => CompanyShareholdersPage(),
        scope: AccessScope.institution,
      ),
      privatePage(
        '/institution/deals/$type',
        () => PartnerShell(
          title: 'Deals',
          child: DealListView(key: ValueKey(type)),
        ),
        scope: AccessScope.institution,
      ),
      privatePage(
        '/institution/deals/$type/create',
        () => CreateDealPage(),
        scope: AccessScope.institution,
      ),
    ],
    privatePage(
      '/institution/bulk-deals',
      () => const BulkDealsPage(),
      scope: AccessScope.institution,
    ),
  ];
}
