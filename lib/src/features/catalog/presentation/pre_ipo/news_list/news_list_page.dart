import 'package:private_deals/src/shared/app_exports.dart';

import '../../widgets/catalog_article_card.dart';

import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_detail_dialog.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_list_page_ctrl.dart';

class NewsListPage extends StatelessWidget {
  final NewsListPageCtrl c = Get.put(NewsListPageCtrl());

  NewsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          title: Text("News List"),
          leading: BackButton(onPressed: onBackPressed),
        ),
        body: Obx(() {
          if (c.isLoading.isFalse) {
            if (c.news.isNotEmpty) {
              return CatalogArticleGrid(
                itemCount: c.news.length,
                controller: c.scrollController,
                itemBuilder: (context, index) {
                  final news = c.news[index];
                  return CatalogArticleCard(
                    image: news.image,
                    title: news.title,
                    description: news.description,
                    date: news.createdAt,
                    onTap: () => showNewsDetailBottomSheet(context, news: news),
                  );
                },
              );
            } else {
              return const NoDataView(isRefreshButton: false);
            }
          } else {
            return Loader();
          }
        }),
      ),
    );
  }
}
