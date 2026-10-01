import 'package:private_deals/src/shared/app_exports.dart';

class InvestorsPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxList<PartnerUser> relationManagerList = <PartnerUser>[].obs;
  RxList<PartnerUser> selectedRelationMangerList = <PartnerUser>[].obs;
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;

  RxList<InvestorModel> searchList = <InvestorModel>[].obs;
  TextEditingController controller = TextEditingController();

  /// FILTER
  Rx<FilterTypeEnum> pendingKYC = FilterTypeEnum.All.obs;
  Rx<FilterTypeEnum> activeInvestor = FilterTypeEnum.All.obs;
  Rx<FilterTypeEnum> aif = FilterTypeEnum.All.obs;

  @override
  void onInit() {
    getInvestorList();
    getRelationManagerList();
    clearFilter();
    super.onInit();
  }

  void clearFilter() {
    pendingKYC(FilterTypeEnum.All);
    activeInvestor(FilterTypeEnum.All);
  }

  List<InvestorModel> get finalList {
    if (isSearching.isFalse) {
      return investorList;
    } else {
      return searchList;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      searchList.value = investorList;
      isSearching(false);
    } else {
      searchList.value = investorList.where((item) {
        // logger.d("Search :$query Amount :${item.amount}");
        return /*item.amount.toString().contains(query) ||*/ item.name
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
      isSearching(true);
    }
  }

  Future<void> getInvestorList() async {
    isLoading(true);
    var res = await WInvestorsApi.investorsList(
      isKyc: pendingKYC().name,
      isActive: activeInvestor().name,
      isAif: aif().name,
      relationManagerList: selectedRelationMangerList,
    );
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investorList(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getRelationManagerList() async {
    var res = await ChannelPartnerApi.relationManagerGet();
    if (res.isSuccess && res.r != null) {
      relationManagerList(res.r);
    } else {
      toast(res.m);
    }
  }
}
