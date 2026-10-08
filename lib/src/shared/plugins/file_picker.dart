import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/models/media_model.dart';

class FilePickers {
  Future<MediaModel?> pickLogo() async {
    final result = await pickSingleImage();
    if (result != null &&
        (result.uint8list == null ||
            result.uint8list!.isEmpty ||
            result.uint8list!.length > 2 * 1024 * 1024)) {
      throw const FormatException('Choose a non-empty image up to 2 MB.');
    }
    return result;
  }

  Future<List<MediaModel>> pickFile({
    bool multiple = false,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    final List<PlatformFile> files;
    if (multiple) {
      files = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
    } else {
      final file = await FilePicker.pickFile(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      files = file == null ? [] : [file];
    }
    return [
      for (final file in files)
        MediaModel(
          type: type,
          name: file.name,
          uint8list: await file.readAsBytes(),
          dataType: FileDataType.bytes,
        ),
    ];
  }

  Future<MediaModel?> pickSingleImage({bool isCropper = false}) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    return MediaModel(
      type: FileType.image,
      name: file.name,
      uint8list: await file.readAsBytes(),
      dataType: FileDataType.bytes,
    );
  }
}
