import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page_ctrl.dart';

class PhonePrimaryDetailView extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  PhonePrimaryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.isFalse) {
            return SingleChildScrollView(
              controller: c.parentController,
              physics: c.isParentScrolling.isTrue
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      CacheImage(
                        url: c.model.cms.banner,
                        fit: BoxFit.fitWidth,
                        width: context.width,
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: InkWell(
                          onTap: onBackPressed,
                          borderRadius: BorderRadius.circular(63),
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  context.theme.dividerColor.withValues(alpha: 0.5),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: context.theme.scaffoldBackgroundColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LogoImage(
                              height: 60,
                              width: 60,
                              url: c.model.cms.logo,
                              radius: 8,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.model.brandName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    c.model.cms.oneLiner,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: context.width,
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Startup Highlights",
                                style: TextStyle(
                                  color: context.theme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                c.model.cms.highlights,
                                style: const TextStyle(fontSize: 13),
                              )
                            ],
                          ),
                        ),
                        // SizedBox(height: 35),
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10)),
                              color: context.theme.scaffoldBackgroundColor,
                              border: Border.all(
                                  color: context.theme.dividerColor
                                      .withValues(alpha: 0.2)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 23),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Startup Overview",
                                      style: TextStyle(
                                        color: context.theme.primaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Location',
                                      subTitle: c.model.city.name.capitalFirst,
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Social Media',
                                      alignment: Alignment.centerLeft,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: c.model.socialMediaLinks
                                              .map(
                                                (e) => e.icon != null
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              Launcher
                                                                  .launchURL(
                                                                      e.link);
                                                            },
                                                            child:
                                                                FaIcon(e.icon)),
                                                      )
                                                    : const SizedBox(),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'website',
                                      subTitle: c.model.cms.website.naString,
                                      isUrl: true,
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Company Number',
                                      subTitle: c.model.legalInfo.cin.naString,
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Incorporation date',
                                      subTitle: c
                                          .model
                                          .legalInfo
                                          .incorporationDate
                                          .dateWithSortMonthYear,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 40),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Investment Summary",
                                      style: TextStyle(
                                        color: context.theme.primaryColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Type',
                                      subTitle: c.model.raisingRound.instrument
                                          .instrumentName,
                                    ),
                                    const SizedBox(height: 30),
                                    Visibility(
                                      visible: !c.model.isEquity,
                                      child: DetailWidget(
                                        title: 'Floor',
                                        subTitle: c.model.raisingRound.floor
                                            .toFormattedPrice,
                                      ),
                                    ),
                                    Visibility(
                                        visible: !c.model.isEquity,
                                        child: const SizedBox(height: 30)),
                                    Visibility(
                                      visible: !c.model.isEquity,
                                      child: DetailWidget(
                                        title: 'Cap',
                                        subTitle: c.model.raisingRound.cap
                                            .toFormattedPrice,
                                      ),
                                    ),
                                    Visibility(
                                        visible: !c.model.isEquity,
                                        child: const SizedBox(height: 30)),
                                    Visibility(
                                      visible: c.model.isEquity,
                                      child: DetailWidget(
                                        title: 'Valuation',
                                        subTitle: c.model.raisingRound.floor
                                            .toFormattedPrice,
                                      ),
                                    ),
                                    Visibility(
                                        visible: c.model.isEquity,
                                        child: const SizedBox(height: 30)),
                                    DetailWidget(
                                      title: 'Equity Offered',
                                      subTitle:
                                          "${c.model.raisingRound.equityOffered}%",
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Private Deals Round Size',
                                      subTitle: c.model.raisingRound
                                          .fundRequirement.toFormattedPrice,
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Total Round Size',
                                      subTitle: c
                                          .model
                                          .raisingRound
                                          .totalFundRequirement
                                          .toFormattedPrice,
                                    ),
                                    const SizedBox(height: 30),
                                    DetailWidget(
                                      title: 'Share price',
                                      subTitle: c.model.raisingRound.sharePrice
                                          .toCurrency,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        Visibility(
                          visible: c.model.isActiveRound ,
                          child: const SizedBox(height: 45),
                        ),
                        Visibility(
                          visible: c.model.isActiveRound ,
                          child: Center(
                            child: CustomElevatedButton(
                              size: const Size(150, 40),
                              radius: 16,
                              fontSize: 14,
                              onPressed: () async {
                                var res = await showCustomDialog(
                                    InvestorListDialog());
                                Get.delete<InvestorListDialogCtrl>();
                                if (res is InvestorModel) {
                                  var route = Routes.primaryInvestmentPath(
                                      Get.currentRoute, res.uuid);
                                  logger.d(route);
                                  var data = await Get.toNamed(route);
                                  if (data == true) {
                                    c.getData();
                                  }
                                }
                              },
                              text: 'Invest Now',
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Visibility(
                        //   visible: app.fromSecondary,
                        //   child: MarketWidget(),
                        // ),
                        // Visibility(
                        //   visible: app.fromSecondary,
                        //   child: const SizedBox(height: 40),
                        // ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: context.theme.dividerColor
                                    .withValues(alpha: 0.2)),
                          ),
                          child: SingleChildScrollView(
                            controller: c.scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Visibility(
                                //   visible: c.fromSecondary,
                                //   child: CustomTabBarButton(
                                //     tab: StartupDetailEnum.market,
                                //     title: "Market",
                                //   ),
                                // ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.idea,
                                  title: "Idea",
                                ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.keyInfo,
                                  title: "Key Information",
                                ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.team,
                                  title: "Team",
                                ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.updates,
                                  title: "Updates",
                                ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.investor,
                                  title: "Investor",
                                ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.faq,
                                  title: "FAQ’s",
                                ),
                                // CustomTabBarButton(
                                //   tab: StartupDetailEnum.meet,
                                //   title: "Shuru-meet",
                                // ),
                                CustomTabBarButton(
                                  tab: StartupDetailEnum.documents,
                                  title: "Documents",
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomTabBarView(),
                        /* TabBarView(children: [
                          Column(
                            children: [
                              Visibility(
                                visible: c.model.startup.startupPitchVideo
                                    .isNotEmpty,
                                child: CustomVideoPlayer(
                                    url: c.model.startup.startupPitchVideo),
                              ),
                              Html(data: c.model.other.infocontent),
                            ],
                          ),
                          Html(data: c.model.other.keyinformation),
                          TeamWidget(),
                          UpdatesWidget(),
                          FAQWidget(),
                          Container(),
                          DocumentWidget(),
                        ]),*/
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Loader();
          }
        }),
      ),
    );
  }
}
