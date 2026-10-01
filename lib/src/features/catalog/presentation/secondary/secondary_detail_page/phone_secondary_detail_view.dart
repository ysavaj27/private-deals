import 'package:private_deals/src/shared/widgets/detail_information_row.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_progressbar.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_detail_page/secondary_detail_page_ctrl.dart';

class PhoneSecondaryDetailView extends StatelessWidget {
  final SecondaryDetailPageCtrl c = Get.find<SecondaryDetailPageCtrl>();

  PhoneSecondaryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: CustomElevatedButton(
          backgroundColor: AppColors.green(context),
          text: 'Buy',
          onPressed: () async {
            Get.toNamed(Routes.preIPOInvestmentPath(Get.currentRoute), arguments: c.model());
            // Get.to(() => PrivateEquityInvestmentPage(), arguments: c.model());
            // var res = await showCustomDialog(InvestorListDialog());
            // Get.delete<InvestorListDialogCtrl>();
            // if (res is InvestorModel) {

            // if (data == true) {
            //   c.getData();
            // }
            // }
          },
        ),
      ),
      // extendBodyBehindAppBar: true,
      body: Obx(() {
        if (c.isLoading.isFalse) {
          return SingleChildScrollView(
            controller: c.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            child: StickyHeader(
              header: Container(
                color: context.theme.scaffoldBackgroundColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LogoImage(
                          url: c.model().logo,
                          height: 35,
                          width: 35,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(c.model().brandName),
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${c.model().sharePrice.toCurrency} ',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: c.model().profitLossString,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.model().resultColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Distributor price ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${c.model().distributerPrice.toCurrency} ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    key: c.sectionKeys[0],
                    "About ${c.model().brandName}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Obx(() {
                      return RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: c.isExpanded.isTrue
                                  ? c.model().about
                                  : c.model().about.substring(
                                          0,
                                          c
                                              .model()
                                              .about
                                              .length
                                              .clamp(0, 100)) +
                                      '...',
                            ),
                            if (c.isExpanded.isFalse)
                              TextSpan(
                                text: " Read More",
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => c.isExpanded(true),
                              ),
                            if (c.isExpanded.isTrue)
                              TextSpan(
                                text: " Read Less",
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => c.isExpanded(false),
                              ),
                          ],
                        ),
                      );
                    }),
                    // Text(
                    //   c.isExpanded.isTrue
                    //       ? c.model().about
                    //       : c.model().about.substring(0, c.model().about.length.clamp(0, 100)) + '...',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w400,
                    //     color: context.theme.colorScheme.onSurfaceVariant,
                    //   ),
                    // ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    key: c.sectionKeys[1],
                    "Fundamentals",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return CustomCardWidget(
                      borderColor: context.theme.colorScheme.outlineVariant,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          _TitleSubTitleWidget(
                            title: "Share Price",
                            subTitle: '${c.model().sharePrice.toCurrency}',
                          ),
                          const SizedBox.shrink(),
                          const _TitleSubTitleWidget(
                            title: "Unlisted Shares Price",
                            subTitle: 'Per Equity Share',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Lot Size",
                            subTitle: '${c.model().fundamentals.lotSize}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "52 Week High",
                            subTitle:
                                '${c.model().fundamentals.fiftyTwoWeekHigh}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "52 Week Low",
                            subTitle:
                                '${c.model().fundamentals.fiftyTwoWeekLow}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Depository",
                            subTitle: c.model().fundamentals.depository,
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "PAN Number",
                            subTitle: c.model().fundamentals.panNumber,
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "ISN Number",
                            subTitle: c.model().fundamentals.isinNumber,
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "CIN",
                            subTitle: c.model().fundamentals.cinNumber,
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "RTA",
                            subTitle: c.model().fundamentals.rta,
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Market Cap (in cr.)",
                            subTitle: '${c.model().fundamentals.marketCap}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "P/E Ratio",
                            subTitle: '${c.model().fundamentals.peRatio}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "P/B Ratio",
                            subTitle: '${c.model().fundamentals.pbRatio}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Debt to Equity",
                            subTitle: '${c.model().fundamentals.debtToEquity}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "ROE (%)",
                            subTitle: '${c.model().fundamentals.roe}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Book Value",
                            subTitle: '${c.model().fundamentals.bookValue}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Face Value",
                            subTitle: '${c.model().fundamentals.faceValue}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Total Shares",
                            subTitle: '${c.model().fundamentals.totalShares}',
                          ),
                          const SizedBox.shrink(),
                          _TitleSubTitleWidget(
                            title: "Company Name",
                            subTitle: c.model().companyName,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 42),
                  const Text(
                    "Current Share Price",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${c.model().sharePrice.toCurrency}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        c.model().profitLossString,
                        style: TextStyle(
                          color: c.model().resultColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),
                  LineChartWidget(),
                  const SizedBox(height: 42),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          key: c.sectionKeys[2],
                          "Financials",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff252525),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        child: Text(
                          'Figures in cr.',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      FinancialsTabWidget(1, "Income Statement"),
                      // const SizedBox(width: 60),
                      FinancialsTabWidget(2, "Balance Sheet"),
                      // const SizedBox(width: 60),
                      FinancialsTabWidget(3, "Cash Flow"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Obx(() {
                        if (c.model().id.isNotEmpty) {
                          return FinancialsMainWidget();
                        } else {
                          return const SizedBox();
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: c.model().shareHolders.isNotEmpty,
                    child: Text(
                      key: c.sectionKeys[3],
                      "Shareholding Pattern",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: c.model().shareHolders.isNotEmpty,
                    child: const SizedBox(height: 15),
                  ),
                  Obx(() {
                    return Visibility(
                      visible: c.model().shareHolders.isNotEmpty,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // direction: Axis.vertical,
                        // alignment: WrapAlignment.center,
                        // crossAxisAlignment: WrapCrossAlignment.center,
                        // runAlignment: WrapAlignment.center,
                        children: List.generate(
                          c.model().shareHolders.length,
                          (index) {
                            var model = c.model().shareHolders[index];
                            return Obx(() {
                              bool isSelected = c.shareHoldingTab() == index;
                              return InkWell(
                                onTap: () {
                                  c.shareHoldingTab(index);
                                  c.shareHoldingTab.refresh();
                                },
                                overlayColor: const WidgetStatePropertyAll(
                                    Colors.transparent),
                                child: AnimatedContainer(
                                  // margin: isSelected
                                  //     ? EdgeInsets.zero
                                  //     : const EdgeInsets.symmetric(
                                  //         horizontal: 33),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.iconColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(38),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${model.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? context
                                              .theme.scaffoldBackgroundColor
                                          : context.iconColor,
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  Visibility(
                    visible: c.model().shareHolders.isNotEmpty,
                    child: const SizedBox(height: 15),
                  ),
                  Obx(() {
                    if (c.model().shareHolders.isNotEmpty) {
                      var list = c
                          .model()
                          .shareHolders[c.shareHoldingTab()]
                          .shareholders;
                      if (list.isNotEmpty) {
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var model = list[index];
                            return ShareHolderSlider(model);
                          },
                        );
                      }
                    }
                    return const SizedBox();
                  }),
                  Visibility(
                    visible: c.model().shareHolders.isNotEmpty,
                    child: const SizedBox(height: 33),
                  ),
                  Text(
                    key: c.sectionKeys[4],
                    "Peer Ratio",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Obx(() {
                    return PeerTableWidget(c.model().peerRatios);
                  }),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: c.model().events.isNotEmpty,
                    child: Text(
                      "Events",
                      key: c.sectionKeys[5],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: c.model().events.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10),
                      itemBuilder: (context, index) {
                        var model = c.model().events[index];
                        return CustomCardWidget(
                          borderColor: context.theme.colorScheme.outlineVariant,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            children: [
                              Text(
                                model.title,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 7),
                              Text(
                                model.description,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Visibility(
                                    visible: model.file.isNotEmpty,
                                    child: DownloadButton(
                                      color: context.iconColor,
                                      size: 25,
                                      onTap: () {
                                        DownloadFile.downloadFromUrl(
                                          url: model.file,
                                          fileName: model.title,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  model.date.showDate,
                                  style: TextStyle(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 25),
                  Visibility(
                    visible: c.model().promoters.isNotEmpty,
                    child: Text(
                      "Promoters or Management",
                      key: c.sectionKeys[6],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PromotersWidget(c.model().promoters),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        } else {
          return const Loader();
        }
      }),
    );
  }
}

class _TitleSubTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const _TitleSubTitleWidget({required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) =>
      DetailInformationRow(label: title, value: subTitle);
}

class LineChartWidget extends StatelessWidget {
  final SecondaryDetailPageCtrl c = Get.find<SecondaryDetailPageCtrl>();

  LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 180,
        child: SfCartesianChart(
          // title: const ChartTitle(text: 'Inflation - Consumer price'),
          plotAreaBorderWidth: 0,
          // legend: Legend(
          //     isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
          primaryXAxis: DateTimeAxis(
            edgeLabelPlacement: EdgeLabelPlacement.none,
            intervalType: DateTimeIntervalType.auto,
            dateFormat: DateFormat.yMMM(),
            labelStyle:
                TextStyle(color: context.theme.colorScheme.onSurfaceVariant),
            majorGridLines: const MajorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            // labelFormat: '{value}%',
            axisLine: const AxisLine(width: 0),
            labelStyle:
                TextStyle(color: context.theme.colorScheme.onSurfaceVariant),

            majorTickLines: const MajorTickLines(color: Colors.transparent),
            minimum: _getMinPrice(), // Set minimum value for Y axis
          ),
          series: _getDefaultLineSeries(),
          tooltipBehavior: TooltipBehavior(enable: false),
        ),
      );
    });
  }

  /// Calculate the minimum price from the share prices list
  double _getMinPrice() {
    final prices = c.model().sharePrices.map((e) => e.price).toList();
    var data = prices.isNotEmpty
        ? prices.reduce((a, b) => a < b ? a : b)
        : 0.0; // Return the minimum price
    return data.toDouble();
  }

  /// The method returns line series to chart.
  List<LineSeries<SharePriceModel, DateTime>> _getDefaultLineSeries() {
    return <LineSeries<SharePriceModel, DateTime>>[
      LineSeries<SharePriceModel, DateTime>(
        dataSource: c.model().sharePrices,
        color: Get.iconColor,
        xValueMapper: (SharePriceModel sales, _) => sales.date,
        yValueMapper: (SharePriceModel sales, _) => sales.price,

        // name: 'Germany',
        // markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
}

class FinancialsTabWidget extends StatelessWidget {
  final int index;
  final String title;
  final SecondaryDetailPageCtrl c = Get.find<SecondaryDetailPageCtrl>();

  FinancialsTabWidget(this.index, this.title, {super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final selected = c.financialTab() == index;
        final colors = context.theme.colorScheme;
        return TextButton(
          onPressed: () => c.financialTab(index),
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? colors.primaryContainer
                : colors.surfaceContainerHigh,
            foregroundColor:
                selected ? colors.onPrimaryContainer : colors.onSurface,
            side: BorderSide(
                color: colors.outlineVariant),
          ),
          child: Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
        );
      });
}

class FinancialsMainWidget extends StatelessWidget {
  final SecondaryDetailPageCtrl c = Get.find<SecondaryDetailPageCtrl>();

  FinancialsMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (c.model().customData.isNotEmpty) {
          switch (c.financialTab()) {
            case 1:
              return Column(
                children: [
                  Visibility(
                    visible: c.model().customData.isNotEmpty,
                    child: _FinancialsTableWidget(c.model().customData.first),
                  ),
                  const SizedBox(height: 8),
                  Visibility(
                    visible: c.model().customData.length >= 2,
                    child: _FinancialsTableWidget(c.model().customData[1]),
                  ),
                ],
              );
            case 2:
              return Column(
                children: [
                  Visibility(
                    visible: c.model().customData.length >= 3,
                    child: _FinancialsTableWidget(c.model().customData[2]),
                  ),
                ],
              );
            case 3:
              return Column(
                children: [
                  Visibility(
                    visible: c.model().customData.length >= 4,
                    child: _FinancialsTableWidget(c.model().customData[3]),
                  ),
                ],
              );
            default:
              return Container();
          }
        } else {
          return const InlineEmptyView(height: 200);
        }
      },
    );
  }
}

class _FinancialsTableWidget extends StatefulWidget {
  final CustomDataModel model;

  const _FinancialsTableWidget(this.model);

  @override
  State<_FinancialsTableWidget> createState() => _FinancialsTableWidgetState();
}

class _FinancialsTableWidgetState extends State<_FinancialsTableWidget> {
  int selectedYearIndex = 0; // Start with the first year (index 1)

  @override
  Widget build(BuildContext context) {
    if (widget.model.values.length >= 2) {
      final years = widget.model.values[0]
          .sublist(1)
          .where((e) => e != null)
          .toList()
          .cast<int>();
      return CustomCardWidget(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        radius: 6,
        borderColor: context.theme.colorScheme.outlineVariant,
        child: Table(
          columnWidths: {
            for (var i = 0; i < widget.model.values.first.length; i++)
              i: FlexColumnWidth(i == 0 ? 40 : 10),
          },
          border: TableBorder(
            horizontalInside: BorderSide(
                color: context.theme.disabledColor, strokeAlign: 0.1, width: 1),
          ),
          children: [
            TableRow(
              children: [
                Text(
                  "${widget.model.values[0][0]}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    isDense: true,
                    value: years[selectedYearIndex],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    isExpanded: false,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYearIndex = years.indexOf(newValue);
                        });
                      }
                    },
                    items: years.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          "${value}",
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            ...widget.model.values.skip(1).map((rowData) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${rowData[0]}",
                      style: TextStyle(
                          color: context.theme.colorScheme.onSurfaceVariant,
                          fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "${rowData[selectedYearIndex + 1]}",
                      // style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class ShareHolderSlider extends StatelessWidget {
  final ShareHolderModel model;

  const ShareHolderSlider(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.name,
          // style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: CustomPercentageProgressBar(model.percentage)),
            const SizedBox(width: 7),
            Text(
              "${model.percentage} %",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class PeerTableWidget extends StatelessWidget {
  final List<PeerRatioModel> list;

  const PeerTableWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 10,
      borderColor: context.theme.colorScheme.outlineVariant,
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(
              color: context.theme.disabledColor, strokeAlign: 0.1, width: 1),
        ),
        children: [
          TableRow(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: const Text(
                  "Particulars (cr)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    // color: Colors.blue,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: const Text(
                  "Revenue (Fy23)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    // color: Colors.blue,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: const Text(
                  "EPS (FY23)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    // color: Colors.blue,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: const Text(
                  "Mcap (06.01.24) ",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    // color: Colors.blue,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                child: const Text(
                  "P/E (06.01.24)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    // color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          // Table Rows
          ...list.skip(1).map((e) {
            return TableRow(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Text(
                    e.perticular,
                    style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Text(
                    "${e.revenue}",
                    style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Text(
                    "${e.eps}",
                    style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Text(
                    "${e.marketCap}",
                    style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  child: Text(
                    e.pe,
                    style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class PromotersWidget extends StatelessWidget {
  final List<PromoterModel> list;

  const PromotersWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        var model = list[index];
        return CustomCardWidget(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.name,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Designation",
                        // style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.designation,
                        // style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "Experience",
                        // style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.experience,
                        // style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        "LinkedIn Profile",
                        // style: TextStyle(fontSize: 12),
                      ),
                      // SizedBox(height: 10),
                      Visibility(
                        visible: model.url.isNotEmpty,
                        child: IconButton(
                          splashRadius: 15,
                          padding: EdgeInsets.zero,
                          onPressed: () => Launcher.launchURL(model.url),
                          icon: const FaIcon(
                            FontAwesomeIcons.linkedinIn,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
