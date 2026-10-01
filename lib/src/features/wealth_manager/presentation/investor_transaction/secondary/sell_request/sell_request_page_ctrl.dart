import 'package:private_deals/src/shared/app_exports.dart';

class SellRequestPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<SellRequestModel> list = <SellRequestModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await WSecondaryTransactionApi.sellRequestList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      logger.d("sell RequestList Length :${list.length}");
    } else {
      toast(res.m);
    }
  }
}
