import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/investor_filter_dialog.dart';

class DesktopInvestorsView extends StatelessWidget {
  final InvestorsPageCtrl c = Get.find<InvestorsPageCtrl>();

  DesktopInvestorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const TitleText("Investors"),
                  const Spacer(),
                  CustomOutlinedButton(
                    color: context.theme.iconTheme.color,
                    width: 100,
                    height: 45,
                    onPressed: () {
                      showCustomDialog(const InvestorFilterDialog());
                    },
                    child: const Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  CustomElevatedButton(
                    width: 100,
                    height: 45,
                    onPressed: () {
                      Get.toNamed(Routes.addInvestorPath(Get.currentRoute));
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // TabText(
                  //   title: "Equity Portfolio",
                  //   type: EquityTypeEnum.equity,
                  //   // size: context,
                  // ),
                  // TabText(
                  //   title: "CCPS Portfolio",
                  //   type: EquityTypeEnum.ccps,
                  //   // size: context,
                  //   // size: context,
                  // ),
                  // TabText(
                  //   title: "CCD Portfolio",
                  //   type: EquityTypeEnum.ccd,
                  //   // size: context,
                  // ),
                ],
              ),
              const SizedBox(height: 18),
              SearchBarTextField(
                onChanged: (p0) => c.search(p0),
                hintText: 'Search investor name',
              ),
              Expanded(
                child: Obx(() {
                  if (c.isLoading.isFalse) {
                    if (c.finalList.isNotEmpty) {
                      return RefreshIndicator(
                        onRefresh: c.getInvestorList,
                        child: ListView.builder(
                          itemCount: c.finalList.length,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          itemBuilder: (context, index) {
                            var model = c.finalList[index];
                            return CustomCardWidget(
                              radius: 20,
                              margin: const EdgeInsets.symmetric(vertical: 13),
                              padding: const EdgeInsets.fromLTRB(37, 5, 37, 38),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      // const SizedBox(width: 15),
                                      Text(
                                        model.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(onPressed: () => Get.toNamed('/investors/${model.id}/cml'), child: const Text('CML')),
                                      TextButton(
                                        onPressed: () {
                                          var portfolioCtrl =
                                              Get.find<PortfolioPageCtrl>();
                                          var homeCtrl =
                                              Get.find<HomePageCtrl>();
                                          homeCtrl.currentTab(
                                            WTabBarEnum.portfolio,
                                          );
                                          portfolioCtrl.selectedInvestor.add(
                                            model.id,
                                          );
                                          portfolioCtrl.getStartupPortfolio();
                                        },
                                        child: Text(
                                          "View Portfolio",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      // CustomElevatedButton(
                                      //   onPressed: () {},
                                      //   text: 'More',
                                      //   size: const Size(187, 50),
                                      //   style: const TextStyle(
                                      //       fontSize: 18,
                                      //       fontWeight: FontWeight.w600),
                                      //   radius: 14,
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 23),
                                  CustomCardWidget(
                                    margin: EdgeInsets.zero,
                                    radius: 6,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 29,
                                      horizontal: 40,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 300,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                "Total Invested",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context
                                                      .theme
                                                      .disabledColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "${model.totalInvested.toFormattedPrice}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  "No. of Startups",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: context
                                                        .theme
                                                        .disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${model.noOfStartups}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 300,
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            children: [
                                              Text(
                                                "Commission Earned",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context
                                                      .theme
                                                      .disabledColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "${model.commissionEarned.toFormattedPrice}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  CustomCardWidget(
                                    margin: EdgeInsets.zero,
                                    radius: 6,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 29,
                                      horizontal: 40,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 300,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            children: [
                                              Text(
                                                "City",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context
                                                      .theme
                                                      .disabledColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "${model.city.name}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Mobile",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: context
                                                        .theme
                                                        .disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "${model.mobileNumber}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 300,
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            children: [
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context
                                                      .theme
                                                      .disabledColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "${model.email}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: model.startupList.isNotEmpty,
                                    child: const SizedBox(height: 13),
                                  ),
                                  Visibility(
                                    visible: model.startupList.isNotEmpty,
                                    child: CustomCardWidget(
                                      margin: EdgeInsets.zero,
                                      radius: 6,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                "Startup Name",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Expanded(
                                                child: Center(
                                                  child: Text(
                                                    "Amount Invested",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "Commission Earned",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: model.startupList.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              var startup =
                                                  model.startupList[index];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 7,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Container(
                                                      width: 220,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        startup.brandName,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: context
                                                              .theme
                                                              .disabledColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                          "${startup.amountInvested.toFormattedPrice}",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: context
                                                                .theme
                                                                .disabledColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 220,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "${startup.commissionEarned.toFormattedPrice}",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: context
                                                              .theme
                                                              .disabledColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),

                                          // const SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return NoDataView(
                        onPressed: c.getInvestorList,
                        isRefreshButton: c.isSearching.isTrue ? false : true,
                      );
                    }
                  } else {
                    return const Loader();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
