import 'package:private_deals/src/shared/app_exports.dart';

class ChannelPartnerPageCtrl extends GetxController {
  final error = ''.obs;
  RxBool isLoading = false.obs;
  RxList<PartnerUser> list = <PartnerUser>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    if (isLoading()) return;
    isLoading(true);
    error('');
    var res = await ChannelPartnerApi.channelPartnerList();
    if (isClosed) return;
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list(res.r);
    } else {
      error(res.m.isEmpty ? 'Please try again to load your partners.' : res.m);
    }
  }
}
