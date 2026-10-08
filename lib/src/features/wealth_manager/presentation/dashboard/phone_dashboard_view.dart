import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_sections.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/sector_startup_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';

class PhoneDashboardView extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  PhoneDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse && c.isData.isTrue) {
        return RefreshIndicator(
          onRefresh: c.getData,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: app.wUser.isPreIpoAccess,
                      child: TabButton(
                        title: "Unlisted",
                        type: DashboardTypeEnum.preIpo,
                        onTap: () {
                          c.changeTab(DashboardTypeEnum.preIpo);
                        },
                        currentIndex: c.currentIndex,
                        // size: context,
                      ),
                    ),
                    Visibility(
                      visible:
                          app.wUser.isPreIpoAccess &&
                          (app.wUser.isSecondaryAccess ||
                              app.wUser.isPrimaryAccess),
                      child: const SizedBox(width: 10),
                    ),
                    Visibility(
                      visible:
                          app.wUser.isSecondaryAccess ||
                          app.wUser.isPrimaryAccess,
                      child: TabButton(
                        title: "Private Equity",
                        type: DashboardTypeEnum.primary,
                        onTap: () {
                          c.changeTab(DashboardTypeEnum.primary);
                        },
                        currentIndex: c.currentIndex,
                        // size: context,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const DashboardHeroCard(),
                const SizedBox(height: AppSpace.md),
                const DashboardKpiStrip(compact: true),
                const SizedBox(height: AppSpace.lg),
                const DashboardPendingStrip(),
                const SizedBox(height: AppSpace.xl),
                const DashboardSectionHeader(
                  title: 'Insights',
                  subtitle: 'Sectors, investors & growth',
                ),
                const SizedBox(height: AppSpace.md),
                SizedBox(
                  height: 400,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView(
                        controller: c.chartPageController,
                        children: c.charts(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: SmoothPageIndicator(
                          controller: c.chartPageController,
                          onDotClicked: (index) {
                            c.chartPageController.jumpToPage(index);
                          },
                          count: 3,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8.0,
                            dotColor: Theme.of(
                              context,
                            ).colorScheme.outlineVariant,
                            activeDotColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                const DashboardTopInvestors(),
                const SizedBox(height: AppSpace.xl),
              ],
            ),
          ),
        );
      } else if (c.isLoading.isTrue) {
        return const Loader();
      } else {
        return ErrorView(
          title: 'Unable to load dashboard',
          message: 'Pull to refresh or try again.',
          onRetry: c.getData,
        );
      }
    });
  }
}

class PendingTaskView extends StatelessWidget {
  final int pendingTask;
  static const int totalTasks = 10;
  final String title;

