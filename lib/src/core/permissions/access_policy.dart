import 'partner_role.dart';

enum AccessScope {
  account,
  enquiries,
  business,
  institution,
  investors,
  primary,
  secondary,
  unlisted,
}

enum AccessResult {
  allowed,
  login,
  retrySession,
  accountUnavailable,
  passwordChange,
  unsupportedRole,
  forbidden,
}

class AccessSnapshot {
  const AccessSnapshot({
    required this.hasToken,
    required this.validated,
    required this.role,
    this.storageUnavailable = false,
    this.blocked = false,
    this.deleted = false,
    this.passwordChange = false,
    this.primary = false,
    this.secondary = false,
    this.unlisted = false,
  });
  final bool hasToken, validated, blocked, deleted, passwordChange;
  final bool storageUnavailable;
  final bool primary, secondary, unlisted;
  final PartnerRole role;
}

class AccessPolicy {
  static AccessResult check(
    AccessSnapshot user,
    AccessScope scope, {
    bool changingPassword = false,
    bool channelPartners = false,
  }) {
    if (user.storageUnavailable) return AccessResult.retrySession;
    if (!user.hasToken) return AccessResult.login;
    if (!user.validated) return AccessResult.retrySession;
    if (user.blocked || user.deleted) return AccessResult.accountUnavailable;
    if (user.role == PartnerRole.unknown) return AccessResult.unsupportedRole;
    if (user.passwordChange && !changingPassword)
      return AccessResult.passwordChange;
    if (channelPartners && user.role == PartnerRole.relationManager)
      return AccessResult.forbidden;
    final allowed = switch (scope) {
      AccessScope.account => true,
      AccessScope.enquiries =>
        user.role == PartnerRole.wealthManager ||
            user.role == PartnerRole.distributor ||
            user.role == PartnerRole.retailer,
      AccessScope.investors => user.role != PartnerRole.institution,
      AccessScope.institution => user.role == PartnerRole.institution,
      AccessScope.business => user.role.isBusinessWorkspace,
      AccessScope.primary => user.role.isBusinessWorkspace && user.primary,
      AccessScope.secondary => user.role.isBusinessWorkspace && user.secondary,
      AccessScope.unlisted => user.role.isBusinessWorkspace && user.unlisted,
    };
    return allowed ? AccessResult.allowed : AccessResult.forbidden;
  }

  static String? safeReturnPath(String? raw) {
    if (raw == null ||
        !raw.startsWith('/') ||
        raw.startsWith('//') ||
        raw.contains(r'\'))
      return null;
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        uri.hasScheme ||
        uri.hasAuthority ||
        uri.path.contains(':'))
      return null;
    if ([
          '/',
          '/init',
          '/session',
          '/access-denied',
          '/changePassword',
        ].contains(uri.path) ||
        uri.path.startsWith('/sign-in'))
      return null;
    return uri.toString();
  }
}
