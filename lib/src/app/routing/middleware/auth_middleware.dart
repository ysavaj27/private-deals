import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';

/// Runs before a protected page builder (and its controllers) is created.
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.scope}) : super(priority: 0);
  final AccessScope? scope;
  @override
  RouteSettings? redirect(String? route) {
    final target = route ?? SessionNavigation.home;
    final result = SessionNavigation.check(target, scope: scope);
    // #region agent log
    agentLog('F', 'auth_middleware.dart:redirect', 'route guard', {
      'target': target,
      'result': result.name,
      'role': app.role.apiValue,
      'validated': app.validated(),
      'hasToken': app.token.isNotEmpty,
      'scope': scope?.name,
    });
    // #endregion
    if (result == AccessResult.allowed) {
      final segments = Uri.parse(target).pathSegments;
      if (segments.length > 1 &&
          segments[0] == 'wealth-manager' &&
          !WTabBarEnum.values.any((tab) => tab.slug == segments[1])) {
        return const RouteSettings(name: '/not-found');
      }
      return null;
    }
    if (result == AccessResult.forbidden) {
      return RouteSettings(name: SessionNavigation.home);
    }
    app.pendingRoute = AccessPolicy.safeReturnPath(target);
    return RouteSettings(name: SessionNavigation.destination());
  }
}
