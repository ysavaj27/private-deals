import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/shared/app_exports.dart';

final DioConfig dioConfig = DioConfig();

// #region agent log
int _agentLogCount = 0;
int _apiLogCount = 0;

void _debugNdjson(String hypothesisId, String location, String message,
    Map<String, dynamic> data, {String runId = 'pre-fix'}) {
  final payload = <String, dynamic>{
    'sessionId': 'd3aa53',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'runId': runId,
  };
  // Prefer local file append so Flutter web/device CORS cannot drop logs.
  try {
    // ignore: avoid_print
    debugPrint('[agent-log] ${payload['location']}: ${payload['message']} $data');
  } catch (_) {}
  Dio()
      .post(
        'http://127.0.0.1:7415/ingest/9642249b-a697-472d-b58b-e135d6ec4dd4',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': 'd3aa53',
          },
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      )
      .then((_) {}, onError: (_) {});
}

void debugNdjson(String hypothesisId, String location, String message,
    Map<String, dynamic> data) {
  _debugNdjson(hypothesisId, location, message, data);
}

void agentLog(
  String hypothesisId,
  String location,
  String message,
  Map<String, dynamic> data,
) {
  _agentLogCount++;
  _debugNdjson(hypothesisId, location, message, {
    ...data,
    'agentLogCount': _agentLogCount,
  });
  Dio()
      .post(
        'http://127.0.0.1:7381/ingest/3656f79e-c7de-4216-93be-fc1c1a370c79',
        data: {
          'sessionId': 'b4d366',
          'hypothesisId': hypothesisId,
          'location': location,
          'message': message,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'runId': 'pre-fix',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': 'b4d366',
          },
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      )
      .then((_) {}, onError: (_) {});
}
// #endregion

class DioConfig {
  final Dio dio;

  DioConfig()
    : dio = Dio(
        BaseOptions(
          baseUrl: AppUrl.baseApiURL,
          followRedirects: false,
          connectTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 45),
        ),
      ) {
    dio.interceptors.add(ApiInterceptor());
    if (kDebugMode) dio.interceptors.add(ApiLogInterceptor());
  }

  Future<Response> get(
    String url,
    Map<String, dynamic> params, {
    bool isCustomUrl = false,
  }) => dio.get(url, queryParameters: params);

  Future<Response> getBytes(
    String url,
    Map<String, dynamic> params,
  ) => dio.get(
    url,
    queryParameters: params,
    options: Options(responseType: ResponseType.bytes),
  );

  Future<Response> post(
    String url,
    Map<String, dynamic> body, [
    bool isRawData = true,
  ]) => dio.post(url, data: isRawData ? body : FormData.fromMap(body));

  Future<Map<String, dynamic>> createBytesImage({
    required Uint8List image,
    required String imageName,
    required String key,
  }) async => {key: MultipartFile.fromBytes(image, filename: imageName)};

  Future<Map<String, dynamic>> createMedia(MediaModel media, String key) async {
    if (media.dataType == FileDataType.bytes && media.uint8list != null) {
      return createBytesImage(
        image: media.uint8list!,
        imageName: media.name,
        key: key,
      );
    }
    if (!kIsWeb &&
        media.dataType == FileDataType.filePath &&
        media.path.isNotEmpty) {
      return createFileImage(media.path, media.name, key);
    }
    return {};
  }

  Future<Map<String, MultipartFile>> createFileImage(
    String imagePath,
    String fileName,
    String key,
  ) async => {key: await MultipartFile.fromFile(imagePath, filename: fileName)};
}

