import 'package:private_deals/src/shared/models/deep_link_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/session/secure_session_store.dart';

final AuthSession app = AuthSession.instance;

/// The only authenticated principal. Investor selections never replace it.
class AuthSession extends GetxService {
  AuthSession({SecureSessionStore? sessionStore})
    : _sessionStore = sessionStore ?? SecureSessionStore();

  static final AuthSession instance = AuthSession();
  static const storageKey = SecureSessionStore.legacyKey;
  final SecureSessionStore _sessionStore;
  bool _storageReadFailed = false;
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
          (iUser.isPreIpoKycComplete ? 1 : 0)) /
      3;

  AccessSnapshot get access => AccessSnapshot(
    storageUnavailable: _storageReadFailed,
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

  Future<T> _withStorage<T>(Future<T> Function() operation) {
    final work = _storageWork.then((_) => operation());
    // A failed operation must not prevent a later retry or logout.
    _storageWork = work.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return work;
  }

  Future<void> _store(Map<String, dynamic>? value) {
    if (!persist) return Future.value();
    return _withStorage(
      () => value == null ? _sessionStore.clear() : _sessionStore.write(value),
    );
  }

  Future<void> getUser() async {
    if (!persist) return;
    final requestRevision = revision;
    try {
      final saved = await _withStorage(_sessionStore.read);
      if (requestRevision != revision) return;
      // Persisted role/flags are never used to authorize a refreshed browser.
      wUserModel(PartnerUser.fromJson(saved ?? {}));
      validated(false);
      _storageReadFailed = false;
      sessionError('');
      revision++;
    } catch (_) {
      if (requestRevision != revision) return;
      validated(false);
      _storageReadFailed = true;
      sessionError('Secure storage is unavailable. Please try again.');
    }
  }

  Future<bool> restore() async {
    restoring(true);
    try {
      if (_storageReadFailed) await getUser();
      if (_storageReadFailed || token.isEmpty) return false;
      sessionError('');
      final result = await WAuthApi.profileGet();
      if (!result.isSuccess) sessionError(result.m);
      return validated();
    } finally {
      restoring(false);
    }
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
    final requestRevision = revision;
    // Publish the authenticated user only after credentials are safely stored.
    // A logout while this write is pending must not resurrect the user.
    await _store({'id': next.id, 'token': next.token});
    if (requestRevision != revision) return;
    wUserModel(next);
    validated(true);
    _storageReadFailed = false;
    sessionError('');
  }

  Future<void> clear() async {
    revision++;
    _storageReadFailed = false;
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
    if (persist) {
      await prefs.setValue(key: 'login_count', value: loginUserCount);
    }
  }

  Future<void> getLoginCounts() async =>
      loginUserCount = await prefs.getValue(key: 'login_count') ?? 0;
}
