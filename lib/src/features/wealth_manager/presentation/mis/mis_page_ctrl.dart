import 'package:private_deals/src/shared/app_exports.dart';

class MISPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<WMisModel> list = <WMisModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await MisApi.wMisList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list(res.r);
      logger.d("misList Length :${list.length}");

    } else {
      toast(res.m);
    }
  }
}