/// Prints API traffic in debug builds only. Runs after [ApiInterceptor] so
/// the log includes the headers that interceptor attaches.
class ApiLogInterceptor extends Interceptor {
  static final Logger _log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      colors: false,
      printEmojis: false,
      noBoxingByDefault: true,
    ),
    output: _DebugPrintOutput(),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['apiLogStartedAt'] = DateTime.now();
    // #region agent log
    _apiLogCount++;
    _debugNdjson('C', 'ApiLogInterceptor.onRequest', 'api log print', {
      'path': options.uri.path,
      'method': options.method,
      'apiLogCount': _apiLogCount,
    });
    // #endregion
    _log.i(
      _safe({
        'endpoint': '${options.method} ${options.uri}',
        'headers': options.headers,
        if (options.queryParameters.isNotEmpty)
          'query': options.queryParameters,
        'body': _describeBody(options.data),
      }),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final summarized = _summarizeForLog(response.data);
    // #region agent log
    _debugNdjson('C', 'ApiLogInterceptor.onResponse', 'api log response print', {
      'path': options.uri.path,
      'status': response.statusCode,
      'payloadType': response.data.runtimeType.toString(),
      'payloadChars': response.data?.toString().length ?? 0,
      'summarizedChars': summarized.toString().length,
      'apiLogCount': _apiLogCount,
      'runId': 'post-fix',
    });
    // #endregion
    _log.i(
      _safe({
        'endpoint': '${options.method} ${options.uri}',
        'status': response.statusCode,
        'durationMs': _elapsedMs(options),
        'headers': response.headers.map,
        'response': summarized,
      }),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    _log.e(
      _safe({
        'endpoint': '${options.method} ${options.uri}',
        'status': err.response?.statusCode,
        'durationMs': _elapsedMs(options),
        'type': err.type.name,
        'headers': err.response?.headers.map,
        'response': _summarizeForLog(err.response?.data),
        'message': err.message,
      }),
    );
    handler.next(err);
  }

  int? _elapsedMs(RequestOptions options) {
    final started = options.extra['apiLogStartedAt'];
    if (started is! DateTime) return null;
    return DateTime.now().difference(started).inMilliseconds;
  }

  Object? _describeBody(dynamic data) {
    if (data is! FormData) return data;
    return {
      'fields': {for (final field in data.fields) field.key: field.value},
      'files': [
        for (final file in data.files)
          {
            'key': file.key,
            'filename': file.value.filename,
            'length': file.value.length,
          },
      ],
    };
  }

  /// Avoid flooding the console with large arrays like `share_prices`.
  dynamic _summarizeForLog(dynamic value, [String? key]) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString():
              _summarizeForLog(entry.value, entry.key.toString()),
      };
    }
    if (value is Iterable) {
      final list = value.toList();
      final keyName = (key ?? '').toLowerCase();
      final isSharePrices = keyName.contains('share_price');
      if (isSharePrices || list.length > 20) {
        return {
          '_omitted': true,
          'count': list.length,
          'sample': list
              .take(isSharePrices ? 1 : 3)
              .map((e) => _summarizeForLog(e))
              .toList(),
        };
      }
      return list.map(_summarizeForLog).toList();
    }
    return value.toString();
  }

  dynamic _safe(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _safe(entry.value),
      };
    }
    if (value is Iterable) return value.map(_safe).toList();
    return value.toString();
  }
}

class _DebugPrintOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      debugPrint(line);
    }
  }
}

