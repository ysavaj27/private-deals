import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'package:private_deals/src/features/institution/data/models/common/enums.dart';

class MediaModel {
  FileType type;
  String name;
  String url;
  String path;
  FileDataType dataType;
  File? file;
  Uint8List? uint8list;

  bool get isEmpty => dataType == FileDataType.none;

  MediaModel({
    this.type = FileType.any,
    this.name = "",
    this.url = "",
    this.path = "",
    this.dataType = FileDataType.none,
    this.file,
    this.uint8list,
  });
}
