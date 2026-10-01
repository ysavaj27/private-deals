import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final PrefConfig prefs = PrefConfig.instance;

class PrefConfig extends GetxService {
  static final PrefConfig instance = PrefConfig();

  final GetStorage storage = GetStorage();

  dynamic getValue({required String key}) async {
    return await storage.read(key);
  }

  Future<void> setValue({required String key, dynamic value}) async {
    await storage.write(key, value);
  }

  Future<void> removeValue({required String key}) async {
    await storage.remove(key);
  }
}
