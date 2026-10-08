import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';

import 'unlisted_portfolio_view.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class DesktopPortfolioView extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  DesktopPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const TitleText("Portfolio"),
                const Spacer(),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: TabButton(
                    title: "Unlisted",
                    type: EquityTypeEnum.preIpo,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.preIpo);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: "Equity",
                    type: EquityTypeEnum.equity,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.equity);
                    },
                    currentIndex: c.currentIndex,
                    // size: context,
                  ),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: "CCPS",
                    type: EquityTypeEnum.ccps,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.ccps);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: "CCD",
                    type: EquityTypeEnum.ccd,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.ccd);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
              ],
            ),
            Visibility(
              visible: app.wUser.isPreIpoAccess,
              child: const SizedBox(height: 10),
            ),
            const SizedBox(height: 8),
            Obx(
              () => c.currentIndex() == EquityTypeEnum.preIpo
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return SearchBarTextField(
                              onChanged: (p0) => c.search(p0),
                              hintText:
                                  c.currentIndex() == EquityTypeEnum.preIpo
                                  ? "Search company's"
                                  : null,
                            );
                          }),
                        ),
                        SizedBox(width: 6),
                        Obx(() {
                          return Visibility(
                            visible:
                                c.currentIndex.value != EquityTypeEnum.preIpo,
                            child: InkWell(
                              mouseCursor: SystemMouseCursors.click,
                              onTap: () {
                                showCustomDialog(PortfolioFilterWidget());
                              },
                              borderRadius: BorderRadius.circular(45),
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderColor(context),
                                  ),
                                ),
                                child: Icon(
                                  Icons.filter_alt_outlined,
                                  color: context.theme.dividerColor,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isFalse) {
                  if (c.currentIndex() == EquityTypeEnum.preIpo) {
                    return UnlistedPortfolioView(
                      list: c.preIpoList.toList(),
                      onRefresh: c.getStartupPortfolio,
                    );
                  } else {
                    if (c.startUpList.isNotEmpty) {
                      return StartUpPortfolioWidget(
                        onRefresh: c.getStartupPortfolio,
                        list: c.startUpList,
                      );
                    } else {
                      return NoDataView(
                        onPressed: c.getStartupPortfolio,
                        isRefreshButton: c.isSearching.isTrue ? false : true,
                      );
                    }
                  }
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

class PortfolioFilterWidget extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  PortfolioFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 550,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TitleText("Filter"),
              IconButton(
                onPressed: Get.back,
                splashRadius: 25,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          // SizedBox(height: 10),
          Divider(),
          SizedBox(height: 20),
          Text("Select Investor", style: context.textTheme.titleLarge),
          SizedBox(height: 10),
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
          Text("Select Startup", style: context.textTheme.titleLarge),
          SizedBox(height: 10),
          Obx(() {
            return Wrap(
              spacing: 4,
              runSpacing: 4,
              children: c.startupList.map((StartupLiteModel startup) {
                return FilterChip(
                  label: Text(startup.brandName),
                  selected: c.selectedStartup.contains(startup.id),
                  onSelected: (bool selected) {
                    if (selected) {
                      c.selectedStartup.add(startup.id);
                    } else {
                      c.selectedStartup.remove(startup.id);
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
                    if (c.selectedInvestor.isEmpty &&
                        c.selectedStartup.isEmpty) {
                      Get.back();
                    } else {
                      c.selectedInvestor.clear();
                      c.selectedStartup.clear();
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

class StartUpPortfolioWidget extends StatelessWidget {
  final List<StartupPortfolioListModel> list;
  final Future<void> Function() onRefresh;

  const StartUpPortfolioWidget({
    super.key,
    required this.list,
    required this.onRefresh,
  });

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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.borderColor(context)),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.borderColor(context)),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                textColor: context.textTheme.titleMedium?.color,
                collapsedTextColor: context.textTheme.titleMedium?.color,
                iconColor: context.iconColor,
                collapsedIconColor: context.iconColor,
                collapsedBackgroundColor: context.theme.scaffoldBackgroundColor,
                dense: false,
                tilePadding: const EdgeInsets.fromLTRB(20, 20, 40, 20),
                backgroundColor: context.theme.scaffoldBackgroundColor,
                visualDensity: VisualDensity.comfortable,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                leading: LogoImage(
                  url: model.investor.profilePhoto,
                  height: 50,
                  width: 50,
                  radius: 25, // circular for a profile photo
                ),
                title: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        model.investor.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Companies :  ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text("${model.totalCompanyCount}"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Total Investment :  ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.theme.disabledColor,
                                ),
                              ),
                              Text(model.totalInvestmentAmount.toCurrency),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  ...model.holdings.map(
                    (e) => StartUpPortfolioCard(model: e, onRefresh: onRefresh),
                  ),
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

class StartUpPortfolioCard extends StatelessWidget {
  final PortfolioModel model;
  final Future<void> Function() onRefresh;

  const StartUpPortfolioCard({
    super.key,
    required this.model,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      margin: const EdgeInsets.symmetric(vertical: 13),
      radius: 20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(37, 6, 37, 38),
        child: Column(
          children: [
            Row(
              children: [
                LogoImage(
                  url: model.startup.cms.logo,
                  height: 75,
                  width: 75,
                  radius: 4,
                  onTap: () {
                    Get.toNamed(
                      Routes.primaryDetailPage,
                      arguments: model.startupId,
                    );
                  },
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.startup.brandName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    // SizedBox(height: 2),
                    Text(
                      model.investor.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
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
                              color: context.isDarkMode
                                  ? context.theme.disabledColor.withValues(
                                      alpha: 0.4,
                                    )
                                  : null,
                              border: Border.all(color: Colors.white),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 5,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Private Equity",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: model.isSecondaryTransaction,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: context.isDarkMode
                                  ? context.theme.disabledColor.withValues(
                                      alpha: 0.4,
                                    )
                                  : null,
                              border: Border.all(
                                color: context.theme.disabledColor,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 5,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Lp Secondary",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Visibility(
                      visible: model.onSellShares != 0,
                      child: Row(
                        children: [
                          Container(
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${model.onSellShares.toInt()} Share On Sell",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Visibility(
                      visible: model.canSell,
                      child: !model.investor.isPreIpoKycComplete
                          ? CompleteInvestorKycButton(
                              investor: model.investor,
                              onSaved: () async {
                                await onRefresh();
                              },
                            )
                          : CustomElevatedButton(
                              onPressed: () async {
                                var res = await showCustomDialog(
                                  PrimarySellShareDialog(model),
                                );
                                Get.delete<PrimarySellShareDialogCtrl>();
                                if (res == true) onRefresh();
                              },
                              text: 'Sell',
                              size: const Size(150, 44),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              // width: 187,
                              // height: 44,
                              radius: 14,
                            ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 23),
            CustomCardWidget(
              radius: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 29),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Shares",
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          model.availableShares.formattedDecimal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Current Share Price",
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          model.currentSharePrice.toCurrency,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Avg share price",
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.disabledColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          child: Text(
                            model.purchasePrice.toCurrency,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 13),
            CustomCardWidget(
              radius: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 16, 33, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount Invested",
                          style: TextStyle(
                            color: context.theme.disabledColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          model.investmentAmount.toCurrency,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Increase/Decrease (Amt)",
                          style: TextStyle(
                            color: context.theme.disabledColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          model.profitAmount.toCurrency,
                          style: TextStyle(
                            fontSize: 18,
                            color: model.profitColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Increase/Decrease(%)",
                          style: TextStyle(
                            color: context.theme.disabledColor,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          model.profitPercentage,
                          style: TextStyle(
                            fontSize: 18,
                            color: model.profitColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
