import 'package:private_deals/src/shared/app_exports.dart';
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
          leading: BackButton(
            onPressed: onBackPressed,
          ),
        ),
        body: Obx(() {
          if (c.isLoading.isFalse) {
            if (c.news.isNotEmpty) {
              return GridView.builder(
                itemCount: c.news.length,
                controller: c.scrollController,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: context.isPhone ? 20 : 30,
                  crossAxisSpacing: context.isPhone ? 20 : 30,
                  mainAxisExtent: 425,
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: context.isPhone ? 20 : 60),
                itemBuilder: (context, index) {
                  var model = c.news[index];
                  return SizedBox(
                    width: 300,
                    height: 425,
                    child: Clickable(
                      onTap: () {
                        showNewsDetailBottomSheet(context, news: model);
                      },
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                      child: CustomCardWidget(
                        color: context.theme.scaffoldBackgroundColor,
                        radius: 14,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14)),
                              child: CacheImage(
                                url: model.image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  color: context
                                                      .theme.disabledColor,
                                                  size: 24),
                                              const SizedBox(width: 5),
                                              Text(
                                                model.createdAt
                                                    .dateWithMonthYear,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            model.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // Ensure text does not overflow
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Flexible(
                                            child: Text(
                                              model.description,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              // Ensure text does not overflow
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    context.theme.disabledColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        showNewsDetailBottomSheet(context,
                                            news: model);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Read More",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(Icons.arrow_forward_outlined,
                                              size: 24),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
