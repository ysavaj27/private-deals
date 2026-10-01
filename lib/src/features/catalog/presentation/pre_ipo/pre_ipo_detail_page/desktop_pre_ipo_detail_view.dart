import 'package:private_deals/src/shared/widgets/detail_information_row.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';
import 'package:private_deals/src/shared/widgets/custom_progressbar.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/seller_slots_widget.dart';

class DesktopPreIPODetailView extends StatelessWidget {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  DesktopPreIPODetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 25),
              color: context.theme.scaffoldBackgroundColor,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBackPressed,
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomTabBarWidget(
                          index: 0,
                          text: 'About',
                        ),
                        CustomTabBarWidget(
                          index: 1,
                          text: 'Fundamentals',
                        ),
                        CustomTabBarWidget(
                          index: 2,
                          text: 'Financials',
                        ),
                        CustomTabBarWidget(
                          index: 3,
                          text: 'Shareholding Pattern',
                        ),
                        CustomTabBarWidget(
                          index: 4,
                          text: 'Peer Ratio',
                        ),
                        CustomTabBarWidget(
                          index: 5,
                          text: 'Events',
                        ),
                        CustomTabBarWidget(
                          index: 6,
                          text: 'Promoters or Management',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isFalse) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: c.scrollController,
                          padding: const EdgeInsets.only(left: 32, right: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  key: c.sectionKeys[0],
                                  "About ${c.model().brandName}",
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(height: 21),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Text(
                                  c.model().about,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    fontWeight: FontWeight.w400,
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                key: c.sectionKeys[1],
                                "Fundamentals",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(() {
                                return CustomCardWidget(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            // TitleSubTitleWidget(
                                            //   title: "NSE India Limited",
                                            //   subTitle:
                                            //       '${c.model().distributerPrice}',
                                            // ),
                                            // const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Unlisted Shares Price",
                                              subTitle: 'Per Equity Share',
                                            ),
                                            const SizedBox(height: 0),
                                            // TitleSubTitleWidget(
                                            //   title: "Lot Size",
                                            //   subTitle:
                                            //       '${c.model().fundamentals.lotSize}',
                                            // ),
                                            // const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "52 Week High",
                                              subTitle:
                                                  '${c.model().fundamentals.fiftyTwoWeekHigh}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "52 Week Low",
                                              subTitle:
                                                  '${c.model().fundamentals.fiftyTwoWeekLow}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Depository",
                                              subTitle: c
                                                  .model()
                                                  .fundamentals
                                                  .depository,
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "PAN Number",
                                              subTitle: c
                                                  .model()
                                                  .fundamentals
                                                  .panNumber,
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "ISN Number",
                                              subTitle: c
                                                  .model()
                                                  .fundamentals
                                                  .isinNumber,
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "CIN",
                                              subTitle: c
                                                  .model()
                                                  .fundamentals
                                                  .cinNumber,
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "RTA",
                                              subTitle:
                                                  c.model().fundamentals.rta,
                                            ),
                                            const SizedBox(height: 0),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            TitleSubTitleWidget(
                                              title: "Market Cap (in cr.)",
                                              subTitle:
                                                  '${c.model().fundamentals.marketCap}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "P/E Ratio",
                                              subTitle:
                                                  '${c.model().fundamentals.peRatio}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "P/B Ratio",
                                              subTitle:
                                                  '${c.model().fundamentals.pbRatio}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Debt to Equity",
                                              subTitle:
                                                  '${c.model().fundamentals.debtToEquity}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "ROE (%)",
                                              subTitle:
                                                  '${c.model().fundamentals.roe}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Book Value",
                                              subTitle:
                                                  '${c.model().fundamentals.bookValue}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Face Value",
                                              subTitle:
                                                  '${c.model().fundamentals.faceValue}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Total Shares",
                                              subTitle:
                                                  '${c.model().fundamentals.totalShares}',
                                            ),
                                            const SizedBox(height: 0),
                                            TitleSubTitleWidget(
                                              title: "Company Name",
                                              subTitle: c.model().companyName,
                                            ),
                                            const SizedBox(height: 0),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 32),
                              // Row(
                              //   children: [
                              //     Text(
                              //       "${c.purchasePrice}",
                              //       style: const TextStyle(
                              //         fontSize: 24,
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 10),
                              //     Text(
                              //       c.model().profitLossString,
                              //       style: TextStyle(
                              //         color: c.model().resultColor,
                              //         fontSize: 20,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 0),
                              LineChartWidget(),
                              const SizedBox(height: 32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      key: c.sectionKeys[2],
                                      "Financials",
                                      style: const TextStyle(
                                        fontSize: 24,
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
                                        horizontal: 16, vertical: 4),
                                    child: Text(
                                      'Figures in cr.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context
                                            .theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 35),
                              Obx(() {
                                return Visibility(
                                  visible: c.model().customData.isNotEmpty,
                                  child: Row(
                                    children: [
                                      FinancialsTabWidget(
                                          1, "Income Statement"),
                                      const SizedBox(width: 60),
                                      FinancialsTabWidget(2, "Balance Sheet"),
                                      const SizedBox(width: 60),
                                      FinancialsTabWidget(3, "Cash Flow"),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 25),
                              Obx(() {
                                return Visibility(
                                  visible: c.model().customData.isNotEmpty,
                                  child: CustomCardWidget(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 38),
                                    width: Get.width,
                                    color: context.theme.disabledColor
                                        .withValues(alpha: 0.1),
                                    child: FinancialsMainWidget(),
                                    // Column(
                                    //   children: [
                                    //     Obx(() {
                                    //       if (c.model().customData.isNotEmpty) {
                                    //         return ;
                                    //       } else {
                                    //         return const SizedBox();
                                    //       }
                                    //     }),
                                    //   ],
                                    // ),
                                  ),
                                );
                              }),
                              Obx(() {
                                return Visibility(
                                  visible: c.model().customData.isNotEmpty,
                                  child: const SizedBox(height: 32),
                                );
                              }),
                              Visibility(
                                visible: c.model().shareHolders.isNotEmpty,
                                child: Text(
                                  key: c.sectionKeys[3],
                                  "Shareholding Pattern",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 37),
                              Container(
                                height: 50,
                                width: context.width,
                                margin: EdgeInsets.only(
                                    right: context.width * 0.08),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26),
                                  color: context.theme.disabledColor
                                      .withValues(alpha: 0.1),
                                ),
                                child: Obx(() {
                                  return Wrap(
                                    direction: Axis.vertical,
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    children: List.generate(
                                      c.model().shareHolders.length,
                                      (index) {
                                        var model =
                                            c.model().shareHolders[index];
                                        return Obx(() {
                                          bool isSelected =
                                              c.shareHoldingTab() == index;
                                          return InkWell(
                                            mouseCursor:
                                                SystemMouseCursors.click,
                                            onTap: () {
                                              c.shareHoldingTab(index);
                                              c.shareHoldingTab.refresh();
                                            },
                                            overlayColor:
                                                const WidgetStatePropertyAll(
                                                    Colors.transparent),
                                            child: AnimatedContainer(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 66),
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? context.iconColor
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        isSelected ? 30 : 15),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${model.year}',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? context.theme
                                                          .scaffoldBackgroundColor
                                                      : context.iconColor,
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 43),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: context.width * 0.08),
                                child: Obx(() {
                                  if (c.model().shareHolders.isNotEmpty) {
                                    var list = c
                                        .model()
                                        .shareHolders[c.shareHoldingTab()]
                                        .shareholders;
                                    if (list.isNotEmpty) {
                                      return ListView.separated(
                                        itemCount: list.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 26),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          var model = list[index];
                                          return ShareHolderSlider(model);
                                        },
                                      );
                                    }
                                  }
                                  return const SizedBox();
                                }),
                              ),
                              const SizedBox(height: 63),
                              Text(
                                key: c.sectionKeys[4],
                                "Peer Ratio",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 33),
                              Obx(() {
                                return PeerTableWidget(c.model().peerRatios);
                              }),
                              const SizedBox(height: 32),
                              Obx(() {
                                return Visibility(
                                  visible: c.model().events.isNotEmpty,
                                  child: Text(
                                    "Events",
                                    key: c.sectionKeys[5],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              Obx(() {
                                return Visibility(
                                  visible: c.model().events.isNotEmpty,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 38),
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: context.theme.disabledColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: c.model().events.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 30),
                                      itemBuilder: (context, index) {
                                        var model = c.model().events[index];
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 18),
                                          decoration: BoxDecoration(
                                            color: context
                                                .theme.scaffoldBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      model.title,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      model.description,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: context
                                                            .theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  model.date.showDate,
                                                  style: TextStyle(
                                                    color: context
                                                        .theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: model.file.isNotEmpty,
                                                child: DownloadButton(
                                                  color: context.iconColor,
                                                  size: 30,
                                                  onTap: () {
                                                    DownloadFile
                                                        .downloadFromUrl(
                                                      url: model.file,
                                                      fileName: model.title,
                                                    );
                                                  },
                                                ),
                                              ),
                                              // IconButton(
                                              //   onPressed: () {},
                                              //   icon: const Icon(Icons.download, size: 32),
                                              // ),
                                              const SizedBox(height: 20),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }),
                              Obx(() {
                                return Visibility(
                                    visible: c.model().events.isNotEmpty,
                                    child: SizedBox(height: 32));
                              }),
                              Text(
                                "Promoters or Management",
                                key: c.sectionKeys[6],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 30),
                              PromotersWidget(c.model().promoters),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 23),
                      SizedBox(
                        width: 450,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ---------- Identity ----------
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LogoImage(
                                              url: c.model().logo,
                                              height: 72,
                                              width: 72,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                c.model().brandName,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        SellerSlotsWidget(),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Form(
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      key: c.desktopFormKey,
                                      child: Obx(
                                        () {
                                          if (c.investorList.isNotEmpty) {
                                            return ListView.separated(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.only(
                                                  top: 15, right: 20),
                                              itemCount: c.investorList.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const SizedBox(height: 20),
                                              itemBuilder: (context, index) {
                                                return CardView(
                                                    model:
                                                        c.investorList[index]);
                                              },
                                            );
                                          } else {
                                            return const InlineEmptyView(height: 200);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            Obx(() {
                              return Visibility(
                                visible: c.investorList.isNotEmpty,
                                child: CustomElevatedButton(
                                  radius: 10,
                                  isLoading: c.investing.value,
                                  backgroundColor: AppColors.green(context),
                                  onPressed: () {
                                    if (c.desktopFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      c.onPress();
                                    }
                                  },
                                  text: 'Invest',
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                    ],
                  );
                } else {
                  return const Loader();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CardView extends StatelessWidget {
  final SelectInvestorModel model;

  CardView({super.key, required this.model});

  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  void onQtyChange(String? p0) {
    final shares = int.tryParse(p0 ?? "");
    if (shares == null) return;
    model.quantity(shares);
    model.totalPrice((model.quantity * model.price()).toDouble());
  }

  void onAmountChange(String? p0) {
    if (p0 == null || double.tryParse(p0) == null) return;
    var price = double.parse(p0);
    model.price(price);
    model.totalPrice((model.quantity * model.price()).toDouble());
    // model.totalPrice.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 12,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.investorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () => c.investorList.remove(model),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.delete, size: 18, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor(context)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TitleTextField(
                  borderColor:
                      context.theme.disabledColor.withValues(alpha: 0.2),
                  fillColor:
                      context.theme.disabledColor.withValues(alpha: 0.08),
                  name: "Quantity",
                  textInputAction: TextInputAction.next,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  isDense: true,
                  controller: model.quantityCTRL,
                  keyboardType: TextInputType.number,
                  onChanged: onQtyChange,
                  validator: (p0) {
                    if (c.selectedOffer.value != null) {
                      return c.selectedOffer.value!.validateQuantity(p0);
                    }
                    if (p0 == null || p0.isEmpty) {
                      return "Enter quantity";
                    } else if (int.tryParse(p0) == null || int.parse(p0) <= 0) {
                      return 'Enter a whole number of shares';
                    } else if (c.isQty.isTrue &&
                        double.parse(p0) < c.minTicketSize) {
                      return 'Min quantity is ${c.minTicketSize} shares';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      // mouseCursor: SystemMouseCursors.click,
                      // onTap: () {
                      //   model.isMarket.toggle();
                      //   if (model.isMarket.isTrue) {
                      //     model.priceCTRL?.text =
                      //         c.model().sharePrice.toStringAsFixed(0);
                      //   }
                      // },
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                fontSize: context.isPhone ? 14 : 16,
                              ),
                              children: [
                                const TextSpan(text: "Price  "),
                                // TextSpan(
                                //   text: model.isMarket.isTrue
                                //       ? "Market"
                                //       : "Limit",
                                //   style: TextStyle(
                                //     color: context.iconColor,
                                //     fontWeight: FontWeight.w500,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          // const SizedBox(width: 1),
                          // const Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    CustomTextField(
                      autofocus: true,
                      isFilled: true,
                      borderColor:
                          context.theme.disabledColor.withValues(alpha: 0.2),
                      fillColor:
                          context.theme.disabledColor.withValues(alpha: 0.06),
                      // readOnly: model.isMarket.isTrue,
                      // enabled: model.isMarket.isFalse,
                      controller: model.priceCTRL,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      isDense: true,
                      onChanged: onAmountChange,
                      validator: (p0) {
                        if (c.selectedOffer.value != null) {
                          return c.selectedOffer.value!.validatePrice(p0);
                        }
                        if (p0 == null || p0.isEmpty) {
                          return "Please enter amount";
                        } else if (double.tryParse(p0) == null) {
                          return 'Enter valid amount';
                        } else if (double.parse(p0) < c.purchasePrice) {
                          return 'Min price ${c.purchasePrice}';
                        } else if (c.isQty.isFalse &&
                            model.totalPrice() < c.minTicketSize) {
                          return 'Min ticket size is ${c.minTicketSize.toCurrency}';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Total Amount :"),
                    const SizedBox(width: 10),
                    Obx(() {
                      return Text(
                        model.totalPrice().toCurrency,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TitleSubTitleWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  const TitleSubTitleWidget(
      {super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) =>
      DetailInformationRow(label: title, value: subTitle);
}

class LineChartWidget extends StatelessWidget {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  LineChartWidget({super.key});

  final TooltipBehavior _tooltipBehavior = TooltipBehavior(
    enable: true,
    builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
        int seriesIndex) {
      final SharePriceModel model = data as SharePriceModel;
      final ColorScheme scheme = Get.theme.colorScheme;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: Get.isDarkMode ? 0.20 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMd().format(model.date),
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
            Text(
              model.price.toCurrency,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.model().sharePrices.isNotEmpty &&
          c.model().sharePrices.length >= 3) {
        return SizedBox(
          height: 400,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              edgeLabelPlacement: EdgeLabelPlacement.none,
              intervalType: DateTimeIntervalType.auto,
              dateFormat: DateFormat.yMMM(),
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(color: Colors.transparent),
              minimum: _getMinPrice(),
            ),
            series: _getDefaultLineSeries(),
            tooltipBehavior: _tooltipBehavior,
          ),
        );
      } else {
        return const InlineEmptyView(height: 200);
      }
    });
  }

  double _getMinPrice() {
    final prices = c.model().sharePrices.map((e) => e.price).toList();
    var data = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
    return data.toDouble();
  }

  List<LineSeries<SharePriceModel, DateTime>> _getDefaultLineSeries() {
    return <LineSeries<SharePriceModel, DateTime>>[
      LineSeries<SharePriceModel, DateTime>(
        dataSource: c.model().sharePrices,
        color: Get.iconColor,
        name: c.model().brandName,
        // series name now uses brandName
        xValueMapper: (SharePriceModel sales, _) => sales.date,
        yValueMapper: (SharePriceModel sales, _) => sales.price,
        enableTooltip: true,
      ),
    ];
  }
}

class FinancialsMainWidget extends StatelessWidget {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  FinancialsMainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        switch (c.financialTab()) {
          case 1:
            return Column(
              children: [
                FinancialsTableWidget(c.model().customData.first),
                const SizedBox(height: 38),
                FinancialsTableWidget(c.model().customData[1]),
              ],
            );
          case 2:
            return Column(
              children: [
                FinancialsTableWidget(c.model().customData[2]),
              ],
            );
          case 3:
            return Column(
              children: [
                FinancialsTableWidget(c.model().customData[3]),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }
}

class FinancialsTableWidget extends StatelessWidget {
  final CustomDataModel model;

  const FinancialsTableWidget(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    final header = model.values.first.where((e) => e != null);
    final rows = model.values
        .skip(1)
        .where((e) => e.any((cell) => cell != null))
        .where((row) => row.length == header.length)
        .map((rowData) {
      return rowData;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        CustomCardWidget(
          color: context.theme.scaffoldBackgroundColor,
          radius: 10,
          borderColor: context.theme.colorScheme.outlineVariant,
          child: Table(
            columnWidths: {
              for (var i = 0; i < header.length; i++)
                i: FlexColumnWidth(i == 0 ? 25 : 10),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: context.theme.disabledColor,
                  strokeAlign: 0.1,
                  width: 1),
            ),
            children: [
              TableRow(
                children:
                    model.values.first.where((e) => e != null).map((header) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 22, horizontal: 31),
                    child: Text(
                      "$header",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        // color: Colors.blue,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Table Rows
              ...rows.map((rowData) {
                return TableRow(
                  children: rowData.where((e) => e != null).map((cellData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 31),
                      child: Text(
                        "$cellData",
                        style: TextStyle(
                            fontSize: 16,
                            color: context.theme.colorScheme.onSurfaceVariant),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class FinancialsTabWidget extends StatelessWidget {
  final int index;
  final String title;
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

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

class ShareHolderSlider extends StatelessWidget {
  final ShareHolderModel model;

  const ShareHolderSlider(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          model.name.capitalFirst,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(child: CustomPercentageProgressBar(model.percentage)),
            const SizedBox(width: 7),
            Text(
              "${model.percentage} %",
              style: const TextStyle(fontSize: 18),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),
      width: Get.width,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: CustomCardWidget(
        color: context.theme.scaffoldBackgroundColor,
        radius: 10,
        borderColor: context.theme.colorScheme.outlineVariant,
        child: Table(
          // columnWidths: {
          //   for (var i = 0; i < model.values.first.length; i++)
          //     i: FlexColumnWidth(i == 0 ? 25 : 10),
          // },
          border: TableBorder(
            horizontalInside: BorderSide(
                color: context.theme.disabledColor, strokeAlign: 0.1, width: 1),
          ),
          children: [
            TableRow(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Particulars (cr)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Revenue (Fy23)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "EPS (FY23)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Mcap (06.01.24) ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "P/E (06.01.24)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      e.perticular,
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      "${e.revenue}",
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      "${e.eps}",
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      "${e.marketCap}",
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      e.pe,
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class PromotersWidget extends StatelessWidget {
  final List<PromoterModel> list;

  const PromotersWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      width: Get.width,
      decoration: BoxDecoration(
        color: context.theme.disabledColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: CustomCardWidget(
        color: context.theme.scaffoldBackgroundColor,
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
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Designation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "Experience",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 31),
                  child: const Text(
                    "LinkedIn Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      // color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            // Table Rows
            ...list.map((e) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      e.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      e.designation.toUpperCase(),
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 31),
                    child: Text(
                      e.experience,
                      style: TextStyle(
                          fontSize: 16,
                          color: context.theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Visibility(
                    visible: e.url.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 31),
                      child: IconButton(
                        mouseCursor: SystemMouseCursors.click,
                        onPressed: () {
                          Launcher.launchURL(e.url);
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.linkedin,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CustomTabBarWidget extends StatelessWidget {
  final int index;
  final String text;
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  CustomTabBarWidget({super.key, required this.index, required this.text});

  @override
  Widget build(BuildContext context) => Obx(() {
        final selected = c.tab() == index;
        final colors = context.theme.colorScheme;
        return TextButton(
          onPressed: () {
            c.tab(index);
            c.scrollToSection(index);
          },
          style: TextButton.styleFrom(
            backgroundColor: selected
                ? colors.primaryContainer
                : colors.surfaceContainerHigh,
            foregroundColor:
                selected ? colors.onPrimaryContainer : colors.onSurface,
            side: BorderSide(
                color: colors.outlineVariant),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
        );
      });
}
