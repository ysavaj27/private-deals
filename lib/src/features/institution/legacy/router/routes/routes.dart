import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';

class Routes {
  static const init = '/init';
  static const signIn = '/sign-in';
  static const password = '/sign-in/password';
  static const signUp = '/sign-in/sign-up';
  static const inquiryPage = '/sign-in/inquiry';
  static const forgotPasswordPage = '/sign-in/forgot-password';

  // static const home = '/home';
  static const profile = '/profile';

  // static const landingPage = '/LandingPage';
  // static const investorDetailPage = '/InvestorDetailPage';
  static const preIPOInvestmentPage = '/investment';

  // static const blogListPage = '$home/blog-lis';
  static const testPage = '/TestPage';
  static const secondary = '/secondary';
  static const changePassword = '/changePassword';

  // static const option = '/option';
  static String homeDefault = '/home/${WTabBarEnum.dashboard.slug}';
  static const notificationPage = '/notification';
  static const addInvestorPage = '$home/add-investor';
  static const addCompanyPage = '$home/add-company';
  static const createDealPage = '$home/create-deal';
  static const kycPage = '$home/kyc/:id';
  static const blogDetailPage = '$home/blog-detail/:slug';
  static const blogListPage = '$home/blog-list';
  static const newsListPage = '$home/news-list';
  static const blogListDetailPage = '$blogListPage/blog-detail/:slug';
  static const primaryListPage = '$home/startup-list/:slug';
  static const shareholdersPage = '$home/unlisted-shares/:slug/shareholders';
  static const promotersPage = '$home/unlisted-shares/:slug/promoters';
  static const preIPOList = '$home/company-list/:type';
  static const home = '/home/:tab';
  static final preIPODetailPage =
      '/home/${WTabBarEnum.preIPOList.slug}/detail/:slug';

  // static final primaryDetailPage =
  //     '/home/${WTabBarEnum.primary.slug}/detail/:slug';
  static final secondaryDetailPage =
      '/home/${WTabBarEnum.secondaryList.slug}/detail/:slug';

  static String addInvestorPath(String tabSlug) => '$tabSlug/add-investor';

  static String createCompany(String url) => '$url/add-company';

  static String createDeal(String url) => '$url/create-deal';

  static String preIPOInvestmentPath(String url) => '$url/investment';

  static String primaryDetailPath(String url, String slug) =>
      '$url/detail/$slug';

  static String secondaryDetailPath(String url, String slug) =>
      '$url/detail/$slug';

  static String primaryInvestmentPath(String url, String id) =>
      '$url/investment/$id';

  static String blogListPath(String url) => '$url/blog-list';

  static String newsListPath(String url) => '$url/news-list';

  static String blogDetailPath(String url, String slug) =>
      '$url/blog-detail/$slug';

  // static String blogListDetailPath(String url, String slug) => '$url/blog-detail/$slug';

  static String kycPath(String url, String id) => '$url/kyc/$id';

  static String primaryListPath(String url, String slug) =>
      '$url/startup-list/$slug';

  static String preIPOListPath(String url, String type) =>
      '$url/company-list/$type';
}

extension WTabBarRouteX on WTabBarEnum {
  String get slug {
    switch (this) {
      case WTabBarEnum.investors:
        return 'investors';
      case WTabBarEnum.dashboard:
        return 'dashboard';
      case WTabBarEnum.transactions:
        return 'transactions';
      case WTabBarEnum.profile:
        return 'profile';
      case WTabBarEnum.sendDocuments:
        return 'send-documents';
      // case WTabBarEnum.notifications:
      //   return 'notifications';
      case WTabBarEnum.primaryList:
        return 'private-equity';
      case WTabBarEnum.secondaryList:
        return 'lp-secondary';
      case WTabBarEnum.preIPOList:
        return 'unlisted-shares';
      case WTabBarEnum.changePassword:
        return 'change-password';
      case WTabBarEnum.sellEnquiries:
        return 'sell-enquiries';
      case WTabBarEnum.companyDeals:
        return 'hot-deals/unlisted';
      case WTabBarEnum.secondaryDeals:
        return 'hot-deals/secondary';
      case WTabBarEnum.priceUpdate:
        return 'update-share-price';
      case WTabBarEnum.manageDeals:
        return 'manage-deals';
      case WTabBarEnum.preIPOTransactions:
        return 'unlisted-transactions';
      case WTabBarEnum.secondaryTransactions:
        return 'secondary-transactions';
    }
  }

  static WTabBarEnum fromSlug(String? slug) {
    if (slug == 'company-deals' || slug == 'hot-deals') {
      return WTabBarEnum.companyDeals;
    }
    return WTabBarEnum.values.firstWhereOrNull((e) => e.slug == slug) ??
        WTabBarEnum.dashboard;
  }
}

class RouteHierarchy {
  static String resolveParent(String currentPath) {
    final segments = Uri.parse(currentPath).pathSegments;

    // /home/:tab/detail/:slug/investment/:id -> /home/:tab/detail/:slug
    if (segments.length == 6 &&
        segments[0] == 'home' &&
        segments[2] == 'detail' &&
        segments[4] == 'investment') {
      return '/home/${segments[1]}/detail/${segments[3]}';
    }

    // /home/:tab/detail/:slug -> /home/:tab
    if (segments.length == 4 &&
        segments[0] == 'home' &&
        segments[2] == 'detail') {
      return '/home/${segments[1]}';
    }

    // /home/:tab/blog-detail/:id -> /home/:tab/blog-list
    if (segments.length == 4 &&
        segments[0] == 'home' &&
        segments[2] == 'blog-detail') {
      return '/home/${segments[1]}';
    }

    if (segments.length == 4 &&
        segments[0] == 'home' &&
        (segments[2] == 'startup-list' || segments[2] == 'company-list')) {
      return '/home/${segments[1]}';
    }

    // /home/:tab/startup-list/:slug -> /home/:tab
    if (segments.length == 4 &&
        segments[0] == 'home' &&
        segments[2] == 'blog-detail') {
      return '/home/${segments[1]}';
    }

    // /home/:tab/blog-list -> /home/:tab
    // /home/:tab/add-investor -> /home/:tab
    if (segments.length == 3 &&
        segments[0] == 'home' &&
        (segments[2] == 'blog-list' ||
            segments[2] == 'news-list' ||
            segments[2] == 'add-investor')) {
      return '/home/${segments[1]}';
    }

    // /home/:tab -> /option
    // if (segments.length == 2 && segments[0] == 'home') {
    //   return Routes.option;
    // }

    // /sign-in/password, /sign-in/sign-up, /sign-in/inquiry, /sign-in/forgot-password -> /sign-in
    if (segments.length == 2 && segments[0] == 'sign-in') {
      return Routes.signIn;
    }

    // Top-level standalone pages (/profile, /investment, /KYCPage, /notification, etc.) -> /option
    return Routes.home;
  }
}

extension SellerTabPath on WTabBarEnum {
  String get sellerPath => switch (this) {
    WTabBarEnum.preIPOList => '/institution/companies/unlisted',
    WTabBarEnum.secondaryList => '/institution/companies/secondary',
    WTabBarEnum.companyDeals => '/institution/deals/hot/unlisted',
    WTabBarEnum.secondaryDeals => '/institution/deals/hot/secondary',
    WTabBarEnum.priceUpdate => '/institution/bulk-deals',
    WTabBarEnum.manageDeals => '/institution/deals/manage/secondary',
    _ => '/institution/$slug',
  };
}