  const PendingTaskView({
    super.key,
    required this.pendingTask,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final newCount = pendingTask <= 10 ? pendingTask : 10;
    final double completedPercentage = (totalTasks - newCount) / totalTasks;
    return Column(
      children: [
        const SizedBox(height: 10),
        CircularPercentIndicator(
          radius: 30.0,
          lineWidth: 6.0,
          percent: completedPercentage.clamp(0.0, 1.0),
          linearGradient: LinearGradient(
            colors: [
              context.theme.colorScheme.error,
              context.theme.colorScheme.error.withValues(alpha: 0.45),
            ],
          ),
          backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
          circularStrokeCap: CircularStrokeCap.round,
          center: Text("$pendingTask", style: const TextStyle(fontSize: 20.0)),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(color: context.theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class ColumnChartWidget extends StatelessWidget {
  const ColumnChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              "Investment Growth",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: ColumnChart()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ColumnChart extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  ColumnChart({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final axisLabelColor = AppColors.chartAxisLabelColor(context);
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableSideBySideSeriesPlacement: false,
      enableAxisAnimation: true,
      // title: const ChartTitle(text: 'Investment Growth'),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          fontSize: 9,
          overflow: TextOverflow.ellipsis,
          color: axisLabelColor,
        ),
        maximumLabelWidth: 50,
        placeLabelsNearAxisLine: true,
        labelRotation: 350,
      ),
      primaryYAxis: NumericAxis(
        majorTickLines: const MajorTickLines(size: 1),
        labelFormat: '{value}',
        // This will be overridden by the label formatter.
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            details.value.toLakesCorersFormat(),
            TextStyle(color: axisLabelColor, fontSize: 10),
          );
        },
        majorGridLines: const MajorGridLines(width: 0),
        rangePadding: ChartRangePadding.auto,
      ),
      series: _getBackToBackColumn(isDark),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        textStyle: TextStyle(color: AppColors.chartTooltipText(context)),
        color: AppColors.chartTooltipBackground(context),
      ),
    );
  }

  List<ColumnSeries<DataModel, String>> _getBackToBackColumn(bool isDark) {
    return <ColumnSeries<DataModel, String>>[
      ColumnSeries<DataModel, String>(
        dataSource: c.columnList(),
        enableTooltip: true,
        pointColorMapper: (DataModel sales, _) => AppColors.columnBarColor(
          shadeSet: sales.darkColors,
          isDark: isDark,
          isForegroundSeries: false,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        width: 0.5,
        spacing: 0.5,
        name: "Invested",
        xValueMapper: (DataModel sales, _) => sales.title,
        yValueMapper: (DataModel sales, _) => sales.numData2,
        dataLabelMapper: (DataModel sales, _) => sales.image,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          builder:
              (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) {
                return Visibility(
                  visible: data.isBig(data.numData2),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: LogoImage(
                      url: data.image,
                      radius: 2,
                      width: 27,
                      height: 27,
                    ),
                  ),
                );
              },
        ),
      ),
      ColumnSeries<DataModel, String>(
        enableTooltip: true,
        dataSource: c.columnList(),
        width: 0.3,
        name: "Current",
        pointColorMapper: (DataModel sales, _) => AppColors.columnBarColor(
          shadeSet: sales.darkColors,
          isDark: isDark,
          isForegroundSeries: true,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        xValueMapper: (DataModel sales, _) => sales.title,
        yValueMapper: (DataModel sales, _) => sales.numData,
        dataLabelMapper: (DataModel sales, _) => sales.image,
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          builder:
              (
                dynamic data,
                dynamic point,
                dynamic series,
                int pointIndex,
                int seriesIndex,
              ) {
                return Visibility(
                  visible: data.isBig(data.numData),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: LogoImage(
                      url: data.image,
                      radius: 2,
                      width: 27,
                      height: 27,
                    ),
                  ),
                );
              },
        ),
      ),
    ];
  }
}

