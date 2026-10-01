import 'package:private_deals/src/shared/app_exports.dart';

class MyEarningPageCtrl extends GetxController {
  Rx<MyEarningTypeEnum> currentIndex = MyEarningTypeEnum.investor.obs;

  RxBool isLoading = false.obs;
  Rx<InvestorEarningModel> investor = InvestorEarningModel.fromJson({}).obs;
  Rx<PartnerEarningModel> partner = PartnerEarningModel.fromJson({}).obs;

  @override
  void onInit() {
    investorData();
    super.onInit();
  }

  Future<void> investorData() async {
    isLoading(true);
    var res = await MyEarningApi.wInvestorEarningList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investor(res.r);
      // logger.d(
      //     "Investor Earning List Length :${investor().investorsList.length}");
    } else {
      toast(res.m);
    }
  }

  Future<void> channelPartnerData() async {
    isLoading(true);
    var res = await MyEarningApi.wPartnerEarningList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      partner(res.r);
      logger.d("Partner Earning List Length :${partner().list.length}");
    } else {
      toast(res.m);
    }
  }
}
