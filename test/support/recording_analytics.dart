import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';

class RecordedEvent {
  RecordedEvent(this.name, this.parameters, this.userId);
  final String name;
  final Map<String, Object> parameters;
  final String? userId;
}

class RecordingAnalytics implements FirebaseAnalytics {
  final events = <RecordedEvent>[];
  final properties = <String, String?>{};
  String? userId;
  bool failInit = false;
  bool failEvents = false;
  Completer<void>? identityGate;

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (failInit) throw StateError('SDK unavailable');
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (identityGate != null) await identityGate!.future;
    userId = id;
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) async => properties[name] = value;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
    List<AnalyticsEventItem>? items,
    AnalyticsCallOptions? callOptions,
  }) async {
    if (failEvents) throw StateError('Event rejected');
    events.add(RecordedEvent(name, parameters ?? {}, userId));
  }

  @override
  Future<void> logScreenView({
    String? screenClass,
    String? screenName,
    Map<String, Object>? parameters,
    AnalyticsCallOptions? callOptions,
  }) => logEvent(
    name: 'screen_view',
    parameters: {
      'screen_name': screenName!,
      'screen_class': screenClass!,
      ...?parameters,
    },
  );

  Future<void> drain() async {
    await Analytics.event('test_flush');
    events.removeWhere((event) => event.name == 'test_flush');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
