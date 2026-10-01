import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_detail_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

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
                radius: 16,
                hintText: "Search Company's",
                onTap: () {
                  var routes =
                      Routes.preIPOListPath(Get.currentRoute, "search");
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
                    // read inside Obx by the caller, see below
                    onSelected: c.changeTab,
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Card list — swaps automatically when tab changes
            Obx(() {
              final companies = c.currentCompanies;

              if (companies.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    'No companies to show here.',
                    style: TextStyle(
                        color: context.theme.iconTheme.color
                            ?.withValues(alpha: 0.6)),
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
                            "/wealth-manager/${WTabBarEnum.preIPO.slug}", company.slug);
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
              borderRadius: 22,
              color: context.theme.primaryColor,
              text: "Explore More",
              width: 150,
              onPressed: () {
                var routes =
                    Routes.preIPOListPath(Get.currentRoute, c.tab.value.route);
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
        Center(
          child: Text(
            'News',
            style: TextStyle(
                fontSize: context.isPhone ? 22 : 36,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 167,
          child: ListView.separated(
            clipBehavior: Clip.none,
            itemCount: list.length,
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              var model = list[index];
              return SizedBox(
                width: 180,
                child: Clickable(
                  onTap: () {
                    showNewsDetailBottomSheet(context, news: model);
                  },
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  child: CustomCardWidget(
                    color: context.theme.scaffoldBackgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    radius: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 90,
                          width: context.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                            child: CacheImage(
                              url: model.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          model.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            model.description,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 10,
                              color: Color.fromRGBO(
                                124,
                                124,
                                124,
                                1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        CustomOutlinedButton(
          borderRadius: 22,
          color: context.theme.primaryColor,
          text: "Explore More",
          width: 150,
          // height: 56,
          onPressed: onPress,
        ),
      ],
    );
  }
}
