//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:private_deals/src/shared/models/base_model.dart';
// import 'package:private_deals/src/shared/plugins/logger.dart';
// import 'package:dio/dio.dart';
//
// import 'package:private_deals/src/core/config/app_key.dart';
// import 'package:private_deals/src/core/session/auth_session.dart';
//
// final Network net = Network();
//
// class Network {
//   // final Map<String, dynamic> _parameters = {};
//   static final Network _instance = Network.internal();
//   static final Dio _dio = Dio();
//
//   Network.internal();
//
//   factory Network() => _instance;
//
//   void init() {
//     _dio.options.headers.addAll({
//       'Content-Type': 'application/json',
//       AppKey.appKeys: AppKey.appKeyValue,
//     }) ;
//     if (app.isUserLogin && app.token.isNotEmpty) {
//       _dio.options.headers.addAll({'Authorization': 'Bearer ${app.token}'});
//     }
//   }
//
//   Future<BaseModel> get(
//       {required String url, required Map<String, dynamic> params}) async {
//     // if (kIsWeb) {
//     //   _dio.options.headers.removeWhere((key, value) => key == "apikey");
//     //   _dio.options.headers.removeWhere((key, value) => key == "token");
//     //   params.addAll(_parameters);
//     // }
//     var keysToRemove = <String>[];
//     params.forEach((key, value) {
//       if ((value is String) && (params[key].isEmpty)) {
//         keysToRemove.add(key);
//       }
//     });
//     for (var key in keysToRemove) {
//       params.remove(key);
//     }
//     logger.d(
//         "CALLING GET NET\nURL: $url\nPARAMS: $params\nHEADERS: ${_dio.options.headers}");
//     return _dio
//         .get(url, queryParameters: params)
//         .then(_success)
//         .catchError(_failed);
//   }
//
//   Future<BaseModel> post({
//     required String url,
//     dynamic body,
//     bool isRaw = false,
//     dynamic params,
//   }) async {
//     // if (kIsWeb) {
//     //   _dio.options.headers.removeWhere((key, value) => key == "apikey");
//     //   _dio.options.headers.removeWhere((key, value) => key == "token");
//     //   body.addAll(_parameters);
//     // }
//     /*  var keysToRemove = <String>[];
//     params.forEach((key, value) {
//       if ((value is String) && (params[key].isEmpty)) {
//         keysToRemove.add(key);
//       }
//     });
//     for (var key in keysToRemove) {
//       params.remove(key);
//     }*/
//     logger.d(
//         "CALLING POST NET\nURL: $url\nBODY : $body\nPARAMS: $params\nHEADERS: ${_dio.options.headers}");
//     dynamic data;
//     if (isRaw) {
//       data = json.encode(body);
//     } else {
//       data = FormData.fromMap(body);
//     }
//     return _dio
//         .post(url, data: data, queryParameters: params)
//         .then(_success)
//         .catchError(_failed);
//   }
//
//   BaseModel _success(Response response) {
//     final dynamic url = response.requestOptions.uri;
//     final dynamic data = response.data;
//     int? code = response.statusCode;
//     logger.i("URL : $url\nRESPONSE ${response.statusCode} : ${data["m"]}");
//     // logger.i("URL : $url\nRESPONSE ${response.statusCode} : ${data}");
//
//     BaseModel model = BaseModel();
//     if (code != null && code == 401) {
//       // app.logout();
//       model = BaseModel();
//     } else {
//       model = BaseModel.fromJson(data);
//     }
//     return model;
//   }
//
//   Future<BaseModel> _failed(error) async {
//     logger.e("onFailed\n$error");
//
//     String message = "Something went wrong";
//     try {
//       if (!(await isConnected())) {
//         message = "No internet connection";
//       } else if (error is DioException) {
//         logger.e(error.response);
//         // logger.e("status code ${error.response?.statusCode}");
//
//         DioException dError = error;
//         String requestMethod = dError.requestOptions.method;
//         String requestURI = dError.requestOptions.uri.path;
//
//         // switch (dError.type) {
//         //   case DioException.cancel:
//         //     message = "Request Cancelled";
//         //     // app.apiErrorCall(
//         //     //     apiUrl: requestURI,
//         //     //     apiMethod: requestMethod,
//         //     //     errorMessage: message);
//         //     break;
//         //   // case DioErrorType.connectionTimeout:
//         //   //   message = "Connection Timeout";
//         //   //   break;
//         //   // case DioErrorType.unknown:
//         //   //   message = "Something went wrong";
//         //   //   break;
//         //   case DioException.receiveTimeout:
//         //     message = "Receive Timeout";
//         //     // app.apiErrorCall(
//         //     //     apiUrl: requestURI,
//         //     //     apiMethod: requestMethod,
//         //     //     errorMessage: message);
//         //     break;
//         //   // case DioErrorType.badResponse:
//         //   //   int code = dError.response?.statusCode ?? 0;
//         //   //   if (code == 404) {
//         //   //     message = "Resource not found";
//         //   //   } else {
//         //   //     message = error.toString();
//         //   //   }
//         //   //   break;
//         //   case DioException.sendTimeout:
//         //     message = "Send Timeout";
//         //     // app.apiErrorCall(
//         //     //     apiUrl: requestURI,
//         //     //     apiMethod: requestMethod,
//         //     //     errorMessage: message);
//         //     break;
//         //   // case DioErrorType.badCertificate:
//         //   //   // TODO: Handle this case.
//         //   //   break;
//         //   // case DioErrorType.connectionError:
//         //   //   // TODO: Handle this case.
//         //   //   break;
//         //   case DioException.connectTimeout:
//         //     message = "Connection Timeout";
//         //     // app.apiErrorCall(
//         //     //     apiUrl: requestURI,
//         //     //     apiMethod: requestMethod,
//         //     //     errorMessage: message);
//         //     break;
//         //   case DioErrorType.response:
//         //     switch (dError.response!.statusCode) {
//         //       case 400:
//         //         message = 'Invalid request';
//         //         break;
//         //       case 401:
//         //         // app.unAuthenticateCall(
//         //         //     message: error.response?.data['m']);
//         //         message = 'Access denied';
//         //         break;
//         //       case 404:
//         //         message = 'The requested information could not be found';
//         //         break;
//         //       case 409:
//         //         message = 'Conflict occurred';
//         //         break;
//         //       case 500:
//         //         message =
//         //             'Internal server error occurred, please try again later.';
//         //         break;
//         //       case 503:
//         //         break;
//         //     }
//         //     break;
//         //   case DioErrorType.other:
//         //     message = "Something went wrong";
//         //     // app.apiErrorCall(
//         //     //     apiUrl: requestURI,
//         //     //     apiMethod: requestMethod,
//         //     //     errorMessage: message);
//         //     break;
//         // }
//         switch (error.type) {
//           case DioExceptionType.connectionTimeout:
//             message = 'Connection Timed out';
//             break;
//           case DioExceptionType.sendTimeout:
//             message = 'Send Timed out';
//             break;
//           case DioExceptionType.receiveTimeout:
//             message = 'Receive Timed out';
//             break;
//           case DioExceptionType.badResponse:
//             switch (error.response?.statusCode) {
//               case 400:
//                 message = 'Invalid request';
//                 break;
//               case 401:
//                 message = 'Access denied';
//                 break;
//               case 402:
//                 message = 'Access denied';
//                 break;
//               case 403:
//                 message = 'Access denied';
//                 break;
//               case 404:
//                 message = 'The requested information could not be found';
//                 break;
//               case 409:
//                 message = 'Conflict occurred';
//                 break;
//               case 500:
//                 message =
//                     'Internal server error occurred, please try again later';
//                 break;
//             }
//             break;
//           case DioExceptionType.unknown:
//             switch (error.response?.statusCode) {
//               case 400:
//                 message = 'Invalid request';
//                 break;
//               case 401:
//                 message = 'Access denied';
//                 dError;
//               case 402:
//                 message = 'Access denied';
//                 break;
//               case 403:
//                 message = 'Access denied';
//                 break;
//               case 404:
//                 message = 'The requested information could not be found';
//                 break;
//               case 409:
//                 message = 'Conflict occurred';
//                 break;
//               case 500:
//                 message =
//                     'Internal server error occurred, please try again later';
//                 break;
//             }
//             break;
//           case DioExceptionType.cancel:
//             message = "Request Cancelled";
//             break;
//           default:
//             break;
//         }
//       }
//     } catch (e) {
//       message = e.toString();
//     }
//     return BaseModel(m:  message, s: 0);
//   }
//
//   Future<bool> isConnected() async {
//     try {
//       List<InternetAddress> list = await InternetAddress.lookup('google.com');
//       return list.isNotEmpty && list[0].rawAddress.isNotEmpty;
//     } catch (e) {
//       return false;
//     }
//   }
// }
//
// // import 'dart:convert';
// // import 'dart:io';
// // import 'package:application/app/app_configration/app_flavors.dart';
// // import 'package:application/app/services/init_service.dart';
// // import 'package:application/data/common/constants/api_endpoints_constants.dart';
// // import 'package:application/data/common/constants/api_error_constants.dart';
// // import 'package:dio/dio.dart';
// // import 'package:application/app/utils/logger.dart';
// //
// //
// // final _ApiService apiService = _ApiService();
// //
// // class _ApiService {
// //
// //   static final _ApiService _instance = _ApiService.internal();
// //   _ApiService.internal();
// //
// //   factory _ApiService() => _instance;
// //
// //   _ApiService._();
// //
// //   static final Dio dio = createDio();
// //
// //   /// CREATE DIO
// //   static Dio createDio() {
// //     Dio dio = Dio();
// //     dio.options = BaseOptions();
// //     dio.interceptors.addAll({ApiInterceptor()});
// //     return dio;
// //   }
// //
// //   /// POST METHOD
// //   Future<Response> post(
// //       {required String url, required Map<String, dynamic> body}) async {
// //     logger.f("body --> $body");
// //     var res =
// //     await dio.post(AppFlavour.devFlavor
// //         ? ApiRoutes.devBaseUrl + url
// //         : ApiRoutes.baseUrl + url, data: FormData.fromMap(body));
// //     return res;
// //   }
// //
// //   /// GET METHOD
// //   Future<Response> get({
// //     required String url,
// //     required Map<String, dynamic> body,
// //   }) async {
// //     logger.f("url = $url");
// //     logger.f("url = ${dio.options.headers}");
// //     logger.f("body = $body");
// //     var res = await dio.get(
// //       AppFlavour.devFlavor
// //           ? ApiRoutes.devBaseUrl + url
// //           : ApiRoutes.baseUrl + url,
// //       queryParameters: body,
// //     );
// //     return res;
// //   }
// //
// // }
// //
// // /// Add Image
// // Future<MultipartFile> addImage({
// //   required File image,
// //   required String imageName,
// // }) async {
// //   return MultipartFile.fromFile(
// //     image.path,
// //     filename: imageName,
// //   );
// // }
// //
// // /// CREATE API INTERCEPTOR
// // class ApiInterceptor extends Interceptor {
// //   /// REQUEST
// //
// //   @override
// //   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
// //     // Map<String, dynamic> header = {};
// //     try {
// //       if (initService.userModel.value != null) {
// //         //logger.i("selected index value : ${selectedDefault}");
// //         options.headers.addAll({
// //           "apikey": initService.userModel.value?.apikey,
// //           "token": initService.userModel.value?.token,
// //         });
// //       }
// //       //   options.headers = {
// //       // 'Content-Type':'multipart/form-data'
// //
// //       return handler.next(options);
// //     } catch (e) {
// //       logger.e("catch exception = $e");
// //     }
// //   }
// //
// //   /// ERROR
// //   @override
// //   void onError(DioException err, ErrorInterceptorHandler handler) {
// //     DioException e = err;
// //     switch (err.type) {
// //       case DioExceptionType.connectionTimeout:
// //         e = ConnectionTimeOutException(err.requestOptions);
// //         break;
// //       case DioExceptionType.sendTimeout:
// //         e = SendTimeOutException(err.requestOptions);
// //         break;
// //       case DioExceptionType.receiveTimeout:
// //         e = ReceiveTimeOutException(err.requestOptions);
// //         break;
// //       case DioExceptionType.badResponse:
// //         switch (err.response?.statusCode) {
// //           case 400:
// //             e = BadRequestException(err.requestOptions);
// //             break;
// //           case 401:
// //             initService.logout();
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 402:
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 403:
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 404:
// //             e = NotFoundException(err.requestOptions);
// //             break;
// //           case 409:
// //             e = ConflictException(err.requestOptions);
// //             break;
// //           case 500:
// //             e = InternalServerErrorException(err.requestOptions);
// //             break;
// //         }
// //         break;
// //       case DioExceptionType.unknown:
// //         switch (err.response?.statusCode) {
// //           case 400:
// //             e = BadRequestException(err.requestOptions);
// //             break;
// //           case 401:
// //             initService.logout();
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 402:
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 403:
// //             e = UnauthorizedException(err.requestOptions);
// //             break;
// //           case 404:
// //             e = NotFoundException(err.requestOptions);
// //             break;
// //           case 409:
// //             e = ConflictException(err.requestOptions);
// //             break;
// //           case 500:
// //             e = InternalServerErrorException(err.requestOptions);
// //             break;
// //         }
// //         break;
// //       case DioExceptionType.cancel:
// //         break;
// //       default:
// //         break;
// //     }
// //     return handler.next(e);
// //   }
// //
// //   @override
// //   void onResponse(Response response, ResponseInterceptorHandler handler) {
// //     logger.f("${response.requestOptions.method} URL : ${response.requestOptions.path} , Body  : ${response.requestOptions.data} , QParam : ${response.requestOptions.queryParameters}\n\n\nResponse :${jsonEncode(response.data)}");
// //     handler.next(response);
// //   }
// // }
// //
// // /// When connection timeout
// // class ConnectionTimeOutException extends DioException {
// //   ConnectionTimeOutException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Connection Timed out, Please try again';
// //   }
// // }
// //
// // class SendTimeOutException extends DioException {
// //   SendTimeOutException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Send Timed out, Please try again';
// //   }
// // }
// //
// // class ReceiveTimeOutException extends DioException {
// //   ReceiveTimeOutException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Receive Timed out, Please try again';
// //   }
// // }
// //
// // //**********-----STATUS CODE ERROR HANDLERS--------**********
// //
// // class BadRequestException extends DioException {
// //   BadRequestException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Invalid request';
// //   }
// // }
// //
// // class InternalServerErrorException extends DioException {
// //   InternalServerErrorException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Internal server error occurred, please try again later.';
// //   }
// // }
// //
// // class ConflictException extends DioException {
// //   ConflictException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Conflict occurred';
// //   }
// // }
// //
// // class UnauthorizedException extends DioException {
// //   UnauthorizedException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'Access denied';
// //   }
// // }
// //
// // class NotFoundException extends DioException {
// //   NotFoundException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'The requested information could not be found';
// //   }
// // }
// //
// // class NoInternetConnectionException extends DioException {
// //   NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);
// //
// //   @override
// //   String toString() {
// //     return 'No internet connection detected, please try again.';
// //   }
// // }
