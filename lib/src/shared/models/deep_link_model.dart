class DeepLinkResult {
  final bool isAuth;

  final String baseRoute;
  final String tab;
  final String bottomNav;
  final String detailRoute;
  final int detailId;

  DeepLinkResult({
    this.isAuth = false,
    this.baseRoute = '',
    this.tab = '',
    this.bottomNav = '',
    this.detailRoute = '',
    this.detailId = 0,
  });
}

class DeepLinkParser {
  static DeepLinkResult? parse(String url) {
    String bottomNav = '';
    bool isAuth = false;
    String detailRoute = '';
    String tab = '';
    int detailId = 0;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return null;

    final segments = uri.pathSegments;

    final base = segments[0];
    if (base == 'wealth-manager') {
      isAuth = true;
    }

    if (segments.length > 1) {
      bottomNav = segments[1];
    }

    if (segments.length > 2) {
      detailRoute = segments[2];

      detailId = int.tryParse(uri.queryParameters['id'] ?? "") ?? 0;
      tab = uri.queryParameters['tab']?.toString() ?? "";
    }

    return DeepLinkResult(
      baseRoute: base,
      tab: tab,
      detailRoute: detailRoute,
      detailId: detailId,
      isAuth: isAuth,
      bottomNav: bottomNav,
    );
  }
}
