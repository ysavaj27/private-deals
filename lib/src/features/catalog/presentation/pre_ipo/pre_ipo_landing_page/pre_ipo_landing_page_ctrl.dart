import 'package:private_deals/src/shared/app_exports.dart';

class PreIPOLandingPageCtrl extends GetxController {
  static const tabs = [
    UnListedShareTabEnum.liquidStocks,
    UnListedShareTabEnum.exclusiveDeals,
    UnListedShareTabEnum.drhpFiled,
    UnListedShareTabEnum.hotDeals,
    UnListedShareTabEnum.aToZ,
  ];

  RxBool isLoading = false.obs;
  Rx<PreIPOLandingPageModel> model = PreIPOLandingPageModel.fromJson({}).obs;
  Rx<PreIPONewsSectorModel> newsSector = PreIPONewsSectorModel.fromJson({}).obs;
  Rx<UnListedShareTabEnum> tab = UnListedShareTabEnum.liquidStocks.obs;

  Future<void> getLandingData() async {
    var res = await PreIpoLandingPageApi.wPreIPOHome();
    if (res.isSuccess) {
      model(res.r!);
    }
  }

  Future<void> getNewsSectors() async {
    var res = await PreIpoLandingPageApi.newsSectors();
    if (res.isSuccess) {
      newsSector(res.r!);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    await Future.wait([getNewsSectors(), getLandingData()]);
    isLoading(false);
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  void changeTab(UnListedShareTabEnum t) => tab.value = t;

  List<CompanyModel> get currentCompanies {
    final tabModel = model.value;
    switch (tab.value) {
      case UnListedShareTabEnum.hotDeals:
        return tabModel.hotDeals;
      case UnListedShareTabEnum.trending:
        return tabModel.trending;
      case UnListedShareTabEnum.exclusiveDeals:
        return tabModel.exclusiveDeals;
      case UnListedShareTabEnum.liquidStocks:
        return tabModel.liquidStocks;
      case UnListedShareTabEnum.drhpFiled:
        return tabModel.drhp;
      case UnListedShareTabEnum.aToZ:
        return tabModel.all;
    }
  }
}
