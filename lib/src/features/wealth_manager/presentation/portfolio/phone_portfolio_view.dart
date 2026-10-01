import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/pre_ipo_sell_share_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/pre_ipo_sell_share_dialog_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class PhonePortfolioView extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  PhonePortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Visibility(
              visible: !app.wUser.isPreIPOOnly,
              child: TabBar(
                controller: c.tabController,
                splashBorderRadius: BorderRadius.circular(50),
                onTap: (v) => c.changeTab(EquityTypeEnum.values[v]),
                tabs: c.tabs,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchBarTextField(
                          hintText: "Search Startup",
                          onChanged: (p0) => c.search(p0),
                        ),
                      ),
                      SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          showCustomDialog(_PhonePortfolioFilter());
                        },
                        borderRadius: BorderRadius.circular(45),
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.borderColor(context)),
                          ),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: context.theme.dividerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: TabBarView(
                      controller: c.tabController,
                      children: c.tabViews,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _PhonePortfolioFilter extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  _PhonePortfolioFilter();

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: context.width,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleText("Select Investor"),
              IconButton(
                onPressed: Get.back,
                splashRadius: 25,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          // SizedBox(height: 10),
          Divider(),
          SizedBox(height: 6),
          Obx(() {
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: c.investorList.map((InvestorModel investor) {
                return FilterChip(
                  label: Text(investor.name),
                  selected: c.selectedInvestor.contains(investor.id),
                  onSelected: (bool selected) {
                    if (selected) {
                      c.selectedInvestor.add(investor.id);
                    } else {
                      c.selectedInvestor.remove(investor.id);
                    }
                  },
                );
              }).toList(),
            );
          }),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  height: 45,
                  onPressed: () {
                    if (c.selectedInvestor.isEmpty) {
                      Get.back();
                    } else {
                      c.selectedInvestor.clear();
                      c.getStartupPortfolio();
                      Get.back();
                    }
                  },
                  text: "Clear",
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: CustomElevatedButton(
                  height: 45,
                  onPressed: () {
                    Get.back();
                    c.getStartupPortfolio();
                  },
                  text: 'Filter',
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class PreIpoListWidget extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  PreIpoListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        List<PreIPOPortfolioListModel> list = [];
        if (c.isSearching.isFalse) {
          list = c.preIpoList;
        } else {
          list = c.preIpoSearchList;
        }
        if (list.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: c.getStartupPortfolio,
            child: PreIPOPortfolioWidget(
                list: list, onRefresh: c.getStartupPortfolio),
          );
        } else {
          return NoDataView(
            onPressed: c.getStartupPortfolio,
            isRefreshButton: c.isSearching.isTrue ? false : true,
          );
        }
      } else {
        return const Loader();
      }
    });
  }
}

class PreIPOPortfolioWidget extends StatelessWidget {
  final List<PreIPOPortfolioListModel> list;
  final Future<void> Function() onRefresh;

  const PreIPOPortfolioWidget(
      {super.key, required this.list, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Obx(() {
        if (list.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              var model = list[index];
              return ExpansionTile(
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.borderColor(context)),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                textColor: context.textTheme.titleMedium?.color,
                collapsedTextColor: context.textTheme.titleMedium?.color,
                iconColor: context.iconColor,
                collapsedIconColor: context.iconColor,
                collapsedBackgroundColor: context.theme.scaffoldBackgroundColor,
                dense: false,
                tilePadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                backgroundColor: context.theme.scaffoldBackgroundColor,
                visualDensity: VisualDensity.comfortable,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: LogoImage(
                  url: model.investor.profilePhoto,
                  height: 40,
                  width: 40,
                  radius: 20,
                ),
                title: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        model.investor.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Companies :  ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text(
                                "${model.totalCompanyCount}",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Total Investment :  ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text(
                                model.totalInvestmentAmount.toFormattedPrice,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  ...model.holdings.map((e) =>
                      PreIPOPortfolioCard(model: e, onRefresh: onRefresh))
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
          );
        } else {}
        return NoDataView(onPressed: onRefresh);
      }),
    );
  }
}

class PreIPOPortfolioCard extends StatelessWidget {
  final PreIPOPortfolioModel model;
  final Future<void> Function() onRefresh;

