import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/phone_pre_ipo_landing_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart'
    show CustomCompanyCard;
import 'package:private_deals/src/features/catalog/presentation/secondary/desktop_secondary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page_ctrl.dart';

class PhoneSecondaryLandingView extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.find<SecondaryLandingPageCtrl>();

  PhoneSecondaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.isFalse) {
            return SingleChildScrollView(
              physics: const CustomScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: context.theme.scaffoldBackgroundColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    child: SearchBarTextField(
                      radius: 6,
                      readOnly: true,
                      hintText: "Search Company's",
                      onTap: () {
                        var routes =
                            Routes.preIPOListPath(Get.currentRoute, 'search');
                        logger.d(routes);
                        Get.toNamed(routes);
                      },
                      // onChanged: (p0) => c.search(p0),
                    ),
                  ),

                  // Card list — swaps automatically when tab changes
                  Obx(() {
                    final companies = c.model().all;
                    if (companies.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: NoDataView(
                          title: 'No companies here',
                          subtitle: 'Try searching or refresh.',
                          isRefreshButton: false,
                        ),
                      );
                    }

                    return Align(
                      alignment: Alignment.topCenter,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runAlignment: WrapAlignment.center,
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
                                // var route = Routes.preIPODetailPath(
                                //     "/wealth-manager/${WTabBarEnum.preIPO.slug}", company.slug);
                                // logger.d(route);
                                // Get.toNamed(route);

                                logger.d(company.slug);
                                String routes = Routes.secondaryDetailPath(
                                    Get.currentRoute, company.slug);
                                logger.d(routes);
                                Get.toNamed(routes);
                              },
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                  Center(
                    child: CustomOutlinedButton(
                      borderRadius: 22,
                      color: context.theme.primaryColor,
                      text: "Explore More",
                      width: 150,
                      onPressed: () {
                        var routes = Routes.preIPOListPath(
                            Get.currentRoute, UnListedShareTabEnum.aToZ.route);
                        logger.d(routes);
                        Get.toNamed(routes);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  FeaturedWidget(),
                  const SizedBox(height: 20),
                  Obx(() {
                    return Visibility(
                      visible: c.model().news.isNotEmpty,
                      child: PhoneNewsWidget(
                        list: c.model().news,
                        onPress: () {},
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return Loader();
          }
        }),
      ),
    );
  }
}
