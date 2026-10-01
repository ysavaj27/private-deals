import 'package:flutter/rendering.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class PrimaryLandingPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<BlogModel> blogs = <BlogModel>[].obs;
  Rx<LandingEnum> currentPage = LandingEnum.home.obs;
  ScrollController scrollController = ScrollController();
  final liveDeal = GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Rx<LandingPageModel> model = LandingPageModel.fromJson({}).obs;
  RxBool isHeaderVisible = true.obs;
  RxBool atTop = true.obs;
  PageController controller = PageController();
  RxList<SectorModel> sectors = <SectorModel>[].obs;
  ScrollController liveDealController = ScrollController();
  ScrollController completedDealController = ScrollController();
  ScrollController blogController = ScrollController();

  @override
  void onReady() {
    scrollLinear();
    super.onReady();
  }

  void scrollLinear() {
    scrollController.addListener(() {
      // logger.d("Direction :${scrollController.position.userScrollDirection}");
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        isHeaderVisible(false);
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        isHeaderVisible(true);
      }
      if (scrollController.position.pixels == 0) {
        atTop(true);
      } else {
        atTop(false);
      }
      // logger.d(
      //     "Position :${scrollController.position.pixels} Value :${atTop.value}");
    });
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await LandingPageApi.wHomePage();
    isLoading(false);
    if (res.isSuccess) {
      model(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> blogList() async {
    var res = await LandingPageApi.blogList();
    if (res.isSuccess) {
      blogs(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> sectorList() async {
    var res = await MasterApi.sectorList();
    if (res.isSuccess) {
      sectors(res.r);
    } else {
      toast(res.m);
    }
  }

  @override
  void onInit() {
    getData();
    blogList();
    sectorList();
    super.onInit();
  }
}
