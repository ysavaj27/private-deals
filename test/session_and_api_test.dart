import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/config/app_key.dart';
import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody response(Map<String, dynamic> body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
Map<String, dynamic> identity([String type = 'Institution', int id = 7]) => {
  'id': id,
  'type': type,
  'token': 'test-token-$id',
  'self_investor_id': 70,
  'is_primary_access': 1,
  'is_secondary_access': 1,
  'is_preipo_access': 1,
};

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

  test('Business failure with data cannot authenticate', () async {
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async =>
          response({'status': 0, 'message': 'Denied', 'data': identity()}),
    );
    final result = await WAuthApi.login(
      mobileNo: '0000000000',
      password: 'test-only',
    );
    expect(result.isSuccess, false);
    expect(app.isUserLogin, false);
    expect(app.token, isEmpty);
  });
  test(
    'Successful login uses business endpoint; self investor never becomes principal',
    () async {
      final adapter = FakeAdapter(
        (_) async => response({'status': 1, 'data': identity()}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await WAuthApi.login(mobileNo: '0000000000', password: 'test-only');
      app.iUserModel(
        InvestorModel.fromJson({'id': 70, 'token': 'investor-selection'}),
      );
      expect(app.userId, 7);
      expect(app.token, 'test-token-7');
      expect(app.wUser.selfInvestorId, 70);
      expect(adapter.requests.single.uri.path, '/api/v1/business/login');
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        false,
      );
    },
  );
  test('A stored session is untrusted until profile succeeds', () async {
    await app.setUser(prefUser: identity());
    app.validated(false);
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': {'id': 7, 'type': 'Institution', 'self_investor_id': 70},
      }),
    );
    expect(app.isUserLogin, false);
    expect(await app.restore(), true);
    expect(app.token, 'test-token-7');
    expect(app.isUserLogin, true);
  });
  test(
    'Transient profile failure does not erase a recoverable token',
    () async {
      await app.setUser(prefUser: identity());
      app.validated(false);
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(await app.restore(), false);
      expect(app.token, 'test-token-7');
      expect(app.validated(), false);
    },
  );
  for (final status in [400, 403, 405, 500]) {
    test('HTTP $status preserves session', () async {
      await app.setUser(prefUser: identity());
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => response({'status': 0, 'message': 'Rejected'}, status),
      );
      await expectLater(
        dioConfig.get('v2/business/institution/company/list', {}),
        throwsA(isA<DioException>()),
      );
      expect(app.isUserLogin, true);
    });
  }
  test('Current-session 401 clears identity', () async {
    await app.setUser(prefUser: identity());
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'message': 'Expired'}, 401),
    );
    await expectLater(
      dioConfig.get('v2/business/institution/company/list', {}),
      throwsA(isA<DioException>()),
    );
    expect(app.token, isEmpty);
  });

  test('Seller-guard 401 does not clear Partner session', () async {
    await app.setUser(prefUser: identity());
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'message': 'Unauthenticated.'}, 401),
    );
    await expectLater(
      dioConfig.post('v2/seller/profile/update', {'logo': 'x'}, false),
      throwsA(isA<DioException>()),
    );
    expect(app.token, 'test-token-7');
    expect(app.isUserLogin, isTrue);
  });

  test('Institution can post display photo on v2 business profile', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': {...identity(), 'profile_photo': 'https://cdn.example/a.png'},
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final res = await dioConfig.post('v2/business/profile', {
      'logo': 'bytes',
    }, false);
    expect(res.statusCode, 200);
    expect(adapter.requests.single.uri.path, '/api/v2/business/profile');
  });
  test('A late 401 cannot log out a newer account', () async {
    await app.setUser(prefUser: identity());
    dioConfig.dio.httpClientAdapter = FakeAdapter((_) async {
      await app.setUser(prefUser: identity('Wealth Manager', 9));
      return response({'message': 'Expired'}, 401);
    });
    await expectLater(
      dioConfig.get('v2/business/institution/company/list', {}),
      throwsA(isA<DioException>()),
    );
    expect(app.userId, 9);
    expect(app.isUserLogin, true);
  });
  test('Wrong role cannot even send Institution requests', () async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    await expectLater(
      dioConfig.get('v2/business/institution/company/list', {}),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, isEmpty);
  });
  test('Institution cannot call the WM dashboard', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    await expectLater(
      dioConfig.get('v1/business/dashboard', {}),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, isEmpty);
  });
  test('Third-party calls never receive Partner credentials', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    await dioConfig.get('https://example.com/public', {}, isCustomUrl: true);
    expect(adapter.requests.single.headers.containsKey('Authorization'), false);
    expect(adapter.requests.single.headers.containsKey(AppKey.appKeys), false);
  });
  test(
    'v2 investor filters are independent; create sends only new contract fields',
    () async {
      await app.setUser(prefUser: identity('Wealth Manager'));
      final adapter = FakeAdapter(
        (options) async => response({
          'status': 1,
          'data': options.method == 'GET' ? [] : {'id': 22},
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await WInvestorsApi.investorsList(
        isKyc: 'Yes',
        isActive: 'No',
        isAif: 'All',
      );
      expect(adapter.requests.last.queryParameters, {
        'is_kyc': 'Yes',
        'is_active': 'No',
        'is_aif': 'All',
      });
      await WInvestorsApi.addInvestor(
        id: 0,
        investorType: 'Individual',
        name: 'Client',
        mobileNumber: '0000000000',
      );
      expect(adapter.requests.last.uri.path, '/api/v2/business/investor');
      expect((adapter.requests.last.data as Map).keys.toSet(), {
        'investor_type',
        'name',
        'mobile_number',
      });
      await WInvestorsApi.addInvestor(
        id: 0,
        investorType: 'Individual',
        name: 'Client',
        mobileNumber: '0000000000',
        email: ' Client@Example.com ',
        gender: 'Male',
      );
      expect((adapter.requests.last.data as Map), {
        'investor_type': 'Individual',
        'name': 'Client',
        'mobile_number': '0000000000',
        'email': 'client@example.com',
        'gender': 'Male',
      });
    },
  );
  test('Recovery id stays separate from authentication', () async {
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({
        'status': 1,
        'data': {'id': 123},
      }),
    );
    await WAuthApi.forgotPassword(phoneNo: '0000000000');
    expect(app.recoveryPartnerId, 123);
    expect(app.token, isEmpty);
    expect(app.isUserLogin, false);
  });
  test('Self investor KYC can be saved with the partner token', () async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    final investor = InvestorModel.fromJson({'id': 70, 'is_self': 0});
    final result = await CmlApi.save(investor, {
      'dp_id': '1',
      'client_id': '2',
      'pan_no': 'TEST',
      'name': 'Self',
      'account_number': '000123456789',
      'ifsc_code': 'HDFC0000001',
    }, null);
    expect(result.isSuccess, true, reason: result.m);
    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer test-token-7',
    );
  });
}
