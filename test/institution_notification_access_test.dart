import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/notification/notification_api.dart';
import 'package:private_deals/src/shared/app_exports.dart' show Routes;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  test('Institution can open notification route', () async {
    await app.setUser(prefUser: identity('Institution'));
    app.validated(true);
    expect(
      SessionNavigation.check(Routes.notificationPage),
      AccessResult.allowed,
    );
  });

  test('Institution can call notifications API', () async {
    await app.setUser(prefUser: identity('Institution'));
    app.validated(true);
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'message': 'ok',
        'data': <Map<String, dynamic>>[],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final result = await NotificationApi.wNotificationList();
    expect(result.isSuccess, isTrue);
    expect(
      adapter.requests.single.uri.path,
      contains('/business/notifications'),
    );
  });
}
