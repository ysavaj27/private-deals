import 'package:private_deals/src/shared/models/deep_link_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';

final AuthSession app = AuthSession.instance;

/// The only authenticated principal. Investor selections never replace it.
class AuthSession extends GetxService {
  static final AuthSession instance = AuthSession();
  static const storageKey = 'private_deals.session.v1';
  UserType userType =
      UserType.distributor; // Compatibility for migrated business screens.
  final currentMenu = MenuItemEnum.none.obs;
  final configModel = ConfigModel.fromJson({}).obs;
  ConfigModel get config => configModel();
  int loginUserCount = 0;
  final iUserModel = InvestorModel.fromJson({}).obs;
  final wUserModel = PartnerUser.fromJson({}).obs;
  final validated = false.obs;
  final restoring = false.obs;
  final sessionError = ''.obs;
  int revision = 0;
  int? recoveryPartnerId;
  String? pendingRoute;
  bool persist = true;
  DeepLinkResult deepLinkResult = DeepLinkResult();
  Future<void> _storageWork = Future.value();

  PartnerUser get wUser => wUserModel();
  PartnerRole get role => wUser.role;
  String get token => wUser.token;
  int get userId => wUser.id;
  bool get isDemo => wUser.isDemo;
  bool get isUserLogin => validated() && token.isNotEmpty && userId > 0;
  bool get isActive => isUserLogin && !wUser.isBlocked && !wUser.isDeleted;
  InvestorModel get iUser => iUserModel().activeInvestor ?? iUserModel();
  double get profileComplete =>
      ((iUser.isKycSuccess ? 1 : 0) +
          (iUser.aifStatus ? 1 : 0) +
          (iUser.cityId != 0 && iUser.address.isNotEmpty ? 1 : 0)) /
      3;

  AccessSnapshot get access => AccessSnapshot(
    hasToken: token.isNotEmpty && userId > 0,
    validated: validated(),
    role: role,
    blocked: wUser.isBlocked,
    deleted: wUser.isDeleted,
    passwordChange: wUser.changePassword,
    primary: wUser.isPrimaryAccess,
    secondary: wUser.isSecondaryAccess,
    unlisted: wUser.isPreIpoAccess,
  );

  Future<void> _store(Map<String, dynamic>? value) {
    if (!persist) return Future.value();
    _storageWork = _storageWork
        .catchError((_) {})
        .then(
          (_) => value == null
              ? prefs.removeValue(key: storageKey)
              : prefs.setValue(key: storageKey, value: value),
        );
    return _storageWork;
  }

  Future<void> getUser() async {
    final saved = await prefs.getValue(key: storageKey);
    if (saved is Map) {
      // Persisted role/flags are never used to authorize a refreshed browser.
      wUserModel(
        PartnerUser.fromJson({'id': saved['id'], 'token': saved['token']}),
      );
      validated(false);
      revision++;
    }
  }

  Future<bool> restore() async {
    if (token.isEmpty) return false;
    restoring(true);
    sessionError('');
    final result = await WAuthApi.profileGet();
    restoring(false);
    if (!result.isSuccess) sessionError(result.m);
    return validated();
  }

  Future<void> setUser({required Map<String, dynamic> prefUser}) async {
    if (prefUser.isEmpty) {
      await clear();
      return;
    }
    final next = PartnerUser.fromJson(prefUser);
    if (next.id <= 0 || next.token.isEmpty) return;
    if (next.id != userId || next.token != token || next.type != wUser.type)
      revision++;
    wUserModel(next);
    validated(true);
    sessionError('');
    await _store({'id': next.id, 'token': next.token});
  }

  Future<void> clear() async {
    revision++;
    validated(false);
    wUserModel(PartnerUser.fromJson({}));
    iUserModel(InvestorModel.fromJson({}));
    recoveryPartnerId = null;
    pendingRoute = null;
    currentMenu(MenuItemEnum.none);
    await _store(null);
  }

  Future<bool> expire(int requestRevision) async {
    if (requestRevision != revision || token.isEmpty) return false;
    await clear();
    return true;
  }

  void changeAuth() {} // Legacy investor view hook; does not change principal.
  Future<void> loginCounts() async {
    loginUserCount++;
    if (persist)
      await prefs.setValue(key: 'login_count', value: loginUserCount);
  }

  Future<void> getLoginCounts() async =>
      loginUserCount = await prefs.getValue(key: 'login_count') ?? 0;
}
