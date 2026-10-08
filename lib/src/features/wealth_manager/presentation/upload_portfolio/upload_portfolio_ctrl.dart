import 'package:private_deals/src/shared/app_exports.dart';

class UploadPortfolioCtrl extends GetxController {
  Rx<DashboardTypeEnum> currentIndex = DashboardTypeEnum.primary.obs;
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
  GlobalKey<FormState> desktopKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneCompanyKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneStartupKey = GlobalKey<FormState>();

  bool get isStartUp => currentIndex() == DashboardTypeEnum.primary;

  List<CompanyStartup> get list {
    if (currentIndex() == DashboardTypeEnum.primary) {
      return model().startup;
    } else {
      return model().company;
    }
  }

  void changeTab(DashboardTypeEnum type) {
    currentIndex(type);
    clearData();
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
    isUploading(true);
    var res = await PortfolioApi.wAddPortfolioApi(
      type: currentIndex(),
      investorId: selectedInvestor().id,
      companyId: selectedCompany().id,
      otherName: companyCTRL.text,
      shares: int.parse(qtyCTRL.text),
      sharePrice: double.parse(sharePriceCTRL.text),
      date: purchaseDateCTRL.text,
    );
    isUploading(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success, Duration(milliseconds: 3500));
      clearData();
    } else {
      toast(res.m, MessageEnum.error);
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
    if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) {
      currentIndex(DashboardTypeEnum.primary);
    } else {
      currentIndex(DashboardTypeEnum.preIpo);
    }
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
