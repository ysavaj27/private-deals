import 'package:flutter_html/flutter_html.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page_ctrl.dart';

class DesktopPrimaryDetailView extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  DesktopPrimaryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        // backgroundColor: context.theme.scaffoldBackgroundColor,
        body: NestedScrollView(
          // controller: scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              floating: true,
              title: Obx(() {
                return Text(c.model.brandName);
              }),
              leading: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Clickable(
                    onTap: onBackPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            context.theme.dividerColor.withValues(alpha: 0.5),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: context.theme.scaffoldBackgroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: HeaderDetails()),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  physics: const BouncingScrollPhysics(),
                  // tabAlignment: TabAlignment.s,
                  controller: c.tabController,
                  // isScrollable: true,
                  // padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: "Idea"),
                    Tab(text: "Key Information"),
                    Tab(text: "Teams"),
                    Tab(text: "Updates"),
                    Tab(text: "Investors"),
                    Tab(text: "FAQ"),
                    Tab(text: "Documents"),
                    // Tab(text: "Social Media"),
                  ],
                ),
              ),
            ),
          ],
          body: Obx(() {
            if (c.isLoading.isFalse) {
              return TabBarView(
                controller: c.tabController,
                children: [
                  _IdeaWidget(),
                  _KeyInformationWidget(),
                  _TeamWidget(),
                  _UpdatesWidget(),
                  _InvestorWidget(),
                  _FAQWidget(),
                  _DocumentWidget(),
                  // SocialMediaWidget(),
                ],
              );
            } else {
              return Loader();
            }
          }),
        ),
      ),
    );
  }
}

class HeaderDetails extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  HeaderDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: CacheImage(
                url: c.model.cms.longBanner,
                fit: BoxFit.fitWidth,
                width: context.width,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LogoImage(
                        height: 112,
                        width: 112,
                        url: c.model.cms.logo,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.model.brandName,
                              maxLines: 3,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.model.cms.oneLiner,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: context.width,
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 30),
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
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Obx(() {
                          return Text(c.model.briefInformation);
                        })
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      color: context.theme.scaffoldBackgroundColor,
                      border: Border.all(
                          color: context.theme.dividerColor
                              .withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 26, vertical: 23),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Startup Overview",
                                style: TextStyle(
                                  color: context.theme.primaryColor,
                                  fontSize: 24,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: c.model.socialMediaLinks
                                      .map(
                                        (e) => e.icon != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15),
                                                child: Clickable(
                                                    onTap: () {
                                                      Launcher.launchURL(
                                                          e.link);
                                                    },
                                                    child: FaIcon(e.icon,
                                                        size: 30)),
                                              )
                                            : const SizedBox(),
                                      )
                                      .toList(),
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
                                subTitle: c.model.legalInfo.incorporationDate
                                    .dateWithSortMonthYear,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Investment Summary",
                                style: TextStyle(
                                  color: context.theme.primaryColor,
                                  fontSize: 24,
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
                                  subTitle:
                                      c.model.raisingRound.cap.toFormattedPrice,
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
                                subTitle: c.model.raisingRound.fundRequirement
                                    .toFormattedPrice,
                              ),
                              const SizedBox(height: 30),
                              DetailWidget(
                                title: 'Total Round Size',
                                subTitle: c.model.raisingRound
                                    .totalFundRequirement.toFormattedPrice,
                              ),
                              const SizedBox(height: 30),
                              DetailWidget(
                                title: 'Share price',
                                subTitle:
                                    "${c.model.raisingRound.sharePrice.toCurrency}",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: c.model.isActiveRound,
                    child: const SizedBox(height: 45),
                  ),
                  Center(
                    child: Visibility(
                      visible: c.model.isActiveRound,
                      child: CustomElevatedButton(
                        size: const Size(361, 64),
                        radius: 22,
                        onPressed: () async {
                          var res =
                              await showCustomDialog(InvestorListDialog());
                          Get.delete<InvestorListDialogCtrl>();
                          if (res is InvestorModel) {
                            logger.d(res.toJson());
                            var data = await Get.toNamed(
                              Routes.primaryInvestmentPath(
                                  Get.currentRoute, res.uuid),
                            );
                            // var data = await Get.to(() => InvestmentPage(),
                            //     arguments: {'startup': c.model, 'investor': res});
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
                ],
              ),
            ),
          ],
        );
      } else {
        return Loader();
      }
    });
  }
}

class _KeyInformationWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _KeyInformationWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 30),
      child: Obx(() {
        if (c.model.cms.keyInformation.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Key Information",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Html(data: c.model.cms.keyInformation),
            ],
          );
        } else {
          return NoDataView();
        }
      }),
    );
  }
}

