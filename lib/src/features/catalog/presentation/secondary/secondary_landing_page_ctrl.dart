import 'package:private_deals/src/shared/app_exports.dart';

class SecondaryLandingPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  Rx<SecondaryLandingPageModel> model =
      SecondaryLandingPageModel.fromJson({}).obs;
  RxList<SectorModel> sectorList = <SectorModel>[].obs;
  Rx<int> currentSector = 0.obs;

  Future<void> getData() async {
    isLoading(true);
    var res = await PreIpoLandingPageApi.wSecondaryHome();
    isLoading(false);
    if (res.isSuccess) {
      model(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getSector() async {
    var res = await MasterApi.sectorList();
    if (res.isSuccess) {
      sectorList(res.r);
    } else {
      toast(res.m);
    }
  }

  // List<StartupRoundModel> get finalList {
  //   if (isSearching.isFalse) {
  //     return list;
  //   } else {
  //     return searchList;
  //   }
  // }

  // void search(String query) {
  //   if (query.isEmpty) {
  //     searchList.value = list;
  //     isSearching(false);
  //   } else {
  //     searchList.value = list.where((item) {
  //       // logger.d("Search :$query Amount :${item.amount}");
  //       return item.startup.brandName
  //               .toLowerCase()
  //               .contains(query.toLowerCase()) ||
  //           item.startup.indicativeValuation
  //               .toString()
  //               .contains(query.toLowerCase());
  //     }).toList();
  //     isSearching(true);
  //   }
  // }

  // void searchBySector() {
  //   if (currentSector().isEmpty) {
  //     searchList.value = list;
  //     isSearching(false);
  //   } else {
  //     searchList.value = list.where((item) {
  //       logger.d(
  //           "Sector :${item.startup.sector.name} Id :${item.startup.sector.id} Current Id :${currentSector()}");
  //       return item.startup.sector.id == currentSector();
  //     }).toList();
  //
  //     isSearching(true);
  //   }
  // }

  @override
  void onInit() {
    getData();
    getSector();
    super.onInit();
  }
}
