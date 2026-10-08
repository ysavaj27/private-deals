import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/investors/presentation/investor_kyc_dialog.dart';

class InvestorsPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxList<PartnerUser> relationManagerList = <PartnerUser>[].obs;
  RxList<PartnerUser> selectedRelationMangerList = <PartnerUser>[].obs;
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;

  RxList<InvestorModel> searchList = <InvestorModel>[].obs;
  TextEditingController controller = TextEditingController();
  String _query = '';

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
    _query = query;
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      searchList.value = investorList;
      isSearching(false);
    } else {
      searchList.value = investorList.where((item) {
        return '${item.name} ${item.email} ${item.mobileNumber} ${item.investorType}'
            .toLowerCase()
            .contains(q);
      }).toList();
      isSearching(true);
    }
  }

  Future<void> openKyc(BuildContext context, InvestorModel investor) async {
    if (investor.isPreIpoKycComplete) return;
    final saved = await showInvestorKycDialog(context, investor);
    if (saved == true) {
      await getInvestorList();
      toast('KYC details saved successfully.', MessageEnum.success);
    }
  }

  Future<void> getInvestorList() async {
    isLoading(true);
    var res = await WInvestorsApi.investorsList(
      // The legacy is_kyc filter may refer to kyc_status, not Pre-IPO KYC.
      isKyc: 'All',
      isActive: activeInvestor().name,
      isAif: aif().name,
      relationManagerList: selectedRelationMangerList,
    );
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investorList(
        res.r!.where((investor) {
          return pendingKYC() == FilterTypeEnum.All ||
              investor.isPreIpoKycComplete ==
                  (pendingKYC() == FilterTypeEnum.Yes);
        }).toList(),
      );
      search(_query);
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

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
