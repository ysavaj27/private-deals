import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';

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
    final result = await FilePicker.pickFiles(
      allowMultiple: multiple,
      type: type,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null) return [];
    return result.files
        .where((file) => file.bytes != null)
        .map(
          (file) => MediaModel(
            type: type,
            name: file.name,
            uint8list: file.bytes,
            dataType: FileDataType.bytes,
          ),
        )
        .toList();
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
