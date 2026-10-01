import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_filter_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_landing_page_ctrl.dart';

class DesktopSecondaryLandingView extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.find<SecondaryLandingPageCtrl>();

  DesktopSecondaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      body: Obx(() {
        if (c.isLoading.isFalse) {
          return SingleChildScrollView(
            physics: const CustomScrollPhysics(),
            child: Column(
              children: [
                Container(
                  color: context.theme.scaffoldBackgroundColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchBarTextField(
                          radius: 6,
                          readOnly: true,
                          hintText: "Search Company's",
                          onTap: () {
                            var routes = Routes.preIPOListPath(
                                Get.currentRoute, 'search');
                            Get.toNamed(routes);
                          },
                          // onChanged: (p0) => c.search(p0),
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          showCustomDialog(SecondaryFilterDialog());
                        },
                        child: const CustomCardWidget(
                          height: 55,
                          width: 55,
                          radius: 6,
                          child: Icon(Icons.filter_list_rounded),
                        ),
                      ),
                    ],
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

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
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
                  );
                }),

                const SizedBox(height: 20),
                Center(
                  child: CustomElevatedButton(
                    radius: 22,
                    text: "Explore More",
                    width: 236,
                    height: 56,
                    onPressed: () {
                      var routes = Routes.preIPOListPath(
                          Get.currentRoute, UnListedShareTabEnum.aToZ.route);
                      Get.toNamed(routes);
                    },
                  ),
                ),
                const SizedBox(height: 40),
                FeaturedWidget(),
                const SizedBox(height: 40),
                NewsWidget(),
              ],
            ),
          );
        } else {
          return Loader();
        }
      }),
    );
  }
}

class FeaturedWidget extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.find<SecondaryLandingPageCtrl>();

  FeaturedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: context.isPhone ? 22 : 36,
              fontWeight: FontWeight.w400,
            ),
            children: [
              TextSpan(
                text: 'Featured ',
                style: TextStyle(
                  decorationThickness: 2.5,
                  decorationColor:
                      context.theme.primaryColor.withValues(alpha: 0.7),
                ),
              ),
              TextSpan(
                text: 'Sectors',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: context.isPhone ? 20 : 40),
        Obx(() {
          return AutoScrollSectorList(
            sectors: c.model().sectors,
            isPhone: context.isPhone,
            onViewMore: (model) {
              var routes = Routes.preIPOListPath(Get.currentRoute, model.slug);
              logger.d(routes);
              Get.toNamed(routes);
            },
            onLogoTap: (model, company) {},
          );
        }),
      ],
    );
  }
}

class NewsWidget extends StatelessWidget {
  final SecondaryLandingPageCtrl c = Get.find<SecondaryLandingPageCtrl>();

  NewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (c.model().news.isNotEmpty) {
      return Column(
        children: [
          Center(
            child: Text(
              'News',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 60),
          SizedBox(
            height: 400,
            child: Obx(() {
              return ListView.separated(
                padding: EdgeInsets.only(
                    left: context.width * 0.0276, right: context.width * 0.1),
                itemCount: c.model().news.length,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  var model = c.model().news[index];
                  return SizedBox(
                    width: 300,
                    height: 425,
                    child: Clickable(
                      // splashColor: Colors.transparent,
                      // hoverColor: Colors.transparent,
                      // highlightColor: Colors.transparent,
                      // borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        // Get.toNamed(
                        // Routes.blogDetailPath(
                        //     Get.currentRoute, model.urlSlug),
                        // );
                      },
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
                                height: 200,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
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
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            model.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            // Ensure text does not overflow
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
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
                                        // Get.toNamed(Routes.blogDetailPath(
                                        //     Get.currentRoute,
                                        //     model.urlSlug));
                                        // Get.toNamed(Routes.blogDetailPage,
                                        //     arguments: model);
                                      },
                                      child: const Row(
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
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  width: 20,
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          CustomElevatedButton(
            radius: 22,
            text: "Explore More",
            width: 236,
            height: 56,
            onPressed: () {
              Get.toNamed(Routes.newsListPath(Get.currentRoute));
            },
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}

class ChartWidget extends StatelessWidget {
  final List<double> yValues;
  final double? height;
  final double? width;

  const ChartWidget({
    super.key,
    required this.yValues,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: width ?? 70,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(
          isVisible: false,
        ),
        primaryYAxis: const NumericAxis(
          isVisible: false,
        ),
        series: _getDefaultAreaSeries(context),
        tooltipBehavior: TooltipBehavior(enable: false),
      ),
    );
  }

  List<AreaSeries<int, int>> _getDefaultAreaSeries(BuildContext context) {
    return <AreaSeries<int, int>>[
      AreaSeries<int, int>(
        dataSource: List<int>.generate(yValues.length, (index) => index),
        // X-axis values (index)
        borderColor: Colors.orange,
        enableTooltip: true,
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            const Color(0xff5E3E1A),
            context.theme.scaffoldBackgroundColor,
          ],
        ),
        xValueMapper: (int index, _) => index,
        // X-axis uses index
        yValueMapper: (int index, _) =>
            yValues[index], // Y-axis from the passed list
      ),
    ];
  }
}

class ChartSampleData {
  DateTime date;
  double values;
  String text;

  ChartSampleData({
    required this.values,
    this.text = '',
    required this.date,
  });
}

// Delegate for SliverPersistentHeader
class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CustomScrollPhysics extends ScrollPhysics {
  const CustomScrollPhysics({super.parent});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset / 2;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    } else if (position.maxScrollExtent <= position.pixels &&
        position.pixels < value) {
      return value - position.pixels;
    }
    return 0.0;
  }
}
