import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/info_card.dart';

class PhoneMyEarningView extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  PhoneMyEarningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // SizedBox(height: 10),
          CustomCardWidget(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: Center(
                        child: TabText(
                            title: "Investor",
                            type: MyEarningTypeEnum.investor))),
                Expanded(
                  child: Center(
                    child: TabText(
                        title: "Channel Partner",
                        type: MyEarningTypeEnum.channelPartner),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: MainView()),
        ],
    );
  }
}

class MainView extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        switch (c.currentIndex()) {
          case MyEarningTypeEnum.investor:
            return InvestorWidget();
          case MyEarningTypeEnum.channelPartner:
            return ChannelPartnerWidget();
        }
      },
    );
  }
}

class InvestorWidget extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  InvestorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        if (c.investor().investorsList.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: c.investorData,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Obx(() {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16, right: 6),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          InfoCard(
                            title: 'Total Investors',
                            data: "${c.investor().totalInvestors}",
                          ),
                          InfoCard(
                            title: 'Amount Invested',
                            data:
                                "${c.investor().totalInvestment.toFormattedPrice}",
                          ),
                          InfoCard(
                            title: 'Commission Earned',
                            data:
                                "${c.investor().commissionEarned.toFormattedPrice}",
                          ),
                          // InfoCard(
                          //     title: 'Percentage Commission Earned',
                          //     data: '2.50%'),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  ListView.separated(
                    itemCount: c.investor().investorsList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var model = c.investor().investorsList[index];
                      return CustomCardWidget(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount Invested'),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${model.totalInvestment.toFormattedPrice}",
                                        // "₹1.05Cr",
                                        style: TextStyle(
                                            color: context.theme.disabledColor,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Commission Earned'),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${model.commissionEarned.toFormattedPrice}",
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 10),
                            // Text("Percentage commission earned"),
                            // SizedBox(height: 5),
                            // Text(
                            //   "₹14.35L",
                            //   style: TextStyle(
                            //       color: context.theme.disabledColor,
                            //       fontSize: 12),
                            // ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const NoDataView();
        }
      } else {
        return const Loader();
      }
    });
  }
}

class ChannelPartnerWidget extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  ChannelPartnerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        if (c.partner().list.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: c.channelPartnerData,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 6),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        InfoCard(
                          title: 'Total Investors',
                          data: "${c.partner().totalPartners}",
                        ),
                        InfoCard(
                          title: 'Amount Invested',
                          data:
                              "${c.partner().totalInvestment.toFormattedPrice}",
                        ),
                        InfoCard(
                          title: 'Commission Earned',
                          data:
                              "${c.partner().totalCommissionEarned.toFormattedPrice}",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: c.partner().list.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      var model = c.partner().list[index];
                      return CustomCardWidget(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Amount Invested'),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${model.partnerTotalInvestment.toFormattedPrice}",
                                        // "₹1.05Cr",
                                        style: TextStyle(
                                            color: context.theme.disabledColor,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Commission Earned'),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${model.commissionEarnedFromThisPartner.toFormattedPrice}",
                                        style: const TextStyle(
                                            color: Colors.green, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Text("Percentage commission earned"),
                            // SizedBox(height: 5),
                            // Text(
                            //   "₹14.35L",
                            //   style: TextStyle(
                            //       color: context.theme.disabledColor, fontSize: 12),
                            // ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        } else {
          return const NoDataView();
        }
      } else {
        return const Loader();
      }
    });
  }
}

class TabText extends StatelessWidget {
  TabText({super.key, required this.title, required this.type});

  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();
  final String title;
  final MyEarningTypeEnum type;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: TabButton<MyEarningTypeEnum>(
      title: title,
      type: type,
      currentIndex: c.currentIndex,
      onTap: () {
        c.currentIndex(type);
        switch (type) {
          case MyEarningTypeEnum.investor:
            c.investorData();
            break;
          case MyEarningTypeEnum.channelPartner:
            c.channelPartnerData();
            break;
        }
      },
    ),
  );
}
