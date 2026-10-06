import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';

void main() {
  for (final role in PartnerRole.values) {
    test('Exact role and workspace matrix: ${role.name}', () {
      if (role != PartnerRole.unknown)
        expect(PartnerRole.parse(role.apiValue), role);
      final user = AccessSnapshot(
        hasToken: true,
        validated: true,
        role: role,
        primary: true,
        secondary: true,
        unlisted: true,
      );
      expect(
        AccessPolicy.check(user, AccessScope.institution) ==
            AccessResult.allowed,
        role == PartnerRole.institution,
      );
      expect(
        AccessPolicy.check(user, AccessScope.business) == AccessResult.allowed,
        role.isBusinessWorkspace,
      );
      expect(
        AccessPolicy.check(user, AccessScope.investors) == AccessResult.allowed,
        role != PartnerRole.unknown && role != PartnerRole.institution,
      );
      for (final scope in [
        AccessScope.primary,
        AccessScope.secondary,
        AccessScope.unlisted,
      ]) {
        expect(
          AccessPolicy.check(user, scope) == AccessResult.allowed,
          role.isBusinessWorkspace,
        );
      }
    });
  }
  test('Missing, misspelled and new roles fail closed', () {
    for (final value in [
      null,
      '',
      'wealthmanager',
      'distributer',
      'distributor',
      'Seller',
      'Admin',
    ]) {
      expect(PartnerRole.parse(value), PartnerRole.unknown);
    }
  });
  test('Account state and required password take precedence', () {
    expect(
      AccessPolicy.check(
        const AccessSnapshot(
          hasToken: false,
          validated: false,
          role: PartnerRole.institution,
        ),
        AccessScope.institution,
      ),
      AccessResult.login,
    );
    expect(
      AccessPolicy.check(
        const AccessSnapshot(
          hasToken: true,
          validated: false,
          role: PartnerRole.institution,
        ),
        AccessScope.institution,
      ),
      AccessResult.retrySession,
    );
    for (final blocked in [true, false]) {
      final user = AccessSnapshot(
        hasToken: true,
        validated: true,
        role: PartnerRole.institution,
        blocked: blocked,
        deleted: !blocked,
        passwordChange: true,
      );
      expect(
        AccessPolicy.check(user, AccessScope.account, changingPassword: true),
        AccessResult.accountUnavailable,
      );
    }
    const user = AccessSnapshot(
      hasToken: true,
      validated: true,
      role: PartnerRole.wealthManager,
      passwordChange: true,
    );
    expect(
      AccessPolicy.check(user, AccessScope.business),
      AccessResult.passwordChange,
    );
    expect(
      AccessPolicy.check(user, AccessScope.account, changingPassword: true),
      AccessResult.allowed,
    );
  });
  test('Product flags and relation manager exclusions', () {
    const user = AccessSnapshot(
      hasToken: true,
      validated: true,
      role: PartnerRole.relationManager,
    );
    expect(
      AccessPolicy.check(user, AccessScope.business, channelPartners: true),
      AccessResult.forbidden,
    );
    expect(
      AccessPolicy.check(user, AccessScope.unlisted),
      AccessResult.forbidden,
    );
    expect(
      AccessPolicy.check(user, AccessScope.investors),
      AccessResult.allowed,
    );
  });
  test('Return URLs cannot escape the app or form authentication loops', () {
    for (final path in [
      'https://example.com',
      '//example.com',
      r'/\example.com',
      '/sign-in',
      '/init',
      '/session',
      '/changePassword',
    ]) {
      expect(AccessPolicy.safeReturnPath(path), isNull);
    }
    expect(
      AccessPolicy.safeReturnPath('/institution/deals/hot/unlisted?search=abc'),
      '/institution/deals/hot/unlisted?search=abc',
    );
  });
}
