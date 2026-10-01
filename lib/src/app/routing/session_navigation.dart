import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';

class SessionNavigation {
  static String get home => app.role == PartnerRole.institution
      ? '/institution/dashboard'
      : '/wealth-manager/dashboard';

  static AccessScope scopeFor(String route) {
    final path = Uri.parse(route).path;
    if (path.startsWith('/institution/')) return AccessScope.institution;
    if (path == '/investors' || path.startsWith('/investors/'))
      return AccessScope.investors;
    if (path == '/account' || path == Routes.changePassword)
      return AccessScope.account;
    if (path.contains('/private-equity') || path.contains('/startup-list'))
      return AccessScope.primary;
    if (path.contains('/lp-secondary') || path == Routes.secondary)
      return AccessScope.secondary;
    if (path.contains('/unlisted-shares') ||
        path.contains('/company-list') ||
        path == '/investment')
      return AccessScope.unlisted;
    return AccessScope.business;
  }

  static AccessResult check(String route, {AccessScope? scope}) =>
      AccessPolicy.check(
        app.access,
        scope ?? scopeFor(route),
        changingPassword: Uri.parse(route).path == Routes.changePassword,
        channelPartners: route.contains('/channel-partner'),
      );

  static String destination([String? desired]) {
    final result = AccessPolicy.check(app.access, AccessScope.account);
    switch (result) {
      case AccessResult.login:
        return Routes.signIn;
      case AccessResult.retrySession:
        return '/session';
      case AccessResult.passwordChange:
        return Routes.changePassword;
      case AccessResult.accountUnavailable:
        return '/access-denied?reason=account';
      case AccessResult.unsupportedRole:
        return '/access-denied?reason=role';
      default:
        break;
    }
    final safe = AccessPolicy.safeReturnPath(desired);
    return safe != null && check(safe) == AccessResult.allowed ? safe : home;
  }

  static void goHome() {
    final next = destination(app.pendingRoute);
    if (next != Routes.changePassword && next != '/session')
      app.pendingRoute = null;
    Get.offAllNamed(next);
  }

  static Future<void> logout() async {
    // Clear local identity even if the server cannot be reached.
    await WAuthApi.logout();
    await app.clear();
    // GetX disposes route controllers after the outgoing widgets unmount.
    // Deleting them here breaks reactive rebuilds triggered by clearing identity.
    Get.offAllNamed(Routes.signIn);
  }
}
