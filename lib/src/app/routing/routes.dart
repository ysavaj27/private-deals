import 'package:private_deals/src/shared/app_exports.dart';

class Routes {
  static const init = '/init';
  static const signIn = '/sign-in';
  static const password = '/sign-in/password';
  static const signUp = '/sign-in/sign-up';
  static const inquiryPage = '/sign-in/inquiry';
  static const forgotPasswordPage = '/sign-in/forgot-password';

  // static const home = '/wealth-manager';
  static const profile = '/profile';

  // static const landingPage = '/LandingPage';
  // static const investorDetailPage = '/InvestorDetailPage';
  static final preIPOInvestmentPage = '$preIPODetailPage/investment';

  // static const blogListPage = '$home/blog-lis';
  static const testPage = '/TestPage';
  static const secondary = '/secondary';
  static const changePassword = '/changePassword';
  static const option = '/option';
  static const homeDefault = '/wealth-manager/dashboard';
  static const notificationPage = '/notification';
  static const addInvestorPage = '$home/add-investor';
  static const kycPage = '$home/kyc/:id';
  static final primaryInvestmentPage = '$primaryDetailPage/investment/:id';
  static const blogDetailPage = '$home/blog-detail/:slug';
  static const blogListPage = '$home/blog-list';
  static const newsListPage = '$home/news-list';
  static const blogListDetailPage = '$blogListPage/blog-detail/:slug';
  static const primaryListPage = '$home/startup-list/:slug';
  static const preIPOList = '$home/company-list/:type';
  static const home = '/wealth-manager/:tab';
  static final preIPODetailPage =
      '/wealth-manager/${WTabBarEnum.preIPO.slug}/detail/:slug';
  static final primaryDetailPage =
      '/wealth-manager/${WTabBarEnum.primary.slug}/detail/:slug';
  static final secondaryDetailPage =
      '/wealth-manager/${WTabBarEnum.secondary.slug}/detail/:slug';

  static String addInvestorPath(String tabSlug) => '$tabSlug/add-investor';

  static String preIPODetailPath(String url, String slug) =>
      '$url/detail/$slug';

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
      case WTabBarEnum.dashboard:
        return 'dashboard';
      case WTabBarEnum.investorTransactions:
        return 'investor-transactions';
      case WTabBarEnum.myEarnings:
        return 'my-earnings';
      case WTabBarEnum.profile:
        return 'profile';
      case WTabBarEnum.investors:
        return 'investors';
      case WTabBarEnum.pendingTasks:
        return 'pending-tasks';
      case WTabBarEnum.sendDocuments:
        return 'send-documents';
      case WTabBarEnum.channelPartner:
        return 'channel-partner';
      case WTabBarEnum.notifications:
        return 'notifications';
      case WTabBarEnum.primary:
        return 'private-equity';
      case WTabBarEnum.secondary:
        return 'lp-secondary';
      case WTabBarEnum.preIPO:
        return 'unlisted-shares';
      case WTabBarEnum.logout:
        return 'logout';
      case WTabBarEnum.mis:
        return 'mis';
      case WTabBarEnum.uploadPortfolio:
        return 'upload-portfolio';
      case WTabBarEnum.changePassword:
        return 'change-password';
      case WTabBarEnum.portfolio:
        return 'portfolio';
    }
  }

  static WTabBarEnum fromSlug(String? slug) {
    return WTabBarEnum.values.firstWhereOrNull((e) => e.slug == slug) ??
        WTabBarEnum.dashboard;
  }
}

class RouteHierarchy {
  static String resolveParent(String currentPath) {
    final segments = Uri.parse(currentPath).pathSegments;

    // /home/:tab/detail/:slug/investment/:id -> /home/:tab/detail/:slug
    if (segments.length == 6 &&
        segments[0] == 'wealth-manager' &&
        segments[2] == 'detail' &&
        segments[4] == 'investment') {
      return '/wealth-manager/${segments[1]}/detail/${segments[3]}';
    }

    // /home/:tab/detail/:slug -> /home/:tab
    if (segments.length == 4 &&
        segments[0] == 'wealth-manager' &&
        segments[2] == 'detail') {
      return '/wealth-manager/${segments[1]}';
    }

    // /home/:tab/blog-detail/:id -> /home/:tab/blog-list
    if (segments.length == 4 &&
        segments[0] == 'wealth-manager' &&
        segments[2] == 'blog-detail') {
      return '/wealth-manager/${segments[1]}';
    }

    if (segments.length == 4 &&
        segments[0] == 'wealth-manager' &&
        (segments[2] == 'startup-list' || segments[2] == 'company-list')) {
      return '/wealth-manager/${segments[1]}';
    }

    // /home/:tab/startup-list/:slug -> /home/:tab
    if (segments.length == 4 &&
        segments[0] == 'wealth-manager' &&
        segments[2] == 'blog-detail') {
      return '/wealth-manager/${segments[1]}';
    }

    // /home/:tab/blog-list -> /home/:tab
    // /home/:tab/add-investor -> /home/:tab
    if (segments.length == 3 &&
        segments[0] == 'wealth-manager' &&
        (segments[2] == 'blog-list' ||
            segments[2] == 'news-list' ||
            segments[2] == 'add-investor')) {
      return '/wealth-manager/${segments[1]}';
    }

    // /home/:tab -> /option
    if (segments.length == 2 && segments[0] == 'wealth-manager') {
      return Routes.option;
    }

    // /sign-in/password, /sign-in/sign-up, /sign-in/inquiry, /sign-in/forgot-password -> /sign-in
    if (segments.length == 2 && segments[0] == 'sign-in') {
      return Routes.signIn;
    }

    // Top-level standalone pages (/profile, /investment, /KYCPage, /notification, etc.) -> /option
    return Routes.option;
  }
}
