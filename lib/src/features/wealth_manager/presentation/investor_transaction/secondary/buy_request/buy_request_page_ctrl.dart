import 'package:private_deals/src/shared/app_exports.dart';

class BuyRequestPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<SecondaryOpportunitiesModel> list =
      <SecondaryOpportunitiesModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await WSecondaryTransactionApi.opportunitiesList();
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      isLoading(false);
    } else {
      toast(res.m);
    }
  }

  Future<void> updateStatus({required int id, required String status}) async {
    var res = await WSecondaryTransactionApi.opportunitiesStatus(
        itemId: id, status: 1);
    if (res.isSuccess) {
      getData();
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
