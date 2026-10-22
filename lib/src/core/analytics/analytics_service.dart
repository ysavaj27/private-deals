import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

/// Single entry point for Firebase Analytics. Features must call [Analytics]
/// helpers — never [FirebaseAnalytics] directly.
class Analytics {
  Analytics._();

  static FirebaseAnalytics? _fa;
  static final NavigatorObserver observer = _AnalyticsObserver();
  static bool _ready = false;
  static Future<void>? _pending;
  static List<List<String>> _routes = [];
  static int? _userId;
  static String? _role;
  static int _identityRevision = 0;

  static Future<void> init({
    FirebaseAnalytics? client,
    Iterable<String> routeTemplates = const [],
  }) async {
    _ready = false;
    _routes =
        routeTemplates.map((route) => Uri.parse(route).pathSegments).toList()
          ..sort(
            (a, b) => a
                .where((part) => part.startsWith(':'))
                .length
                .compareTo(b.where((part) => part.startsWith(':')).length),
          );
    try {
      _fa = client ?? FirebaseAnalytics.instance;
      await _fa!
          .setAnalyticsCollectionEnabled(true)
          .timeout(const Duration(seconds: 2));
      // Consent is not a DebugView switch. Use Firebase's device/browser debug
      // settings; do not override consent simply because this is a debug build.
      _ready = true;
      // Also clears an SDK identity left over from an expired persisted session.
      await setUser(_userId, role: _role);
    } catch (e, st) {
      debugPrint('Analytics.init failed: $e\n$st');
      _ready = false;
    }
  }

  static Future<void> setUser(int? userId, {String? role}) async {
    final id = userId != null && userId > 0 ? userId : null;
    final partnerRole = id != null && role != null && role.trim().isNotEmpty
        ? _clip(role.trim(), 36)
        : null;
    if (id != _userId || partnerRole != _role) {
      _identityRevision++;
    }
    _userId = id;
    _role = partnerRole;
    await _enqueue('setUser', (client) async {
      await client.setUserId(id: id?.toString());
      await client.setUserProperty(name: 'partner_role', value: partnerRole);
    });
  }

  static Future<void> clearUser() => setUser(null);

  /// Keeps identity changes and events ordered without blocking app actions.
  static Future<void> _enqueue(
    String operation,
    Future<void> Function(FirebaseAnalytics) send,
  ) {
    if (!_ready) return Future.value();
    Future<void> sendNext() async {
      if (!_ready) return;
      try {
        await send(_fa!).timeout(const Duration(seconds: 2));
      } catch (e, st) {
        // Stop after a hung SDK call rather than queueing events under an
        // identity whose update may not have completed.
        if (e is TimeoutException || operation == 'setUser') _ready = false;
        debugPrint('Analytics.$operation failed: $e\n$st');
      }
    }

    final previous = _pending;
    final work = previous == null
        ? sendNext()
        : previous.then((_) => sendNext());
    _pending = work;
    unawaited(
      work.then((_) {
        if (identical(_pending, work)) _pending = null;
      }),
    );
    return work;
  }

  /// Resolves a route to its registered template, excluding IDs and queries.
  static String screenName(String? route) {
    if (route == null || route.trim().isEmpty) return '';
    final uri = Uri.tryParse(route);
    if (uri == null) return 'unknown';
    final List<String> segments;
    try {
      segments = uri.pathSegments;
    } on FormatException {
      return 'unknown';
    }
    for (final pattern in _routes) {
      if (pattern.length != segments.length) continue;
      var matches = true;
      for (var i = 0; i < pattern.length; i++) {
        if (!pattern[i].startsWith(':') && pattern[i] != segments[i]) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return pattern.isEmpty
            ? 'root'
            : _clip(_normalize(pattern.join('_')), 100);
      }
    }
    return 'unknown';
  }

  static Future<void> logScreen(String? route) async {
    if (!_ready) return;
    final name = screenName(route);
    if (name.isEmpty) return;
    final role = _role;
    await _enqueue(
      'logScreen',
      (client) => client.logScreenView(
        screenName: name,
        screenClass: name,
        parameters: {'partner_role': ?role},
      ),
    );
  }

