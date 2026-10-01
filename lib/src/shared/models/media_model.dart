import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';

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