  const PreIPOPortfolioCard(
      {super.key, required this.model, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(vertical: 8),
      radius: 20,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: [
          Row(
            // crossAxisAlignment:
            // CrossAxisAlignment.start,
            children: [
              LogoImage(
                radius: 10,
                url: model.company.logo,
                height: 75,
                width: 75,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.company.brandName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.investor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Visibility(
                    visible: model.onSellShares != 0,
                    child: Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${model.onSellShares.toInt()} Share On Sell",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: model.isAvailableShare,
                    child: CustomElevatedButton(
                      onPressed: () async {
                        var res = await showCustomDialog(
                            PreIPOSellShareDialog(model));
                        Get.delete<PreIPOSellShareDialogCtrl>();
                        if (res == true) {
                          onRefresh();
                        }
                      },
                      padding: EdgeInsets.zero,
                      text: 'Sell',
                      size: const Size(65, 35),
                      // width: 187,
                      // height: 44,
                      radius: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Shares",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${model.shares}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Current Share Price",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.currentSharePrice.toCurrency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Avg share price",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.purchasePrice.toCurrency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount Invested", style: context.textTheme.bodySmall),
                  Text(
                    model.investmentAmount.toCurrency,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Increase/Decrease (Amt)", style: context.textTheme.bodySmall),
                  Text(
                    model.profitAmount.toCurrency,
                    style: TextStyle(
                        color: model.profitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       "Purchase Price",
              //       style: context.textTheme.bodySmall,
              //     ),
              //     Text(
              //       model.purchasePrice.toCurrency,
              //       style: const TextStyle(
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Increase/Decrease(%)", style: context.textTheme.bodySmall),
                  Text(
                    model.profitPercentage,
                    style: TextStyle(
                        color: model.profitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ListWidget extends StatelessWidget {
  final RxList<StartupPortfolioListModel> data;

  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  ListWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        List<StartupPortfolioListModel> list = [];
        if (c.isSearching.isFalse) {
          list = data;
        } else {
          list = c.searchList;
        }
        if (list.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: c.getStartupPortfolio,
            child: StartUpPortfolioWidget(
                list: list, onRefresh: c.getStartupPortfolio),
          );
        } else {
          return NoDataView(
            onPressed: c.getStartupPortfolio,
            isRefreshButton: c.isSearching.isTrue ? false : true,
          );
        }
      } else {
        return const Loader();
      }
    });
  }
}

class StartUpPortfolioWidget extends StatelessWidget {
  final List<StartupPortfolioListModel> list;
  final Future<void> Function() onRefresh;

  const StartUpPortfolioWidget(
      {super.key, required this.list, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Obx(() {
        if (list.isNotEmpty) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            physics: const BouncingScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              var model = list[index];
              return ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.borderColor(context)),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.borderColor(context)),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                textColor: context.textTheme.titleMedium?.color,
                collapsedTextColor: context.textTheme.titleMedium?.color,
                iconColor: context.iconColor,
                collapsedIconColor: context.iconColor,
                collapsedBackgroundColor: context.theme.scaffoldBackgroundColor,
                dense: false,
                tilePadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                backgroundColor: context.theme.scaffoldBackgroundColor,
                visualDensity: VisualDensity.comfortable,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: LogoImage(
                  url: model.investor.profilePhoto,
                  height: 40,
                  width: 40,
                  radius: 20,
                ),
                title: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        model.investor.name.capitalFirst,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Companies :  ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text(
                                "${model.totalCompanyCount}",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Total Investment :  ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text(
                                model.totalInvestmentAmount.toFormattedPrice,
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  ...model.holdings.map((e) =>
                      StartupPortfolioCard(model: e, onRefresh: onRefresh))
                ],
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
          );
        } else {}
        return NoDataView(onPressed: onRefresh);
      }),
    );
  }
}

class StartupPortfolioCard extends StatelessWidget {
  final PortfolioModel model;
  final Future<void> Function() onRefresh;

  const StartupPortfolioCard(
      {super.key, required this.model, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(vertical: 8),
      radius: 20,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          Row(
            // crossAxisAlignment:
            // CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: LogoImage(
                  radius: 10,
                  url: model.startup.cms.logo,
                  height: 75,
                  width: 75,
                  onTap: () {
                    Get.toNamed(Routes.primaryDetailPage,
                        arguments: model.startupId);
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.startup.brandName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.investor.name.capitalFirst,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Visibility(
                          visible: model.isPrimaryTransaction,
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white.withValues(alpha: 0.4),
                              border: Border.all(color: Colors.white),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 5),
                            alignment: Alignment.center,
                            child: Text("Primary", style: context.textTheme.bodySmall),
                          ),
                        ),
                        Visibility(
                          visible: model.isSecondaryTransaction,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: context.isDarkMode
                                  ? context.theme.disabledColor
                                      .withValues(alpha: 0.4)
                                  : null,
                              border: Border.all(
                                  color: context.theme.disabledColor),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 5),
                            alignment: Alignment.center,
                            child: Text("Lp Secondary", style: context.textTheme.bodySmall),
                          ),
                        ),
                      ],
                    ),

                    // Text(
                    //   model.name,
                    //   style: TextStyle(
                    //       color: context.theme.colorScheme.onSurfaceVariant,
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 12),
                    // ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Visibility(
                    visible: model.onSellShares != 0,
                    child: Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${model.onSellShares.toInt()} Share On Sell",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: model.canSell,
                    child: CustomElevatedButton(
                      onPressed: () async {
                        var res = await showCustomDialog(
                            PrimarySellShareDialog(model));
                        Get.delete<PrimarySellShareDialogCtrl>();
                        if (res == true) {
                          onRefresh();
                        }
                      },
                      padding: EdgeInsets.zero,
                      text: 'Sell',
                      size: const Size(65, 35),
                      // width: 187,
                      // height: 44,
                      radius: 8,
                    ),
                  ),
                ],
              ),

              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: [
              //     Row(
              //       children: [
              //         Container(
              //           height: 10,
              //           width: 10,
              //           decoration: const BoxDecoration(
              //             color: Colors.green,
              //             shape: BoxShape.circle,
              //           ),
              //         ),
              //         const SizedBox(width: 5),
              //         Text(
              //           "On Sell",
              //           style: TextStyle(
              //             fontSize: 10,
              //             fontWeight: FontWeight.w600,
              //             color: context.theme.colorScheme.onSurfaceVariant,
              //           ),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(height: 6),
              //     // Visibility(
              //     //   visible: model.canSell,
              //     //   child: CustomElevatedButton(
              //     //     onPressed: () async {
              //     //       var res = await showCustomDialog(
              //     //           SellShareDialog(model));
              //     //       Get.delete<SellShareDialogCtrl>();
              //     //       if (res == true) {
              //     //         c.getData();
              //     //       }
              //     //
              //     //       // showCustomDialog(TransactionSlipDialog());
              //     //     },
              //     //     padding: EdgeInsets.zero,
              //     //     text: 'Sell',
              //     //     size: const Size(65, 35),
              //     //     // width: 187,
              //     //     // height: 44,
              //     //     radius: 8,
              //     //   ),
              //     // ),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Shares",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${model.availableShares}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Current Share Price",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.currentSharePrice.toCurrency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Avg share price",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.purchasePrice.toCurrency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Amount Invested", style: context.textTheme.bodySmall),
                  Text(
                    model.investmentAmount.toCurrency,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Increase/Decrease (Amt)", style: context.textTheme.bodySmall),
                  Text(
                    model.profitAmount.toCurrency,
                    style: TextStyle(
                        color: model.profitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       "Purchase Price",
              //       style: context.textTheme.bodySmall,
              //     ),
              //     Text(
              //       model.purchasePrice.toCurrency,
              //       style: const TextStyle(
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Increase/Decrease(%)", style: context.textTheme.bodySmall),
                  Text(
                    model.profitPercentage,
                    style: TextStyle(
                        color: model.profitColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabText extends StatelessWidget {
  TabText({
    super.key,
    required this.title,
    required this.type,
  });

  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  final String title;
  final EquityTypeEnum type;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = c.currentIndex() == type;
      return InkWell(
        onTap: () {
          c.currentIndex(type);
          c.getStartupPortfolio();
          c.isSearching(false);
          c.searchList.clear();
          c.controller.clear();
        },
        borderRadius: BorderRadius.circular(11),
        child: Container(
          // margin: EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: isSelected
                ? context.theme.primaryColor.withValues(alpha: 0.4)
                : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              fontSize: isSelected ? 13 : 12,
              color:
                  // isSelected
                  //     ? context.theme.primaryColor
                  //     :
                  context.isDarkMode ? Colors.white : context.theme.shadowColor,
            ),
          ),
        ),
      );
    });
  }
}