  /// UI click / button tap.
  static Future<void> tap(String? name, {String? screen}) async {
    final tapName = sanitizeName(name ?? '');
    if (tapName.isEmpty) return;
    await event(
      'ui_tap',
      params: {
        'name': tapName,
        'screen': screenName(screen ?? Get.currentRoute),
      },
    );
  }

  static Future<void> event(String name, {Map<String, Object?>? params}) async {
    if (!_ready) return;
    final eventName = sanitizeName(name);
    if (eventName.isEmpty) return;
    final cleaned = <String, Object>{'partner_role': ?_role};
    params?.forEach((key, value) {
      if (value == null || cleaned.length >= 25) return;
      final k = sanitizeName(key);
      if (k.isEmpty) return;
      if (value is num && value.isFinite) {
        cleaned[k] = value;
      } else if (value is bool) {
        cleaned[k] = value ? 1 : 0;
      } else if (value is String) {
        cleaned[k] = _clip(value, 100);
      }
    });
    await _enqueue(
      'event($eventName)',
      (client) => client.logEvent(
        name: eventName,
        parameters: cleaned.isEmpty ? null : cleaned,
      ),
    );
  }

  /// Records a business outcome once, including failures, even if its view has
  /// closed. Payloads must contain only explicitly selected reporting fields.
  static Future<BaseModel<T>> trackRequest<T>(
    String name, {
    required Future<BaseModel<T>> Function() request,
    Map<String, Object?> params = const {},
  }) async {
    final revision = _identityRevision;
    final context = <String, Object?>{
      ...params,
      'screen': screenName(Get.currentRoute),
    };
    void record(bool success) {
      // A response belonging to a previous session must not be attributed to
      // the next account (or to the anonymous user after logout).
      if (revision != _identityRevision) return;
      unawaited(event(name, params: {...context, 'success': success}));
    }

    try {
      final result = await request();
      record(result.isSuccess);
      return result;
    } catch (_) {
      record(false);
      rethrow;
    }
  }

  // --- Typed business helpers ---

  static Future<void> login({String? role}) =>
      event('login', params: {'method': 'password', 'role': role});

  static Future<void> logout() => event('logout');

  static Future<void> preIpoDetailView({
    required int companyId,
    required String companySlug,
    required String brandName,
    required String viewer,
  }) => event(
    'pre_ipo_detail_view',
    params: {
      'company_id': companyId,
      'company_slug': companySlug,
      'brand_name': brandName,
      'viewer': viewer,
    },
  );

  static Future<void> preIpoOfferSelect({
    required int companyId,
    required int dealId,
    required num price,
  }) => event(
    'pre_ipo_offer_select',
    params: {'company_id': companyId, 'deal_id': dealId, 'price': price},
  );

  static Future<void> primaryDetailView({
    required int companyId,
    required String companySlug,
    required String brandName,
  }) => event(
    'primary_detail_view',
    params: {
      'company_id': companyId,
      'company_slug': companySlug,
      'brand_name': brandName,
    },
  );

  static Future<void> secondaryDetailView({
    required int companyId,
    required String companySlug,
    required String brandName,
  }) => event(
    'secondary_detail_view',
    params: {
      'company_id': companyId,
      'company_slug': companySlug,
      'brand_name': brandName,
    },
  );

  /// Firebase-safe snake_case name (max 40 chars).
  static String sanitizeName(String raw) {
    var cleaned = _normalize(raw);
    if (cleaned.isEmpty) return '';
    if (!RegExp(r'^[a-z]').hasMatch(cleaned) ||
        ['firebase_', 'google_', 'ga_'].any(cleaned.startsWith)) {
      cleaned = 'app_$cleaned';
    }
    return _clip(cleaned, 40);
  }

  static String _normalize(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.isEmpty) return '';
    final cleaned = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned;
  }

  static String _clip(String value, int max) =>
      value.length <= max ? value : value.substring(0, max);
}

/// One screen-view source. Dialogs, sheets and snackbars are not page visits.
class _AnalyticsObserver extends NavigatorObserver {
  void _screen(Route<dynamic>? route) {
    if (route is PageRoute) unawaited(Analytics.logScreen(route.settings.name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _screen(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _screen(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _screen(previousRoute);
  }
}
