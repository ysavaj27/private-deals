import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/desktop_secondary_landing_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/pre_ipo_list_page_ctrl.dart';

class PhonePreIPOListView extends StatelessWidget {
  final PreIPOListPageCtrl c = Get.find<PreIPOListPageCtrl>();

  PhonePreIPOListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: BackButton(onPressed: onBackPressed),
        title: Text(
          "${(Get.parameters['type'] ?? "").toString().capitalizeFirst}",
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: c.scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: false,
              floating: true,
              delegate: SliverAppBarDelegate(
                minHeight: 80.0,
                maxHeight: 80.0,
                child: Container(
                  color: context.theme.scaffoldBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: SearchBarTextField(
                    radius: 6,
                    hintText: "Search Businesses",
                    onChanged: (p0) => c.search(p0),
                  ),
                ),
              ),
            ),
            Obx(() {
              if (c.isLoading.isFalse) {
                if (c.list.isNotEmpty) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      addAutomaticKeepAlives: true,
                      (context, index) {
                        var model = c.list[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              Get.to(
                                () => PreIPODetailPage(),
                                arguments: model.id,
                              );
                            },
                            child: CustomCardWidget(
                              radius: 6,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      LogoImage(
                                        url: model.logo,
                                        radius: 6,
                                        height: 53,
                                        width: 53,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          model.brandName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      ChartWidget(
                                        list: model.sharePrices,
                                        width: 45.82,
                                        height: 36.98,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 23),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Share Price",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context
                                                    .theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${model.sharePrice.toCurrency}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Lot Size",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context
                                                    .theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${model.fundamentals.lotSize}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Depository",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context
                                                    .theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              model.fundamentals.depository,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      addSemanticIndexes: true,
                      childCount: c.list.length, // Adjust the count as needed
                    ),
                  );
                } else {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpace.xl),
                      child: NoDataView(isRefreshButton: false),
                    ),
                  );
                }
              } else {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: context.height * 0.5,
                    child: const Loader(),
                  ),
                );
              }
            }),
            Obx(() {
              return SliverToBoxAdapter(
                child: Visibility(
                  visible: c.isLoadMore.value,
                  child: SizedBox(height: 100, child: const Loader()),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ChartWidget extends StatelessWidget {
  final List<SharePriceModel> list;
  final double? height;
  final double? width;

  const ChartWidget({super.key, required this.list, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      width: width ?? 70,
      child: SfCartesianChart(
        margin: EdgeInsets.zero,
        plotAreaBorderWidth: 0,
        primaryXAxis: const DateTimeAxis(isVisible: false),
        primaryYAxis: NumericAxis(
          isVisible: false,
          minimum: _getMinPrice(), // Set minimum value for Y axis
        ),
        series: _getDefaultLineSeries(context),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  double _getMinPrice() {
    final prices = list.map((e) => e.price).toList();
    var data = prices.isNotEmpty
        ? prices.reduce((a, b) => a < b ? a : b)
        : 0.0; // Return the minimum price
    return data.toDouble();
  }

  /// The method returns line series to chart.
  List<AreaSeries<SharePriceModel, DateTime>> _getDefaultLineSeries(
    BuildContext context,
  ) {
    return <AreaSeries<SharePriceModel, DateTime>>[
      AreaSeries<SharePriceModel, DateTime>(
        dataSource: list,
        enableTooltip: true,
        borderColor: Colors.orange,
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [context.theme.scaffoldBackgroundColor, Color(0xff5E3E1A)],
        ),

        xValueMapper: (SharePriceModel sales, _) => sales.date,
        yValueMapper: (SharePriceModel sales, _) => sales.price,

        // name: 'Germany',
        // markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
}
