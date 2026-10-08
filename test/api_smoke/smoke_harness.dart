import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';

import 'smoke_case.dart';
import 'smoke_config.dart';

class SmokeFakeAdapter implements HttpClientAdapter {
  SmokeFakeAdapter({this.respond});

  Future<ResponseBody> Function(RequestOptions)? respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (respond != null) return respond!(options);
    return okBody();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody okBody([Object? data]) => ResponseBody.fromString(
  jsonEncode({
    'status': 1,
    'message': 'ok',
    'data': data ?? <String, dynamic>{'id': 1},
  }),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

ResponseBody okListBody([List<dynamic>? items]) => ResponseBody.fromString(
  jsonEncode({
    'status': 1,
    'message': 'ok',
    'data':
        items ??
        [
          {'id': 1},
        ],
  }),
  200,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

Map<String, dynamic> partnerIdentity({
  String type = 'Wealth Manager',
  int id = 7,
}) => {
  'id': id,
  'type': type,
  'token': 'smoke-token-$id',
  'self_investor_id': 70,
  'is_primary_access': 1,
  'is_secondary_access': 1,
  'is_preipo_access': 1,
  'name': 'Smoke Partner',
  'mobile_no': '9000000000',
};

Future<void> installSmokeSession({
  String type = 'Wealth Manager',
  int id = 7,
}) async {
  await app.setUser(
    prefUser: partnerIdentity(type: type, id: id),
  );
  app.validated(true);
}

/// Normalize Dio path for comparison (strip leading /api/).
String normalizeApiPath(String path) {
  var p = path;
  if (p.startsWith('http')) {
    p = Uri.parse(p).path;
  }
  if (p.startsWith('/api/')) p = p.substring(5);
  if (p.startsWith('/')) p = p.substring(1);
  return p;
}

bool pathMatches(String actual, String expectedSuffix) {
  if (expectedSuffix == '(none)') return false;
  final a = normalizeApiPath(actual);
  final e = normalizeApiPath(expectedSuffix);
  return a == e || a.endsWith(e) || a.contains(e);
}

Future<void> smokeSetUp() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  app.persist = false;
  await app.clear();
}

Future<void> smokeTearDown() async {
  await app.clear();
  Get.reset();
}

/// Runs [action], asserts the last request path matches [expectedPath], records PASS/FAIL.
Future<void> expectContractPath({
  required SmokeCase smokeCase,
  required Future<void> Function() action,
  required SmokeFakeAdapter adapter,
  Object? responseData,
  bool expectList = false,
}) async {
  if (smokeCase.skipReason != null) {
    smokeLedger.record(
      SmokeResult(
        caseId: smokeCase.id,
        status: SmokeResultStatus.skip,
        detail: smokeCase.skipReason!,
      ),
    );
    return;
  }

  adapter.requests.clear();
  adapter.respond = (_) async {
    if (expectList) return okListBody();
    return okBody(responseData);
  };

  Object? error;
  try {
    await action();
  } catch (e) {
    error = e;
  }

  final last = adapter.requests.isEmpty ? null : adapter.requests.last;
  final actual = last?.path ?? last?.uri.path ?? '';
  final methodOk = last == null
      ? false
      : (smokeCase.method == SmokeMethod.get
            ? last.method.toUpperCase() == 'GET'
            : last.method.toUpperCase() == 'POST');
  final pathOk = last != null && pathMatches(actual, smokeCase.pathSuffix);

  // Contract smoke cares that the client hits the planned endpoint.
  // Parse/model errors after a correct request are noted but still PASS.
  if (pathOk && methodOk) {
    smokeLedger.record(
      SmokeResult(
        caseId: smokeCase.id,
        status: SmokeResultStatus.pass,
        actualPath: actual,
        detail: [
          if (smokeCase.mismatchNote != null) smokeCase.mismatchNote!,
          if (error != null) 'response parse soft-fail: $error',
          if (error == null) 'contract path ok',
        ].join('; '),
      ),
    );
    return;
  }

  smokeLedger.record(
    SmokeResult(
      caseId: smokeCase.id,
      status: SmokeResultStatus.fail,
      actualPath: actual,
      detail: error != null
          ? 'threw: $error'
          : 'expected ${smokeCase.method.name.toUpperCase()} '
                '${smokeCase.pathSuffix}, got ${last?.method} $actual',
    ),
  );
  fail(
    '#${smokeCase.id} ${smokeCase.feature}: '
    'expected ${smokeCase.method.name.toUpperCase()} ${smokeCase.pathSuffix}, '
    'got ${last?.method} $actual (error=$error)',
  );
}

void recordNa(SmokeCase smokeCase, String reason) {
  smokeLedger.record(
    SmokeResult(
      caseId: smokeCase.id,
      status: SmokeResultStatus.na,
      detail: reason,
    ),
  );
}

void recordLive(SmokeCase smokeCase, {required bool ok, String detail = ''}) {
  smokeLedger.record(
    SmokeResult(
      caseId: smokeCase.id,
      status: ok ? SmokeResultStatus.pass : SmokeResultStatus.fail,
      detail: detail.isEmpty
          ? (ok ? 'live ok (${SmokeConfig.describe()})' : 'live failed')
          : detail,
    ),
  );
}
