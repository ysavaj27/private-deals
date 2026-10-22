import 'package:private_deals/src/shared/app_exports.dart';

/// Uses the API message when the server sends one. An empty success falls
/// back to when the holding becomes visible; an empty failure stays explicit.
String portfolioUploadMessage({
  required bool success,
  required String apiMessage,
  required bool knownCompany,
}) {
  final message = apiMessage.trim();
  if (message.isNotEmpty) return message;
  if (!success) return 'Unable to add this holding.';
  return knownCompany
      ? 'This holding is available in the portfolio.'
      : 'This holding may take up to 48 hours to appear in the portfolio.';
}

class UploadPortfolioCtrl extends GetxController {
  Rx<CompanyStartupModel> model = CompanyStartupModel().obs;
  Rx<CompanyStartup> selectedCompany = CompanyStartup.fromJson({}).obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  TextEditingController investorCTRL = TextEditingController();
  TextEditingController companyCTRL = TextEditingController();
  TextEditingController sharePriceCTRL = TextEditingController();
  TextEditingController qtyCTRL = TextEditingController();
  TextEditingController purchaseDateCTRL = TextEditingController();
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;
  Rx<InvestorModel> selectedInvestor = InvestorModel.fromJson({}).obs;

  List<CompanyStartup> get list => model().company;

  bool get isCustomCompany {
    final name = companyCTRL.text.trim().toLowerCase();
    if (name.isEmpty) return false;
    return !list.any(
      (company) => company.brandName.trim().toLowerCase() == name,
    );
  }

  void clearData() {
    if (isClosed) return;
    sharePriceCTRL.clear();
    qtyCTRL.clear();
    purchaseDateCTRL.clear();
    companyCTRL.clear();
    investorCTRL.clear();
    selectedCompany(CompanyStartup.fromJson({}));
    selectedInvestor(InvestorModel.fromJson({}));
  }

  Future<void> getCompanyStartupList() async {
    var res = await PortfolioApi.getCompanyStartupApi();
    if (res.isSuccess) {
      model(res.r);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> addData() async {
    if (isUploading()) return;
    isUploading(true);
    final knownCompany = selectedCompany().id > 0;
    final res = await PortfolioApi.wAddPortfolioApi(
      investorId: selectedInvestor().id,
      companyId: knownCompany ? selectedCompany().id : null,
      otherName: companyCTRL.text,
      shares: int.tryParse(qtyCTRL.text) ?? 0,
      sharePrice: double.tryParse(sharePriceCTRL.text) ?? 0,
      date: purchaseDateCTRL.text,
    );
    if (!isClosed) isUploading(false);
    if (isClosed) return;
    final message = portfolioUploadMessage(
      success: res.isSuccess,
      apiMessage: res.m,
      knownCompany: knownCompany,
    );
    if (res.isSuccess) {
      toast(message, MessageEnum.success, const Duration(milliseconds: 3500));
      clearData();
    } else {
      toast(message, MessageEnum.error);
    }
  }

  Future<void> getInvestorList() async {
    var res = await WInvestorsApi.investorsList(
      isKyc: FilterTypeEnum.All.name,
      isActive: FilterTypeEnum.All.name,
      isAif: FilterTypeEnum.All.name,
      relationManagerList: [],
    );
    if (res.isSuccess && res.r != null) {
      investorList(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    await Future.wait([getCompanyStartupList(), getInvestorList()]);
    isLoading(false);
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    investorCTRL.dispose();
    companyCTRL.dispose();
    sharePriceCTRL.dispose();
    qtyCTRL.dispose();
    purchaseDateCTRL.dispose();
    super.onClose();
  }
}
