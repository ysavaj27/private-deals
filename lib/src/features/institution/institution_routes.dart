import 'data/models/common/enums.dart';

class InstitutionRoutes {
  static const dashboard = '/institution/dashboard';
  static const companies = '/institution/companies/:type';
  static const deals = '/institution/deals/:section/:type';
  static const promotersPage = '/institution/companies/:type/:slug/promoters';
  static const shareholdersPage =
      '/institution/companies/:type/:slug/shareholders';
  static String createCompany(String path) => '$path/create';
  static String createDeal(String path) => '$path/create';
}

extension WTabBarRouteX on WTabBarEnum {
  String get slug => this == WTabBarEnum.preIPOList ? 'unlisted' : 'secondary';
}

class RouteHierarchy {
  static String resolveParent(String path) {
    final segments = Uri.parse(path).pathSegments;

    // /institution/deals/{hot|manage}/{type}/create -> /institution/deals/{hot|manage}/{type}
    if (segments.length >= 5 &&
        segments[0] == 'institution' &&
        segments[1] == 'deals' &&
        (segments[2] == 'hot' || segments[2] == 'manage') &&
        segments.last == 'create') {
      return '/institution/deals/${segments[2]}/${segments[3]}';
    }

    return segments.length > 3
        ? '/institution/${segments[1]}/${segments[2]}'
        : InstitutionRoutes.dashboard;
  }
}
