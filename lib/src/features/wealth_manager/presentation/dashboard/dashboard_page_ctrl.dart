import 'dart:math';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/phone_dashboard_view.dart';

class DashboardPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isData = false.obs;
  RxList<StartupRoundModel> startupList = <StartupRoundModel>[].obs;
  Rx<DashboardTypeEnum> currentIndex = DashboardTypeEnum.preIpo.obs;
  Rx<WDashboardModel> model = WDashboardModel.fromJson({}).obs;
  WDashboardModel primaryModel = WDashboardModel.fromJson({});
  WDashboardModel preIpoModel = WDashboardModel.fromJson({});
  RxDouble maxSize = 0.0.obs;
  RxList<List<dynamic>> barList = <List<dynamic>>[].obs;
  RxList<DataModel> columnList = <DataModel>[].obs;

  bool get isPrimary => currentIndex() == DashboardTypeEnum.primary;
  List<DataModel<List<WStartup>>> numberPieChartList =
      <DataModel<List<WStartup>>>[];
  List<DataModel<List<WStartup>>> investmentPieChartList =
      <DataModel<List<WStartup>>>[];
  List<DataModel<List<Active>>> kycInvestorList = <DataModel<List<Active>>>[];
  List<DataModel<List<Active>>> activeInvestorList =
      <DataModel<List<Active>>>[];
  RxList<DataModel> monthlyList = <DataModel>[].obs;
  RxList<DataModel> quarterlyList = <DataModel>[].obs;
  final ScrollController scrollController = ScrollController();
  RxBool isMonthly = false.obs;
  RxBool isInvestment = false.obs;
  RxBool isActive = false.obs;
  PageController trendingPageController = PageController();
  PageController chartPageController = PageController();

  @override
  void onInit() {
    getAllData();
    super.onInit();
  }

  Future<void> getAllData() async {
    await Future.wait([primaryGetData(), preIpoGetData(), getStartupList()]);
    if (app.wUser.isPreIpoAccess) {
      changeTab(DashboardTypeEnum.preIpo);
    } else if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess) {
      changeTab(DashboardTypeEnum.primary);
    }
  }

  Future<void> getData() async {
    if (currentIndex() == DashboardTypeEnum.primary) {
      await primaryGetData();
      await getStartupList();
    } else {
      await preIpoGetData();
    }
  }

  List<Widget> charts() {
    List<Widget> list = [];
    list.addIf(investmentPieChartList.isNotEmpty, MobilePieChartWidget());
    list.addIf(activeInvestorList.isNotEmpty, InvestorPieChartWidget());
    // list.addIf(
    //     quarterlyList.isNotEmpty || monthlyList.isNotEmpty, MobileLineChart());
    list.addIf(columnList().isNotEmpty, ColumnChartWidget());
    return list;
  }

  void centerItem() {
    final screenWidth = Get.width;
    final offset = 160 * 2 - (screenWidth - 160) / 2;
    scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> primaryGetData() async {
    isLoading(true);
    var res = await DashboardApi.wealthManagerDashboard();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      primaryModel = res.r!;
      if (currentIndex() == DashboardTypeEnum.primary) {
        changeTab(DashboardTypeEnum.primary);
      }
    } else {
      toast(res.m);
    }
  }

  Future<void> preIpoGetData() async {
    isLoading(true);
    var res = await DashboardApi.wealthManagerPreIPODashboard();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      preIpoModel = res.r!;
      if (currentIndex() == DashboardTypeEnum.preIpo) {
        changeTab(DashboardTypeEnum.preIpo);
      }
    } else {
      toast(res.m);
    }
  }

  void changeTab(DashboardTypeEnum type) {
    currentIndex(type);
    switch (type) {
      case DashboardTypeEnum.primary:
        model(primaryModel);
        setData();
        model.refresh();
        break;
      case DashboardTypeEnum.preIpo:
        model(preIpoModel);
        setData();
        model.refresh();
        break;
    }
  }

  Future<void> getStartupList() async {
    isLoading(true);
    var res = await LandingPageApi.wStartupList(
      type: StartupStatusEnum.raisingnow,
    );
    isLoading(false);
    if (res.isSuccess) {
      startupList(res.r);
    } else {
      toast(res.m);
    }
  }

  void clearData() {
    isData(false);
    maxSize(0.0);
    barList.clear();
    kycInvestorList.clear();
    activeInvestorList.clear();
    columnList.clear();
    numberPieChartList.clear();
    investmentPieChartList.clear();
    monthlyList.clear();
    monthlyList.clear();
    quarterlyList.clear();
    isMonthly(false);
    isInvestment(false);
  }

  Future<void> setData() async {
    clearData();

    /// SET ACTIVE & NON ACTIVE  AND KYC AND NON KYC INVESTOR
    var activeInvestor = model().investorChartModel.active
        .where((e) => e.kycStatus.isNotEmpty)
        .toList();
    var unActiveInvestor = model().investorChartModel.active
        .where((e) => e.kycStatus.isEmpty)
        .toList();
    activeInvestorList.add(
      DataModel(
        index: activeInvestor.length,
        info: activeInvestor,
        title: "Active",
      ),
    );
    activeInvestorList.add(
      DataModel(
        index: unActiveInvestor.length,
        info: unActiveInvestor,
        title: "In Active",
      ),
    );

    var kycCompleteInvestorList = model().investorChartModel.kyc
        .where((e) => e.kycStatus == 1)
        .toList();
    var noKycInvestorList = model().investorChartModel.kyc
        .where((e) => e.kycStatus == 0)
        .toList();
    kycInvestorList.add(
      DataModel(
        index: kycCompleteInvestorList.length,
        info: kycCompleteInvestorList,
        title: "Kyc",
      ),
    );
    kycInvestorList.add(
      DataModel(
        index: noKycInvestorList.length,
        info: noKycInvestorList,
        title: "Non Kyc",
      ),
    );

    ///NEW BAR CHARTS DATA
    for (var i = 0; i < model().investmentGrowth.length; i++) {
      var data = model().investmentGrowth[i];
      final shadeSet = AppColors.darKList[i % AppColors.darKList.length];
      columnList.add(
        DataModel(
          title: data.startupName,
          image: data.logo,
          numData: data.totalInvestedAmount.toDouble(),
          numData2: data.currentValue.toDouble(),
          darkColors: shadeSet,
          lightColors: shadeSet,
        ),
      );
    }

    /// PIE CHART DATA ADD INTO MODEL
    for (var i = 0; i < model().sectors.length; i++) {
      var data = model().sectors[i];
      var dataModel = DataModel<List<WStartup>>(
        title: data.name,
        numData: data.startups.length.toDouble(),
        numData2: data.totalInvestment.toDouble(),
        index: i,
        info: data.startups,
      );
      numberPieChartList.add(dataModel);
      investmentPieChartList.add(dataModel);
    }

    double stepSize = (90 - 60) / (model().sectors.length);

    /// UPDATE RADIUS OF NUMBER PIE CHART
    numberPieChartList.sort((a, b) => a.numData.compareTo(b.numData));

    for (var i = 0; i < numberPieChartList.length; i++) {
      var data = numberPieChartList[i];
      double radius = 60 + (i * stepSize);
      numberPieChartList[i] = DataModel(
        title: data.title,
        numData: data.numData,
        numData2: data.numData2,
        index: data.index,
        id: data.id,
        data: '${radius.floor()}%',
        info: data.info,
      );
    }

    /// UPDATE RADIUS OF INVESTMENT PIE CHART
    investmentPieChartList.sort((a, b) => a.numData2.compareTo(b.numData2));

    for (var i = 0; i < investmentPieChartList.length; i++) {
      var data = investmentPieChartList[i];
      double radius = 60 + (i * stepSize);
      investmentPieChartList[i] = DataModel(
        title: data.title,
        numData: data.numData,
        numData2: data.numData2,
        id: data.id,
        index: data.index,
        data: '${radius.floor()}%',
        info: data.info,
      );
    }

    /// LINE CHART DATA
    for (var i = 0; i < model().investments.monthly.length; i++) {
      var chart = model().investments.monthly[i];
      monthlyList.add(
        DataModel(
          title: chart.month,
          numData: chart.totalInvestment.toDouble(),
          index: i,
        ),
      );
    }
    for (var i = 0; i < model().investments.quarterly.length; i++) {
      var chart = model().investments.quarterly[i];
      quarterlyList.add(
        DataModel(
          title: chart.quarter,
          numData: chart.totalInvestment.toDouble(),
          index: i,
        ),
      );
    }

    isData(true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    trendingPageController.dispose();
    chartPageController.dispose();
    super.onClose();
  }
}

class DataModel<T> {
  String title;
  String data;
  String image;
  double numData;
  double numData2;
  int index;
  int id;
  List<Color> darkColors;
  List<Color> lightColors;
  T? info;

  bool isBig(double va) {
    int largest = max(numData.toInt(), numData2.toInt());
    if (largest == va.toInt()) {
      return true;
    } else {
      return false;
    }
  }

  DataModel({
    this.title = '',
    this.data = '',
    this.image = '',
    this.numData = 0.0,
    this.numData2 = 0.0,
    this.index = 0,
    this.id = 0,
    this.darkColors = const [],
    this.lightColors = const [],
    this.info,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'data': data,
    'image': image,
    'numData': numData,
    'index': index,
  };
}
