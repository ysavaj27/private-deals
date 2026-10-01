import 'package:private_deals/src/shared/app_exports.dart';

class NewsListPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadMore = false.obs;
  RxList<NewsModel> news = <NewsModel>[].obs;
  ScrollController scrollController = ScrollController();

  Future<void> getData(int count) async {
    if (count.isEmpty) {
      isLoading(true);
    }
    var res = await PreIpoLandingPageApi.wNewsList(count: count);
    isLoading(false);
    if (res.isSuccess) {
      if (count.isEmpty) {
        news(res.r);
      } else {
        news.addAll(res.r!);
      }
    } else {
      toast(res.m, MessageEnum.error);
    }
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

    isLoadMore(true);

    try {
      await getData(news.length);
    } finally {
      isLoadMore(false);
    }
  }

  @override
  void onInit() {
    getData(0);
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();

    super.onClose();
  }
}