class _DocumentWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _DocumentWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Documents",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DocumentTile(
                  title: "Pitch-deck",
                  file: c.model.cms.pitchDeck,
                  hint:
                      "A pitch deck is a brief presentation that gives potential investors or clients an overview of your business plan, products, services and growth traction.",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: DocumentTile(
                  title: "Finacial Projections",
                  file: c.model.cms.financialProjection,
                  hint:
                      "A forecasts of your cash inflows and outlays, income and balance sheet for future course of time",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DocumentTile(
                  title: "DD Report",
                  file: c.model.cms.ddReport,
                  hint:
                      "Due diligence is an investigation, audit, or review performed to confirm facts or details of a matter under consideration.",
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: DocumentTile(
                  title: "DIPP start-up certificate",
                  file: c.model.cms.dpiitReport,
                  hint:
                      "A certificate that helps to get recognized as a startup by the Department of Industrial Policy and Promotion (DIPP) under the Ministry of Commerce and Industry.",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DocumentTile(
                  title: "Shuru-Up Research Report",
                  file: c.model.cms.shuruupResearchReport,
                  hint:
                      "A report made by the Shuru-Up team so as to provide deep understanding of the start-up",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: DocumentTile(
                  title: "Valuation Report",
                  file: c.model.cms.valuationReport,
                  hint:
                      "A report of a registered valuer or merchant banker that aids in quantifying the valuation of the start-up.",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FAQWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _FAQWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.model.faqs.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.separated(
                  itemCount: c.model.faqs.length,
                  itemBuilder: (context, index) {
                    var model = c.model.faqs[index];
                    return ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      ),
                      onExpansionChanged: (value) {
                        // logger.d('Value :$value');
                      },
                      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      textColor: context.textTheme.titleMedium?.color,
                      collapsedTextColor: context.textTheme.titleMedium?.color,
                      collapsedBackgroundColor:
                          context.theme.colorScheme.surface,
                      dense: false,
                      tilePadding: context.isPhone
                          ? const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15)
                          : const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                      backgroundColor: context.theme.colorScheme.surface,
                      leading: Text(
                        "Q",
                        style: TextStyle(
                          fontSize: context.isPhone ? 18 : 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      title: Text(
                        model.question,
                        style: TextStyle(
                          fontSize: context.isPhone ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "A",
                              style: TextStyle(
                                fontSize: context.isPhone ? 16 : 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 35),
                            Flexible(
                              child: Text(
                                model.answer,
                                style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                  fontSize: context.isPhone ? 14 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) =>
                      SizedBox(height: context.isPhone ? 5 : 20),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      } else {
        return NoDataView();
      }
    });
  }
}

class _InvestorWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _InvestorWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.model.portfolio.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Investors",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.separated(
                  itemCount: c.model.portfolio.length,
                  itemBuilder: (context, index) {
                    var model = c.model.portfolio[index];
                    return CustomCardWidget(
                      radius: 14,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: context.isPhone ? 15 : 30),
                        child: Row(
                          children: [
                            LogoImage(
                              url: model.profile,
                              placeHolderImage: AppAssets.maleUserPlaceholder,
                              height: context.isPhone ? 50 : 65,
                              width: context.isPhone ? 50 : 65,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              model.showName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: context.isPhone ? 16 : 20,
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: !context.isPhone,
                              child: Text(
                                "Amount Invested: ",
                                style: TextStyle(
                                    color: context
                                        .theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                            Text(
                              model.totalInvested.toFormattedPrice,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.isPhone ? 16 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ),
              ),
            ],
          ),
        );
      } else {
        return NoDataView();
      }
    });
  }
}

class _UpdatesWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _UpdatesWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.model.updates.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Updates",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: c.model.updates.length,
                itemBuilder: (context, index) {
                  var model = c.model.updates[index];
                  return CustomCardWidget(
                    radius: 14,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CacheImage(
                                url: model.image,
                                height: 65,
                                width: 65,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                model.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                model.createdAt.dateWithSortMonthYear,
                                style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Divider(
                            height: 1,
                            thickness: 0.6,
                            color: context.theme.dividerColor
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            model.description,
                            style: TextStyle(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
              ),
            ),
          ],
        );
      } else {
        return NoDataView();
      }
    });
  }
}

