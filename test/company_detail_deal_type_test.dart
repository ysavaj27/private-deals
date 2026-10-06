import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/app/routing/routes.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/landing_page/unlisted_landing_page_api.dart';
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  test('Company detail requests only the company slug', () async {
    final adapter = FakeAdapter(
      (_) async => response({'status': 1, 'data': <String, dynamic>{}}),
    );
    dioConfig.dio.httpClientAdapter = adapter;

    await PreIpoLandingPageApi.wCompanyDetail('example');
    expect(adapter.requests.last.queryParameters, {'slug': 'example'});
  });

  test('Detail and investment routes omit the retired deal type filter', () {
    const base = '/wealth-manager/unlisted-shares';
    final detail = Routes.preIPODetailPath(base, 'example');
    expect(detail, '$base/detail/example');
    expect(Routes.preIPOInvestmentPath(detail), '$detail/investment');
    expect(Routes.preIPODetailPath('$base?deal_type=hot', 'example'), detail);
    expect(
      Routes.preIPOInvestmentPath('$detail?deal_type=hot'),
      '$detail/investment',
    );
  });

  test('Legacy links drop deal type but retain unrelated query parameters', () {
    const detail = '/wealth-manager/unlisted-shares/detail/example';
    final route = Uri.parse(
      Routes.preIPOInvestmentPath(
        '$detail?deal_type=hot&source=saved&tag=a&tag=b',
      ),
    );
    expect(route.path, '$detail/investment');
    expect(route.queryParameters.containsKey('deal_type'), isFalse);
    expect(route.queryParameters['source'], 'saved');
    expect(route.queryParametersAll['tag'], ['a', 'b']);
  });
}
