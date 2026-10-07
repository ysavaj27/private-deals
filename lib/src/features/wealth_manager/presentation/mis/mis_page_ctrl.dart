import 'package:private_deals/src/shared/app_exports.dart';

class MISPageCtrl extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final list = <WMisModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    if (isLoading()) return;
    isLoading(true);
    error('');
    try {
      final res = await MisApi.wMisList();
      if (isClosed) return;
      if (res.isSuccess) {
        list.assignAll(res.r ?? []);
      } else {
        error('Unable to load company reports. Please try again.');
      }
    } catch (_) {
      if (!isClosed) error('Unable to load company reports. Please try again.');
    } finally {
      if (!isClosed) isLoading(false);
    }
  }
}