class ApiInterceptor extends Interceptor {
  static bool isPrivateDealsApi(Uri uri) {
    final base = Uri.parse(AppUrl.baseApiURL);
    return uri.origin == base.origin && uri.path.startsWith(base.path);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!isPrivateDealsApi(options.uri)) {
      // Public third-party lookups must never receive our credentials.
      options.headers.removeWhere(
        (key, _) => [
          'authorization',
          AppKey.appKeys.toLowerCase(),
          'userid',
        ].contains(key.toLowerCase()),
      );
      handler.next(options);
      return;
    }
    options.extra['sessionRevision'] = app.revision;
    final path = options.uri.path;
    if (path.contains('/investor/') &&
        !path.contains('/business/investor/') &&
        !path.endsWith('/investor/register-inquiry')) {
      handler.reject(
        DioApiError(options, 'Use the Partner workflow for this action.'),
      );
      return;
    }
    final isRecovery = path.contains('/business/forgot-password');
    final isLogin = path.endsWith('/business/login');
    // #region agent log
    if (isLogin) {
      agentLog('A', 'dio_config.dart:onRequest', 'login request', {
        'path': path,
        'device': init.deviceOs,
        'deviceIdEmpty': init.deviceId.isEmpty,
        'userTypeHeader': 'distributor',
        'hasHeadToken': true,
      });
    }
    // #endregion
    final isProfileGet =
        path.endsWith('/business/profile') && options.method == 'GET';
    final isLogout = path.endsWith('/business/logout');
    final isPassword = path.endsWith('/business/changepassword');
    if (path.contains('/seller/')) {
      // Only the restored seller screens may use legacy endpoints. Company,
      // deal, authentication, and investor calls keep their business APIs.
      final sellerPath = path.substring(path.indexOf('/v2/seller/') + 1);
      final supported = options.method == 'GET'
          ? const {
              'v2/seller/dashboard',
              'v2/seller/sell-enquiries/list',
              'v2/seller/pre-ipo/transaction',
              'v2/seller/profile',
            }.contains(sellerPath)
          : options.method == 'POST' &&
                sellerPath == 'v2/seller/profile/update';
      if (!path.contains('/v2/seller/') ||
          !supported ||
          AccessPolicy.check(app.access, AccessScope.institution) !=
              AccessResult.allowed) {
        handler.reject(
          DioApiError(
            options,
            'This account cannot perform this seller action.',
          ),
        );
        return;
      }
    }
    if (path.contains('/business/') &&
        !isLogin &&
        !isRecovery &&
        !isProfileGet &&
        !isLogout) {
      final isInvestor = path.contains('/v2/business/investor');
      final isProfilePhoto =
          path.endsWith('/business/profile') && options.method == 'POST';
      final scope = isProfilePhoto || isPassword
          ? AccessScope.account
          : path.contains('/business/institution/')
          ? AccessScope.institution
          : path.contains('/business/enquiries/')
          ? AccessScope.enquiries
          : isInvestor
          ? AccessScope.investors
          : AccessScope.business;
      final result = AccessPolicy.check(
        app.access,
        scope,
        changingPassword: isPassword,
      );
      if (result != AccessResult.allowed) {
        handler.reject(
          DioApiError(options, 'This account cannot perform this action.'),
        );
        return;
      }
    }
    options.headers.addAll({
      AppKey.appKeys: AppKey.appKeyValue,
      'deviceid': init.deviceId,
      'devicetype': kIsWeb ? 'web' : init.deviceOs,
      'userid': app.userId,
      'usertype': 'distributor',
      'isdebug': kDebugMode || app.isDemo ? 1 : 0,
    });
    if (!isLogin && !isRecovery && app.token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${app.token}';
    }
    // #region agent log
    if (!isLogin) {
      agentLog('G', 'dio_config.dart:onRequest', 'authenticated request', {
        'path': path,
        'method': options.method,
        'hasAuth': options.headers.containsKey('Authorization'),
        'role': app.role.apiValue,
      });
    }
    // #endregion
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final revision = response.requestOptions.extra['sessionRevision'];
    if (revision != null && revision != app.revision) {
      handler.reject(
        DioApiError(
          response.requestOptions,
          'The session changed. Please retry.',
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    if (error.response?.statusCode == 401 &&
        options.headers.containsKey('Authorization')) {
      final path = options.uri.path;
      // Seller endpoints use seller-api-guard. A Partner/Institution token can
      // receive 401 there without the Partner session being invalid.
      final sellerGuardRejection = path.contains('/seller/');
      final revision = options.extra['sessionRevision'];
      final expired = !sellerGuardRejection &&
          revision is int &&
          await app.expire(revision);
      // #region agent log
      agentLog('G', 'dio_config.dart:onError', 'authenticated 401', {
        'path': path,
        'expired': expired,
        'sellerGuardRejection': sellerGuardRejection,
        'revisionMatch': revision == app.revision,
      });
      // #endregion
      if (expired) {
        // Keep controllers alive until GetX removes the outgoing route.
        if (Get.key.currentState != null) Get.offAllNamed(Routes.signIn);
      }
    }
    // #region agent log
    if (options.uri.path.endsWith('/business/login')) {
      agentLog('A', 'dio_config.dart:onError', 'login http error', {
        'statusCode': error.response?.statusCode,
        'dioType': error.type.name,
        'errorType': error.runtimeType.toString(),
      });
    }
    // #endregion
    final body = error.response?.data;
    final message = body is Map && body['message'] is String
        ? body['message'] as String
        : error is DioApiError
        ? error.message
        : error.response?.statusCode == 403
        ? 'You do not have permission for this action.'
        : error.response?.statusCode == 401
        ? 'Please sign in again.'
        : 'Unable to reach the server. Please try again.';
    handler.reject(DioApiError(options, message, response: error.response));
  }
}

class DioApiError extends DioException {
  @override
  final String message;

  DioApiError(RequestOptions options, this.message, {Response? response})
    : super(requestOptions: options, response: response);

  @override
  String toString() => message;
}
