import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/session/auth_session.dart';

import 'session_and_api_test.dart' show identity;

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
      AccessPolicy.check(user, AccessScope.business, passwordPromptHost: true),
      AccessResult.allowed,
    );
    expect(
      AccessPolicy.check(user, AccessScope.primary, passwordPromptHost: true),
      AccessResult.passwordChange,
    );
    expect(
      AccessPolicy.check(user, AccessScope.account, changingPassword: true),
      AccessResult.allowed,
    );
    const institution = AccessSnapshot(
      hasToken: true,
      validated: true,
      role: PartnerRole.institution,
      passwordChange: true,
    );
    expect(
      AccessPolicy.check(
        institution,
        AccessScope.institution,
        passwordPromptHost: true,
      ),
      AccessResult.allowed,
    );
    expect(
      AccessPolicy.check(
        institution,
        AccessScope.business,
        passwordPromptHost: true,
      ),
      AccessResult.forbidden,
    );
  });
  test('Required password opens the home dashboard', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(
      prefUser: {...identity('Wealth Manager'), 'ask_password_change': 1},
    );
    expect(
      SessionNavigation.check('/wealth-manager/dashboard'),
      AccessResult.allowed,
    );
    expect(
      SessionNavigation.check('/wealth-manager/investors'),
      AccessResult.passwordChange,
    );
    expect(
      SessionNavigation.destination('/wealth-manager/investors'),
      '/wealth-manager/dashboard',
    );
    await app.setUser(
      prefUser: {...identity('Institution', 8), 'ask_password_change': 1},
    );
    expect(
      SessionNavigation.check('/institution/dashboard'),
      AccessResult.allowed,
    );
    expect(
      SessionNavigation.check('/institution/companies'),
      AccessResult.passwordChange,
    );
    expect(SessionNavigation.destination(), '/institution/dashboard');
    await app.clear();
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
