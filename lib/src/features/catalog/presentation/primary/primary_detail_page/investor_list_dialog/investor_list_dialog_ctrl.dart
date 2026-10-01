import 'package:private_deals/src/shared/app_exports.dart';

class InvestorListDialogCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;

  Future<void> getData() async {
    isLoading(true);
    var res = await WInvestorsApi.investorsList(
      isKyc: FilterTypeEnum.All.name,
      isActive: FilterTypeEnum.All.name,
      isAif: FilterTypeEnum.All.name,
    );
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investorList(res.r);
    } else {
      toast(res.m);
    }
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
