import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadFile {
  static final Dio dio = Dio();

  static Future<String> downloadFromByte({
    required List<int> bytes,
    required String fileName,
    bool isTempPath = false,
  }) async {
    try {
      final directory = await getSaveDirectory(
        tempPath: isTempPath,
      );

      logger.d('File Path :$directory');

      if (directory != null && directory.isNotEmpty) {
        final file = File('$directory/$fileName');

        logger.d('File Path :${file.path}');

        await file.writeAsBytes(bytes);

        logger.d('File downloaded to: ${file.path}');

        return file.path;
      }

      return '';
    } catch (e, t) {
      logger.e(
        'Error found in downloadFromByte',
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

      final directory = await getSaveDirectory();

      logger.d('File Path :$directory');

      if (directory == null || directory.isEmpty) {
        return false;
      }

      final fileExtension = _extractExtension(url);

      final resolvedFileName = fileName.isNotEmpty
          ? _buildFileName(fileName, fileExtension)
          : _extractFileName(url);

      final separator = Platform.isWindows ? r'\' : '/';

      final filePath = '$directory$separator$resolvedFileName';

      logger.d('Download File Path :$filePath');

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percent = (received / total * 100).toInt();

            progress?.value = percent.toDouble();

            onProgress?.call(percent, total);
          }
        },
      );

      if (Platform.isIOS ||
          Platform.isAndroid ||
          Platform.isMacOS) {
        logger.d('Notification Called :$resolvedFileName');

        NotificationServices.showNotification(
          id: 1,
          title: 'Download complete',
          body: 'Tap to open $resolvedFileName',
          payload: filePath,
        );
      } else if (PlatformHelper.isWindows) {
        await DesktopNotification.showNotification(
          filePath,
          resolvedFileName,
        );
      }

      return true;
    } catch (e, t) {
      toast(
        e.toString(),
        MessageEnum.error,
      );

      logger.e(
        'Error found in downloadFromUrl',
        error: e.toString(),
        stackTrace: t,
      );

      return false;
    }
  }

  static Future<String?> getSaveDirectory({
    bool tempPath = true,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (tempPath) {
        return (await getTemporaryDirectory()).path;
      }

      await requestStoragePermission();

      return (await getApplicationDocumentsDirectory()).path;
    }

    if (PlatformHelper.isWindows) {
      return (await getDownloadsDirectory())?.path ??
          (await getApplicationDocumentsDirectory()).path;
    }

    if (Platform.isMacOS) {
      return (await getDownloadsDirectory())?.path ??
          (await getApplicationDocumentsDirectory()).path;
    }

    return null;
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid && await isAndroid13OrAbove()) {
      logger.d(
        'Request Grant :${init.androidVersion}',
      );

      if (await Permission.manageExternalStorage
          .request()
          .isGranted) {
        return true;
      }

      await Permission.manageExternalStorage.request();

      return false;
    }

    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> isAndroid13OrAbove() async {
    if (init.androidVersion != 0 &&
        init.androidVersion >= 13) {
      return true;
    }

    return false;
  }

  static Future<String?> getUserSaveDirectory() async {
    final downloadsDirectory = await getDownloadsDirectory();

    final directory = await getDirectoryPath(
      confirmButtonText: 'Select Folder',
      initialDirectory: downloadsDirectory?.path,
    );

    return directory;
  }

  static String _buildFileName(
      String fileName,
      String extension,
      ) {
    if (fileName.contains('.')) {
      return fileName;
    }

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

      return name.isEmpty ? 'download' : name;
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