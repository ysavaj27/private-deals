import 'dart:async';

import 'package:private_deals/src/shared/app_exports.dart';

class PreIPOListPageCtrl extends GetxController {
  Timer? debounce;
  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;
  RxList<CompanyModel> list = <CompanyModel>[].obs;
  final ScrollController scrollController = ScrollController();
  Rx<UnListedShareTabEnum> types = UnListedShareTabEnum.trending.obs;
  final searchFocusNode = FocusNode();
  bool isSecondary = false;

  Future<void> getData({required int count, String query = ''}) async {
    final slug = Get.parameters['type'] ?? '';
    final isSearch = slug == 'search';
    if (!isSecondary && slug == UnListedShareTabEnum.hotDeals.route) {
      if (count > 0) return;
      isLoading(true);
      final response = await PreIpoLandingPageApi.wPreIPOHome();
      if (response.isSuccess) {
        final search = query.trim().toLowerCase();
        list.assignAll(
          response.r!.hotDeals.where(
            (company) =>
                company.brandName.toLowerCase().contains(search) ||
                company.companyName.toLowerCase().contains(search),
          ),
        );
      } else {
        toast(response.m, MessageEnum.error);
      }
      isLoading(false);
      return;
    }

    if (isSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) searchFocusNode.requestFocus();
      });
    }
    if (count.isEmpty) {
      isLoading(true);
    }
    var res = await PreIpoLandingPageApi.wCompanyList(
      count: count,
      search: query,
      data: isSearch ? '' : slug,
      isSecondary: isSecondary,
    );
    if (res.isSuccess) {
      if (count.isEmpty) {
        list(res.r);
      } else {
        list.addAll(res.r!);
      }
    } else {
      toast(res.m, MessageEnum.error);
    }
    isLoading(false);
  }

  void search(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      await getData(query: query, count: 0);
    });
  }

  void _scrollListener() {
    if (!scrollController.hasClients) return;

    // Remaining scrollable content in pixels
    final extentAfter = scrollController.position.extentAfter;

    if (extentAfter < 300 && isLoading.isFalse && isLoadMore.isFalse) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (isLoading.isTrue || isLoadMore.isTrue) return;
    if (!isSecondary &&
        Get.parameters['type'] == UnListedShareTabEnum.hotDeals.route)
      return;

    isLoadMore(true);

    try {
      await getData(count: list.length);
    } finally {
      isLoadMore(false);
    }
  }

  @override
  void onInit() {
    isSecondary = Get.currentRoute.contains(WTabBarEnum.secondary.slug);
    getData(count: 0);
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    debounce?.cancel();

    searchFocusNode.dispose();
    super.onClose();
  }
}
