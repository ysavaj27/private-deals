import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';

final DioConfig dioConfig = DioConfig();

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
  }
  Future<Response> get(
    String url,
    Map<String, dynamic> params, {
    bool isCustomUrl = false,
  }) => dio.get(url, queryParameters: params);
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
        !path.endsWith('/investor/register-inquiry')) {
      handler.reject(
        DioApiError(options, 'Use the Partner workflow for this action.'),
      );
      return;
    }
    final isRecovery = path.contains('/business/forgot-password');
    final isLogin = path.endsWith('/business/login');
    final isProfile =
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
        !isProfile &&
        !isLogout) {
      final isInvestor = path.contains('/v2/business/investor');
      final scope = path.contains('/business/institution/')
          ? AccessScope.institution
          : isInvestor
          ? AccessScope.investors
          : isPassword
          ? AccessScope.account
          : AccessScope.business;
      final result = AccessPolicy.check(
        app.access,
        scope,
        changingPassword: isPassword,
      );
      if (result != AccessResult.allowed ||
          (app.role == PartnerRole.institution &&
              path.endsWith('/business/profile') &&
              options.method != 'GET')) {
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
      final revision = options.extra['sessionRevision'];
      if (revision is int && await app.expire(revision)) {
        // Keep controllers alive until GetX removes the outgoing route.
        if (Get.key.currentState != null) Get.offAllNamed(Routes.signIn);
      }
    }
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