class _TeamWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _TeamWidget();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.model.teamMembers.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Team List",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.separated(
                  itemCount: c.model.teamMembers.length,
                  itemBuilder: (context, index) {
                    var model = c.model.teamMembers[index];
                    return CustomCardWidget(
                      radius: 14,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                LogoImage(
                                  url: model.profilePhoto,
                                  height: 65,
                                  width: 65,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        model.designation,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      // Text.rich(
                                      //   TextSpan(
                                      //     style: const TextStyle(fontSize: 16),
                                      //     children: [
                                      //       TextSpan(
                                      //         text: 'Designation: ',
                                      //         style: TextStyle(
                                      //           color: context.theme.colorScheme.onSurfaceVariant,
                                      //         ),
                                      //       ),
                                      //
                                      //     ],
                                      //   ),
                                      // )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: model.linkedinUrl.isNotEmpty,
                                  child: IconButton(
                                    splashRadius: 20,
                                    icon: const FaIcon(
                                      FontAwesomeIcons.linkedin,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Launcher.launchURL(model.linkedinUrl);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Divider(
                              height: 1,
                              thickness: 0.6,
                              color: context.theme.dividerColor
                                  .withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 25),
                            Text(
                              model.briefInformation,
                              style: TextStyle(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                ),
              ),
            ],
          ),
        );
      } else {
        return NoDataView();
      }
    });
  }
}

