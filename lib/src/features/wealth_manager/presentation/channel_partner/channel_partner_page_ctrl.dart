import 'package:private_deals/src/shared/app_exports.dart';

class ChannelPartnerPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PartnerUser> list = <PartnerUser>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await ChannelPartnerApi.channelPartnerList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list(res.r);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
