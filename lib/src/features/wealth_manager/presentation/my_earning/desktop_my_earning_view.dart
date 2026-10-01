import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/desktop_dashboard_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/my_earning/my_earning_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class DesktopMyEarningView extends StatelessWidget {
  final MyEarningPageCtrl c = Get.put(MyEarningPageCtrl());

  DesktopMyEarningView({super.key});

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
                const TitleText("My Earning"),
                const Spacer(),
                TabText(
                  title: "From Investors",
                  type: MyEarningTypeEnum.investor,
                  // size: context,
                ),
                TabText(
                  title: "From Channel Partner",
                  type: MyEarningTypeEnum.channelPartner,
                  // size: context,
                  // size: context,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: MainView()),
          ],
        ),
      ),
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
            return _InvestorWidget();
          case MyEarningTypeEnum.channelPartner:
            return _ChannelPartnerWidget();
        }
      },
    );
  }
}

class _ChannelPartnerWidget extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  _ChannelPartnerWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DCardWidget(
                  title: 'Total Investors',
                  subTitle: "${c.partner().totalPartners}",
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DCardWidget(
                  title: 'Amount Invested',
                  subTitle: c.partner().totalInvestment.toFormattedPrice,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DCardWidget(
                  title: 'Commission Earned',
                  subTitle:
                      c.partner().totalCommissionEarned.toFormattedPrice,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 8),
        Expanded(
          child: CustomCardWidget(
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Center(child: HeadingText("No")),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: HeadingText("Partners")),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: HeadingText("Amount Invested")),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: HeadingText("Commission Earned")),
                      ),

                      // Expanded(
                      //     child: Center(child: HeadingText("Action"))),
                    ],
                  ),
                ),
                Divider(
                  color: context.theme.disabledColor.withValues(alpha: 0.2),
                  thickness: 0.7,
                  height: 1,
                ),
                Expanded(
                  child: Obx(() {
                    if (c.isLoading.isFalse) {
                      if (c.partner().list.isNotEmpty) {
                        return ListView.builder(
                          itemCount: c.partner().list.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          itemBuilder: (context, index) {
                            var model = c.partner().list[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        model.name,
                                        style: TextStyle(
                                            color: context.theme.disabledColor),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        // model.startup.amount.toFormattedPrice,
                                        model.partnerTotalInvestment.toFormattedPrice,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        model.commissionEarnedFromThisPartner.toFormattedPrice,
                                        style: const TextStyle(
                                            // color: model.statusReturnOfInvest,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {}
                      return const NoDataView();
                    } else {
                      return const Loader();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InvestorWidget extends StatelessWidget {
  final MyEarningPageCtrl c = Get.find<MyEarningPageCtrl>();

  _InvestorWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DCardWidget(
                  title: 'Total Investors',
                  subTitle: "${c.investor().totalInvestors}",
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DCardWidget(
                  title: 'Amount Invested',
                  subTitle: c.investor().totalInvestment.toFormattedPrice,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DCardWidget(
                  title: 'Commission Earned',
                  subTitle: c.investor().commissionEarned.toFormattedPrice,
                ),
              ),
              const SizedBox(width: 6),
              // Expanded(
              //   child: DCardWidget(
              //     title: 'Percentage Commission Earned',
              //     subTitle: "₹68.24L",
              //   ),
              // ),
            ],
          );
        }),
        const SizedBox(height: 8),
        Expanded(
          child: CustomCardWidget(
            radius: 20,
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(child: HeadingText("No")),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: HeadingText("Investor")),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: HeadingText("Amount Invested")),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(child: HeadingText("Commission Earned")),
                      ),
                      // Expanded(
                      //   flex: 3,
                      //   child: Center(
                      //       child: HeadingText("Percentage commission earned")),
                      // ),
                      // Expanded(
                      //     child: Center(child: HeadingText("Action"))),
                    ],
                  ),
                ),
                Divider(
                  color: context.theme.disabledColor.withValues(alpha: 0.2),
                  thickness: 0.7,
                  height: 1,
                ),
                Expanded(
                  child: Obx(() {
                    if (c.isLoading.isFalse) {
                      if (c.investor().investorsList.isNotEmpty) {
                        return ListView.builder(
                          itemCount: c.investor().investorsList.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 10),
                          itemBuilder: (context, index) {
                            var model = c.investor().investorsList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        model.name,
                                        style: TextStyle(
                                            color: context.theme.disabledColor),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        model.totalInvestment.toFormattedPrice,
                                        style: const TextStyle(),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Center(
                                      child: Text(
                                        model.commissionEarned.toFormattedPrice,
                                        style: const TextStyle(
                                            // color: model.statusReturnOfInvest,
                                            ),
                                      ),
                                    ),
                                  ),
                                  // Expanded(
                                  //   flex: 3,
                                  //   child: Center(
                                  //     child: Text(
                                  //       "",
                                  //       style: TextStyle(),
                                  //     ),
                                  //   ),
                                  // ),
                                  /*
                                      Expanded(
                                        child: PopupMenuButton<String>(
                                          splashRadius: 20,
                                          icon: const SVGImage(
                                            AppAssets.downloadIc,
                                            height: 18,
                                            width: 18,
                                          ),
                                          onSelected: (String result) async {
                                            switch (result) {
                                              case 'SSA':
                                                await DownloadFile
                                                    .downloadFromUrl(
                                                        url: model.ssa);
                                                break;
                                              case 'Offer':
                                                await DownloadFile
                                                    .downloadFromUrl(
                                                        url:
                                                            model.offerlater);
                                                break;
                                              case 'SHA':
                                                await DownloadFile
                                                    .downloadFromUrl(
                                                        url: model.sha);
                                                break;
                                            }
                                          },
                                          itemBuilder:
                                              (BuildContext context) =>
                                                  <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'SSA',
                                              child: Text('SSA'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'Offer',
                                              child: Text('Offer'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'SHA',
                                              child: Text('SHA'),
                                            ),
                                          ],
                                        ),

                                        // child: IconButton(
                                        //   splashRadius: 25,
                                        //   onPressed: () {},
                                        //   icon: SVGImage(
                                        //     AppAssets.downloadIc,
                                        //   ),
                                        // ),
                                      ),
            */
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const NoDataView();
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
      ],
    );
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