class _IdeaWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  _IdeaWidget();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 100, vertical: 30),
      child: Column(
        children: [
          Visibility(
            visible: c.model.cms.pitchVideo.isNotEmpty,
            child: CustomVideoPlayer(
              url: c.model.cms.pitchVideo,
            ),
          ),
          const SizedBox(height: 15),
          Html(data: c.model.cms.idea),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: context.theme.scaffoldBackgroundColor,
      width: 800,
      padding: EdgeInsets.symmetric(horizontal: 100),
      alignment: Alignment.center,
      // padding: EdgeInsets.symmetric(horizontal: context.),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

// class DesktopStartupDetailView extends StatelessWidget {
//   final StartupDetailPageCtrl c = Get.find<StartupDetailPageCtrl>();
//
//   DesktopStartupDetailView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Obx(() {
//           if (c.isLoading.isFalse) {
//             return SingleChildScrollView(
//               controller: c.parentController,
//               physics: c.isParentScrolling.isTrue
//                   ? const BouncingScrollPhysics()
//                   : const NeverScrollableScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Stack(
//                     children: [
//                       SizedBox(
//                         height: 280,
//                         child: CacheImage(
//                           url: c.model.cms.longBanner,
//                           fit: BoxFit.fitWidth,
//                           width: context.width,
//                         ),
//                       ),
//                       Positioned(
//                         top: 20,
//                         left: 80,
//                         child: InkWell(
//                           onTap: Get.back,
//                           borderRadius: BorderRadius.circular(63),
//                           child: Container(
//                             height: 63,
//                             width: 63,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color:
//                                   context.theme.dividerColor.withValues(alpha: 0.5),
//                             ),
//                             child: Icon(
//                               Icons.arrow_back,
//                               color: context.theme.scaffoldBackgroundColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 120, vertical: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             LogoImage(
//                               height: 112,
//                               width: 112,
//                               url: c.model.cms.logo,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     c.model.brandName,
//                                     maxLines: 3,
//                                     style: const TextStyle(
//                                         fontSize: 28,
//                                         fontWeight: FontWeight.w600),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     c.model.cms.oneLiner,
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w500,
//                                       color: context.theme.colorScheme.onSurfaceVariant,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//
//                         const SizedBox(height: 30),
//                         Container(
//                           width: context.width,
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 25, horizontal: 30),
//                           decoration: BoxDecoration(
//                             color: context.theme.primaryColor.withOpacity(0.05),
//                             borderRadius: const BorderRadius.vertical(
//                                 bottom: Radius.circular(10)),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Startup Highlights",
//                                 style: TextStyle(
//                                   color: context.theme.primaryColor,
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 15),
//                               Text(
//                                 c.model.briefInformation,
//                               )
//                             ],
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: const BorderRadius.vertical(
//                                 top: Radius.circular(10)),
//                             color: context.theme.scaffoldBackgroundColor,
//                             border: Border.all(
//                                 color: context.theme.dividerColor
//                                     .withValues(alpha: 0.2)),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 26, vertical: 23),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 flex: 4,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Startup Overview",
//                                       style: TextStyle(
//                                         color: context.theme.primaryColor,
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Location',
//                                       subTitle: c.model.city.name.capitalFirst,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Social Media',
//                                       alignment: Alignment.centerLeft,
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: c.model.socialMediaLinks
//                                             .map(
//                                               (e) => e.icon != null
//                                                   ? Padding(
//                                                       padding:
//                                                           const EdgeInsets.only(
//                                                               right: 15),
//                                                       child: GestureDetector(
//                                                           onTap: () {
//                                                             Launcher.launchURL(
//                                                                 e.link);
//                                                           },
//                                                           child: Icon(e.icon,
//                                                               size: 30)),
//                                                     )
//                                                   : const SizedBox(),
//                                             )
//                                             .toList(),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'website',
//                                       subTitle: c.model.cms.website.naString,
//                                       isUrl: true,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Company Number',
//                                       subTitle: c.model.legalInfo.cin.naString,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Incorporation date',
//                                       subTitle: c
//                                           .model
//                                           .legalInfo
//                                           .incorporationDate
//                                           .dateWithSortMonthYear,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 flex: 3,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Investment Summary",
//                                       style: TextStyle(
//                                         color: context.theme.primaryColor,
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Type',
//                                       subTitle: c.model.raisingRound.instrument.instrumentName,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     Visibility(
//                                       visible: !c.model.isEquity,
//                                       child: DetailWidget(
//                                         title: 'Floor',
//                                         subTitle: c.model.raisingRound.floor
//                                             .toFormattedPrice,
//                                       ),
//                                     ),
//                                     Visibility(
//                                         visible: !c.model.isEquity,
//                                         child: const SizedBox(height: 30)),
//                                     Visibility(
//                                       visible: !c.model.isEquity,
//                                       child: DetailWidget(
//                                         title: 'Cap',
//                                         subTitle: c.model.raisingRound.cap
//                                             .toFormattedPrice,
//                                       ),
//                                     ),
//                                     Visibility(
//                                         visible: !c.model.isEquity,
//                                         child: const SizedBox(height: 30)),
//                                     Visibility(
//                                       visible: c.model.isEquity,
//                                       child: DetailWidget(
//                                         title: 'Valuation',
//                                         subTitle: c.model.raisingRound.floor
//                                             .toFormattedPrice,
//                                       ),
//                                     ),
//                                     Visibility(
//                                         visible: c.model.isEquity,
//                                         child: const SizedBox(height: 30)),
//                                     DetailWidget(
//                                       title: 'Equity Offered',
//                                       subTitle:
//                                           "${c.model.raisingRound.equityOffered}%",
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Shuru-Up Round Size',
//                                       subTitle: c.model.raisingRound
//                                           .fundRequirement.toFormattedPrice,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Total Round Size',
//                                       subTitle: c
//                                           .model
//                                           .raisingRound
//                                           .totalFundRequirement
//                                           .toFormattedPrice,
//                                     ),
//                                     const SizedBox(height: 30),
//                                     DetailWidget(
//                                       title: 'Share price',
//                                       subTitle:
//                                           "${c.model.raisingRound.sharePrice.toCurrency}",
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Visibility(
//                           visible: c.model.isActiveRound && !app.fromSecondary,
//                           child: const SizedBox(height: 45),
//                         ),
//                         Center(
//                           child: Visibility(
//                             visible: c.model.isActiveRound && !app.fromSecondary,
//                             child: CustomElevatedButton(
//                               size: const Size(361, 64),
//                               radius: 22,
//                               onPressed: () async {
//                                 var res = await showCustomDialog(
//                                     InvestorListDialog());
//                                 Get.delete<InvestorListDialogCtrl>();
//                                 if (res is InvestorModel) {
//                                   logger.d(res.toJson());
//                                   var data = await Get.to(
//                                       () => InvestmentPage(),
//                                       arguments: {
//                                         'startup': c.model,
//                                         'investor': res
//                                       });
//                                   if (data == true) {
//                                     c.getData();
//                                   }
//                                 }
//                               },
//                               text: 'Invest Now',
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 50),
//                         Visibility(
//                           visible: app.fromSecondary,
//                           child: MarketWidget(),
//                         ),
//                         Visibility(
//                           visible: app.fromSecondary,
//                           child: const SizedBox(height: 40),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                                 color: context.theme.dividerColor
//                                     .withValues(alpha: 0.2)),
//                           ),
//                           alignment: Alignment.center,
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Row(
//                               children: [
//                                 // Visibility(
//                                 //   visible: c.fromSecondary,
//                                 //   child: CustomTabBarButton(
//                                 //     tab: StartupDetailEnum.market,
//                                 //     title: "Market",
//                                 //   ),
//                                 // ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.idea,
//                                   title: "Idea",
//                                 ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.keyInfo,
//                                   title: "Key Information",
//                                 ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.team,
//                                   title: "Team",
//                                 ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.updates,
//                                   title: "Updates",
//                                 ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.investor,
//                                   title: "Investor",
//                                 ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.faq,
//                                   title: "FAQ’s",
//                                 ),
//                                 // CustomTabBarButton(
//                                 //   tab: StartupDetailEnum.meet,
//                                 //   title: "Shuru-meet",
//                                 // ),
//                                 CustomTabBarButton(
//                                   tab: StartupDetailEnum.documents,
//                                   title: "Documents",
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         CustomTabBarView(),
//                         // const SizedBox(height: 80),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return const Loader();
//           }
//         }),
//       ),
//     );
//   }
// }
