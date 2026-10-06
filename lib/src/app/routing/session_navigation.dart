import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class SessionNavigation {
  static String get home => app.role == PartnerRole.institution
      ? '/institution/dashboard'
      : '/wealth-manager/dashboard';

  static AccessScope scopeFor(String route) {
    final path = Uri.parse(route).path;
    if (path == '/wealth-manager/my-inquiries') return AccessScope.enquiries;
    if (path.startsWith('/institution/')) return AccessScope.institution;
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
    // #region agent log
    agentLog('E', 'session_navigation.dart:goHome', 'post-login destination', {
      'next': next,
      'role': app.role.apiValue,
      'home': home,
      'pending': app.pendingRoute,
      'account': AccessPolicy.check(app.access, AccessScope.account).name,
    });
    // #endregion
    if (next != Routes.changePassword && next != '/session')
      app.pendingRoute = null;
    Get.offAllNamed(next);
  }

  static Future<void> logout() async {
    // #region agent log
    agentLog('D', 'session_navigation.dart:logout', 'logout start', {
      'hasToken': app.token.isNotEmpty,
      'revision': app.revision,
      'route': Get.currentRoute,
    });
    // #endregion
    // Clear local identity even if the server cannot be reached.
    final logoutResult = await WAuthApi.logout();
    // #region agent log
    agentLog('D', 'session_navigation.dart:logout', 'logout API finished', {
      'success': logoutResult.isSuccess,
      'message': logoutResult.m,
      'hasToken': app.token.isNotEmpty,
      'revision': app.revision,
    });
    // #endregion
    await app.clear();
    // GetX disposes route controllers after the outgoing widgets unmount.
    // Deleting them here breaks reactive rebuilds triggered by clearing identity.
    Get.offAllNamed(Routes.signIn);
    // Permanent shell controllers survive offAllNamed; drop them after the
    // sign-in route has replaced the workspace tree.
    Future.microtask(() {
      if (Get.isRegistered<HomePageCtrl>()) {
        Get.delete<HomePageCtrl>(force: true);
      }
      if (Get.isRegistered<PortfolioPageCtrl>()) {
        Get.delete<PortfolioPageCtrl>(force: true);
      }
    });
  }
}
