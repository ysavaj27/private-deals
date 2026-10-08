import 'dart:async';

import 'package:private_deals/src/shared/app_exports.dart';

class PrimaryListPageCtrl extends GetxController {
  final PageController pageController = PageController();
  Timer? timer;
  int currentPage = 0;
  RxBool isLoading = false.obs;
  RxList<StartupRoundModel> list = <StartupRoundModel>[].obs;

  // final List<String> images = [
  //   'assets/image1.png',
  //   'assets/image2.png',
  //   'assets/image3.png',
  //   'assets/image4.png',
  // ];

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    // if (Get.arguments is List) {
    //   list.value = Get.arguments ?? [];
    //   _startAutoScroll();
    // } else if (Get.arguments is int) {
    var slug = Get.parameters['slug'] ?? "";
    isLoading(true);
    var res = await LandingPageApi.wNewStartupList(slug: slug);
    if (isClosed) return;
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      _startAutoScroll();
    }
    // }
  }

  void _startAutoScroll() {
    timer?.cancel();
    if (isClosed || list.isEmpty) return;
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentPage < list.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      if (list.length > 1 && pageController.hasClients) {
        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void onClose() {
    timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
