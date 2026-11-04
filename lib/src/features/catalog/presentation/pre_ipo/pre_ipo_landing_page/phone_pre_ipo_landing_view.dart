import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_detail_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import '../../widgets/catalog_article_card.dart';
import '../../widgets/catalog_section_style.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/pre_ipo_landing_page_ctrl.dart';

class PhonePreIPOLandingView extends StatelessWidget {
  final PreIPOLandingPageCtrl c = Get.find<PreIPOLandingPageCtrl>();

  PhonePreIPOLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SearchBarTextField(
                readOnly: true,
                radius: AppRadii.control,
                hintText: "Search Company's",
                onTap: () {
                  var routes = Routes.preIPOListPath(
                    Get.currentRoute,
                    "search",
                  );
                  logger.d(routes);
                  Get.toNamed(routes);
                },
              ),
            ),
            SizedBox(height: 20),
            // Tab chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 44,
                child: Obx(() {
                  return CustomTabBar<UnListedShareTabEnum>(
                    items: PreIPOLandingPageCtrl.tabs,
                    labelBuilder: (tab) => tab.label,
                    selected: c.tab.value,
                    onSelected: c.changeTab,
                    isHighlighted: (tab) =>
                        tab == UnListedShareTabEnum.hotDeals,
                    highlightedIcon: Icons.local_fire_department_rounded,
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Card list — swaps automatically when tab changes
            Obx(() {
              final companies = c.currentCompanies;

              if (companies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: NoDataView(
                    title: 'No companies to show here.',
                    isRefreshButton: false,
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final company in companies)
                    CustomCompanyCard(
                      company: company,
                      // logo: CacheImage(url: company.logo),
                      // companyName: company.brandName,
                      // changePercent: company.percentageChange,
                      // sector: company.category,
                      // badgeText: company.headingText,
                      onTap: () {
                        var route = Routes.preIPODetailPath(
                          Routes.catalogPath(WTabBarEnum.preIPO.slug),
                          company.slug,
                        );
                        logger.d(route);
                        Get.toNamed(route);
                      },
                    ),
                  // CustomCompanyCard(
                  //   company,
                  //   onTap: () {
                  //     var route = Routes.preIPODetailPath(
                  //         "/wealth-manager/${WTabBarEnum.preIPO.slug}", company.slug);
                  //     logger.d(route);
                  //     Get.toNamed(route);
                  //   },
                  // ),
                ],
              );
            }),
            const SizedBox(height: 20),
            CustomOutlinedButton(
              borderRadius: AppRadii.button,
              color: context.theme.primaryColor,
              text: "Explore More",
              width: 150,
              onPressed: () {
                var routes = Routes.preIPOListPath(
                  Get.currentRoute,
                  c.tab.value.route,
                );
                logger.d(routes);
                Get.toNamed(routes);
              },
            ),
            const SizedBox(height: 20),
            FeaturedWidget(),
            const SizedBox(height: 20),
            Obx(() {
              return PhoneNewsWidget(
                list: c.newsSector().news,
                onPress: () {
                  Get.toNamed(Routes.newsListPath(Get.currentRoute));
                },
              );
            }),
            const SizedBox(height: 20),

            // --- rest of your page content goes below this line ---
          ],
        ),
      ),
    );
  }
}

class PhoneNewsWidget extends StatelessWidget {
  final List<NewsModel> list;
  final void Function()? onPress;

  // final PreIPOLandingPageCtrl c = Get.find<PreIPOLandingPageCtrl>();

  const PhoneNewsWidget({super.key, required this.list, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CatalogSectionHeading(title: 'News'),
        const SizedBox(height: 20),
        CatalogArticleCarousel(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final news = list[index];
            return CatalogArticleCard(
              image: news.image,
              title: news.title,
              description: news.description,
              date: news.createdAt,
              onTap: () => showNewsDetailBottomSheet(context, news: news),
            );
          },
        ),
        const SizedBox(height: 20),
        CatalogExploreButton(onPressed: onPress),
      ],
    );
  }
}
