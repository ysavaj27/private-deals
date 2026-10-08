import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/desktop_dashboard_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/sector_startup_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/phone_dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  final DashboardPageCtrl c = Get.put(DashboardPageCtrl());

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneDashboardView();
    } else {
      return DesktopDashboardView();
    }
  }
}

class InvestmentPieChart extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  InvestmentPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      // title: const ChartTitle(
      //     text: 'Various countries population density and area'),
      legend: Legend(
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: context.theme.colorScheme.onSurface),
      ),
      palette: AppColors.pieChartPalette(context),
      series: <PieSeries<DataModel, String>>[
        PieSeries<DataModel, String>(
          dataSource: c.investmentPieChartList,
          // enableTooltip: true,
          xValueMapper: (DataModel data, _) => data.title,
          yValueMapper: (DataModel data, _) => data.numData2.toInt(),
          dataLabelMapper: (DataModel data, _) => data.title,
          strokeColor: AppColors.chartStrokeColor(context),
          onPointTap: (pointInteractionDetails) {
            var index = pointInteractionDetails.viewportPointIndex;
            if (index != null && index is int) {
              var model = c.investmentPieChartList[index];
              showCustomDialog(SectorStartupDialog(model.info));
            }
            // logger.d(
            //     'Data :${c.pieChartList[index?.toInt() ?? 0].toJson()}');
          },
          startAngle: 20,
          endAngle: 20,
          strokeWidth: 0.2,
          pointRadiusMapper: (DataModel data, _) => data.data,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            overflowMode: OverflowMode.shift,
            alignment: ChartAlignment.near,
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

  /// Returns the pie series.
  /*
  List<PieSeries<ChartSampleData, String>> _getRadiusPieSeries() {
    return <PieSeries<ChartSampleData, String>>[
      PieSeries<ChartSampleData, String>(
          dataSource: <ChartSampleData>[
            ChartSampleData(x: 'Argentina', y: 505370, text: '45%'),
            ChartSampleData(x: 'Belgium', y: 551500, text: '53.7%'),
            ChartSampleData(x: 'Cuba', y: 312685, text: '59.6%'),
            ChartSampleData(x: 'Dominican Republic', y: 350000, text: '72.5%'),
            ChartSampleData(x: 'Egypt', y: 301000, text: '85.8%'),
            ChartSampleData(x: 'Kazakhstan', y: 300000, text: '90.5%'),
            ChartSampleData(x: 'Somalia', y: 357022, text: '95.6%')
          ],
          xValueMapper: (ChartSampleData data, _) => data.x as String,
          yValueMapper: (ChartSampleData data, _) => data.y,
          dataLabelMapper: (ChartSampleData data, _) => data.x as String,
          startAngle: 100,
          endAngle: 100,
          // pointRadiusMapper: (ChartSampleData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelPosition: ChartDataLabelPosition.outside))
    ];
  }
*/
}

class ChartSampleData {
  String x;
  double y;
  String text;

  ChartSampleData({required this.y, required this.text, required this.x});
}

class NumberPieChartWidget extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();
  final RxBool isHovering = false.obs;

  NumberPieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      // title: const ChartTitle(text: 'Numbers'),
      legend: Legend(
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: context.theme.colorScheme.onSurface),
      ),
      palette: AppColors.pieChartPalette(context),
      series: <PieSeries<DataModel, String>>[
        PieSeries<DataModel, String>(
          dataSource: c.numberPieChartList,
          // enableTooltip: true,
          xValueMapper: (DataModel data, _) => data.title,
          yValueMapper: (DataModel data, _) => data.numData.toInt(),
          dataLabelMapper: (DataModel data, _) =>
              "${data.title} : ${data.numData.toInt()}",
          strokeColor: AppColors.chartStrokeColor(context),
          onPointTap: (pointInteractionDetails) {
            var index = pointInteractionDetails.viewportPointIndex;
            if (index != null && index is int) {
              var model = c.numberPieChartList[index];
              showCustomDialog(SectorStartupDialog(model.info));
            }
            // logger.d(
            //     'Data :${c.pieChartList[index?.toInt() ?? 0].toJson()}');
          },
          startAngle: 20,
          endAngle: 20,
          strokeWidth: 0.2,
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
}

class ActiveInvestorPieChart extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  ActiveInvestorPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      // title: const ChartTitle(text: 'Numbers'),
      legend: Legend(
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: context.theme.colorScheme.onSurface),
      ),
      palette: AppColors.pieChartPalette(context),
      series: <PieSeries<DataModel<List<Active>>, String>>[
        PieSeries<DataModel<List<Active>>, String>(
          dataSource: c.activeInvestorList,
          // enableTooltip: true,
          xValueMapper: (DataModel<List<Active>> data, _) => data.title,
          yValueMapper: (DataModel<List<Active>> data, _) => data.index,
          dataLabelMapper: (DataModel<List<Active>> data, _) =>
              "${data.title} : ${data.index.toInt()}",
          strokeColor: AppColors.chartStrokeColor(context),
          onPointTap: (pointInteractionDetails) {
            var index = pointInteractionDetails.viewportPointIndex;
            if (index != null && index is int) {
              var model = c.activeInvestorList[index];
              if (model.info != null) {
                showCustomDialog(
                  InvestorsListDialog(
                    investorList: model.info!,
                    isCompleted: model.title == "Active" ? true : false,
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
  }
}

class KycInvestorPieChart extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  KycInvestorPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      // title: const ChartTitle(text: 'Numbers'),
      legend: Legend(
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: context.theme.colorScheme.onSurface),
      ),
      palette: AppColors.pieChartPalette(context),
      series: <PieSeries<DataModel<List<Active>>, String>>[
        PieSeries<DataModel<List<Active>>, String>(
          dataSource: c.kycInvestorList,
          // enableTooltip: true,
          xValueMapper: (DataModel<List<Active>> data, _) => "${data.index}",
          yValueMapper: (DataModel<List<Active>> data, _) => data.index,
          dataLabelMapper: (DataModel<List<Active>> data, _) =>
              "${data.title} : ${data.index}",
          strokeColor: AppColors.chartStrokeColor(context),
          onPointTap: (pointInteractionDetails) {
            var index = pointInteractionDetails.viewportPointIndex;
            if (index != null && index is int) {
              var model = c.kycInvestorList[index];
              if (model.info != null) {
                showCustomDialog(
                  InvestorsListDialog(
                    investorList: model.info!,
                    isCompleted: model.title == "Kyc" ? true : false,
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
}

class InvestorsListDialog extends StatelessWidget {
  final List<Active> investorList;
  final bool isKyc;
  final bool isCompleted;

  const InvestorsListDialog({
    super.key,
    required this.investorList,
    this.isKyc = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      width: 600,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Investors",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.height * 0.6,
              minHeight: 100,
            ),
            child: investorList.isNotEmpty
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      children: investorList.map((model) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  model.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              Visibility(
                                visible: isKyc,
                                child: isCompleted
                                    ? const Text('Completed')
                                    : CompleteInvestorKycButton(
                                        investor: InvestorModel(
                                          id: model.id,
                                          name: model.name,
                                          email: model.email,
                                        ),
                                        onSaved: () async {
                                          Get.back();
                                          await Get.find<DashboardPageCtrl>()
                                              .getData();
                                        },
                                      ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const InlineEmptyView(height: 200),
          ),
        ],
      ),
    );
  }
}
