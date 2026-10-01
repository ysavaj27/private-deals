import 'package:private_deals/src/shared/app_exports.dart';
import 'package:open_filex/open_filex.dart';

void openFile(String path) {
  try {
    OpenFilex.open(path);
  }  catch (e) {
    logger.d(e.toString(),error: "Error");
  }
}