class MobilePieChartWidget extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  MobilePieChartWidget({super.key});

  //
  // final List<Color> colors = [
  //   Colors.red,
  //   Colors.green,
  //   Colors.blue,
  //   Colors.orange,
  //   Colors.purple,
  // ];

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              "Sector Bifurcation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => c.isInvestment(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: c.isInvestment.isFalse
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(
                        'Number',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.isInvestment.isFalse
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => c.isInvestment(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: c.isInvestment.isTrue
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(
                        'Investment',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.isInvestment.isTrue
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (c.isData.isTrue) {
                if (c.isInvestment.isTrue) {
                  return SfCircularChart(
                    // title: const ChartTitle(
                    //     text: 'Various countries population density and area'),
                    legend: Legend(
                      overflowMode: LegendItemOverflowMode.none,
                      textStyle: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    palette: AppColors.pieChartPalette(context),
                    series: <PieSeries<DataModel, String>>[
                      PieSeries<DataModel, String>(
                        dataSource: c.investmentPieChartList,
                        // enableTooltip: true,
                        xValueMapper: (DataModel data, _) => data.title,
                        yValueMapper: (DataModel data, _) =>
                            data.numData2.toInt(),
                        dataLabelMapper: (DataModel data, _) => data.title,
                        strokeColor: AppColors.chartStrokeColor(context),
                        onPointTap: (pointInteractionDetails) {
                          var index =
                              pointInteractionDetails.viewportPointIndex;
                          if (index != null && index is int) {
                            var model = c.investmentPieChartList[index];
                            showCustomDialog(SectorStartupDialog(model.info));
                          }
                        },
                        strokeWidth: 0.7,
                        startAngle: 315,
                        endAngle: 315,
                        pointRadiusMapper: (DataModel data, _) => data.data,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          overflowMode: OverflowMode.shift,
                          alignment: ChartAlignment.far,
                          labelAlignment: ChartDataLabelAlignment.auto,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: TextStyle(
                            color: context.theme.colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // onTooltipRender: (TooltipArgs args) {
                    //   final NumberFormat format = NumberFormat.decimalPattern();
                    //   args.text =
                    //       '${args.dataPoints![args.pointIndex!.toInt()].x} : ${format.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                    // },
                    // tooltipBehavior: TooltipBehavior(enable: true, elevation: 10),
                  );
                } else {
                  return SfCircularChart(
                    // title: const ChartTitle(
                    //     text: 'Various countries population density and area'),
                    legend: Legend(
                      overflowMode: LegendItemOverflowMode.none,
                      textStyle: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    palette: AppColors.pieChartPalette(context),
                    series: <PieSeries<DataModel, String>>[
                      PieSeries<DataModel, String>(
                        dataSource: c.numberPieChartList,
                        // enableTooltip: true,
                        xValueMapper: (DataModel data, _) => data.title,
                        yValueMapper: (DataModel data, _) =>
                            data.numData.toInt(),
                        dataLabelMapper: (DataModel data, _) =>
                            "${data.title} : ${data.numData.toInt()}",
                        strokeColor: AppColors.chartStrokeColor(context),
                        onPointTap: (pointInteractionDetails) {
                          var index =
                              pointInteractionDetails.viewportPointIndex;
                          if (index != null && index is int) {
                            var model = c.numberPieChartList[index];
                            showCustomDialog(SectorStartupDialog(model.info));
                          }

                          // logger.d(
                          //     'Data :${c.pieChartList[index?.toInt() ?? 0].toJson()}');
                        },
                        strokeWidth: 0.7,
                        startAngle: 315,
                        endAngle: 315,
                        pointRadiusMapper: (DataModel data, _) => data.data,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          overflowMode: OverflowMode.shift,
                          alignment: ChartAlignment.far,
                          labelAlignment: ChartDataLabelAlignment.auto,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: TextStyle(
                            color: context.theme.colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // onTooltipRender: (TooltipArgs args) {
                    //   final NumberFormat format = NumberFormat.decimalPattern();
                    //   args.text =
                    //       '${args.dataPoints![args.pointIndex!.toInt()].x} : ${format.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                    // },
                    // tooltipBehavior: TooltipBehavior(enable: true, elevation: 10),
                  );
                }
              } else {
                return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }
}

class InvestorPieChartWidget extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  InvestorPieChartWidget({super.key});

  //
  // final List<Color> colors = [
  //   Colors.red,
  //   Colors.green,
  //   Colors.blue,
  //   Colors.orange,
  //   Colors.purple,
  // ];

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              "Investors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => c.isActive(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: c.isActive.isFalse
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(
                        'Kyc',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.isActive.isFalse
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => c.isActive(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: c.isActive.isTrue
                            ? context.theme.colorScheme.primary
                            : context.theme.colorScheme.surfaceContainerHigh,
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 12,
                          color: c.isActive.isTrue
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (c.isData.isTrue) {
                if (c.isActive.isTrue) {
                  return SfCircularChart(
                    // title: const ChartTitle(text: 'Numbers'),
                    legend: Legend(
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    palette: AppColors.pieChartPalette(context),
                    series: <PieSeries<DataModel<List<Active>>, String>>[
                      PieSeries<DataModel<List<Active>>, String>(
                        dataSource: c.activeInvestorList,
                        // enableTooltip: true,
                        xValueMapper: (DataModel<List<Active>> data, _) =>
                            data.title,
                        yValueMapper: (DataModel<List<Active>> data, _) =>
                            data.index,
                        dataLabelMapper: (DataModel<List<Active>> data, _) =>
                            "${data.title} : ${data.index.toInt()}",
                        strokeColor: AppColors.chartStrokeColor(context),
                        onPointTap: (pointInteractionDetails) {
                          var index =
                              pointInteractionDetails.viewportPointIndex;
                          if (index != null && index is int) {
                            var model = c.activeInvestorList[index];
                            if (model.info != null) {
                              showCustomDialog(
                                InvestorsListDialog(
                                  investorList: model.info!,
                                  isCompleted: model.title == "Active"
                                      ? true
                                      : false,
                                  isKyc: false,
                                ),
                              );
                            }
                          }
                          // logger.d(
                          //     'Data :${c.pieChartList[index?.toInt() ?? 0].toJson()}');
                        },
                        startAngle: 20,
                        endAngle: 20,
                        strokeWidth: 0.2,
                        radius: "80%",
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          overflowMode: OverflowMode.shift,
                          alignment: ChartAlignment.far,
                          labelAlignment: ChartDataLabelAlignment.auto,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: TextStyle(
                            color: context.theme.colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // onTooltipRender: (TooltipArgs args) {
                    //   final NumberFormat format = NumberFormat.decimalPattern();
                    //   args.text =
                    //       '${args.dataPoints![args.pointIndex!.toInt()].x} : ${format.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                    // },
                    // tooltipBehavior: TooltipBehavior(enable: true, elevation: 10),
                  );
                } else {
                  return SfCircularChart(
                    // title: const ChartTitle(text: 'Numbers'),
                    legend: Legend(
                      overflowMode: LegendItemOverflowMode.wrap,
                      textStyle: TextStyle(
                        color: context.theme.colorScheme.onSurface,
                      ),
                    ),
                    palette: AppColors.pieChartPalette(context),
                    series: <PieSeries<DataModel<List<Active>>, String>>[
                      PieSeries<DataModel<List<Active>>, String>(
                        dataSource: c.kycInvestorList,
                        // enableTooltip: true,
                        xValueMapper: (DataModel<List<Active>> data, _) =>
                            "${data.index}",
                        yValueMapper: (DataModel<List<Active>> data, _) =>
                            data.index,
                        dataLabelMapper: (DataModel<List<Active>> data, _) =>
                            "${data.title} : ${data.index}",
                        strokeColor: AppColors.chartStrokeColor(context),
                        onPointTap: (pointInteractionDetails) {
                          var index =
                              pointInteractionDetails.viewportPointIndex;
                          if (index != null && index is int) {
                            var model = c.kycInvestorList[index];
                            if (model.info != null) {
                              showCustomDialog(
                                InvestorsListDialog(
                                  investorList: model.info!,
                                  isCompleted: model.title == "Kyc"
                                      ? true
                                      : false,
                                  isKyc: true,
                                ),
                              );
                            }
                          }
                          // logger.d(
                          //     'Data :${c.pieChartList[index?.toInt() ?? 0].toJson()}');
                        },
                        startAngle: 20,
                        endAngle: 20,
                        strokeWidth: 0.2,
                        radius: "80%",
                        // pointRadiusMapper: (Active data, _) => data.data,
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          overflowMode: OverflowMode.shift,
                          alignment: ChartAlignment.far,
                          labelAlignment: ChartDataLabelAlignment.auto,
                          labelPosition: ChartDataLabelPosition.inside,
                          textStyle: TextStyle(
                            color: context.theme.colorScheme.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    // onTooltipRender: (TooltipArgs args) {
                    //   final NumberFormat format = NumberFormat.decimalPattern();
                    //   args.text =
                    //       '${args.dataPoints![args.pointIndex!.toInt()].x} : ${format.format(args.dataPoints![args.pointIndex!.toInt()].y)}';
                    // },
                    // tooltipBehavior: TooltipBehavior(enable: true, elevation: 10),
                  );
                }
              } else {
                return const SizedBox();
              }
            }),
          ),
        ],
      ),
    );
  }
}
