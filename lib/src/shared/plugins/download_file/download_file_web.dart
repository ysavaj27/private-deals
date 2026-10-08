import 'dart:js_interop';

import 'package:private_deals/src/shared/app_exports.dart';
import 'package:dio/dio.dart';
import 'package:web/web.dart' as web;

class DownloadFile {
  static final Dio dio = Dio();

  static Future<String> downloadFromByte({
    required List<int> bytes,
    required String fileName,
    bool isTempPath = false,
  }) async {
    try {
      return await saveBytesWeb(bytes, fileName) ? fileName : '';
    } catch (e, t) {
      logger.e(
        'Error found in downloadFromByte on web',
        error: e.toString(),
        stackTrace: t,
      );
      return '';
    }
  }

  static Future<bool> downloadFromUrl({
    required String url,
    String fileName = '',
    RxDouble? progress,
    Function(int received, int total)? onProgress,
  }) async {
    try {
      if (url.isEmpty) {
        toast('File Not Found');
        return false;
      }

      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percent = (received / total * 100).toInt();

            progress?.value = percent.toDouble();
            onProgress?.call(percent, total);
          }
        },
      );

      final bytes = response.data;

      if (bytes == null) {
        return false;
      }

      final resolvedName = fileName.isNotEmpty
          ? _buildFileName(fileName, url)
          : _extractFileName(url);

      return await saveBytesWeb(bytes, resolvedName);
    } catch (e, t) {
      toast(e.toString(), MessageEnum.error);

      logger.e(
        'Error found in downloadFromUrl on web',
        error: e.toString(),
        stackTrace: t,
      );

      return false;
    }
  }

  static Future<bool> saveBytesWeb(List<int> bytes, String fileName) async {
    try {
      final jsBytes = Uint8List.fromList(bytes).toJS;

      final blob = web.Blob(
        [jsBytes].toJS,
        web.BlobPropertyBag(type: 'application/octet-stream'),
      );

      final url = web.URL.createObjectURL(blob);

      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = fileName
        ..style.display = 'none';

      web.document.body?.append(anchor);

      anchor.click();

      anchor.remove();

      web.URL.revokeObjectURL(url);

      return true;
    } catch (e, t) {
      logger.e('Web save error', error: e.toString(), stackTrace: t);

      return false;
    }
  }

  static String _buildFileName(String fileName, String url) {
    if (fileName.contains('.')) {
      return fileName;
    }

    final extension = _extractExtension(url);

    if (extension.isEmpty) {
      return fileName;
    }

    return '$fileName.$extension';
  }

  static String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);

      final path = uri.path;

      if (path.isEmpty) {
        return 'download';
      }

      final name = path.split('/').last;

      if (name.isEmpty) {
        return 'download';
      }

      return name;
    } catch (_) {
      return 'download';
    }
  }

  static String _extractExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;

      if (!path.contains('.')) {
        return '';
      }

      return path.split('.').last;
    } catch (_) {
      return '';
    }
  }
}
