import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/desktop_primary_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/phone_primary_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page_ctrl.dart';

class PrimaryDetailPage extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.put(PrimaryDetailPageCtrl());

  PrimaryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePrimaryDetailView();
    } else {
      return DesktopPrimaryDetailView();
    }
  }
}

class CustomTabBarView extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  CustomTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    double phoneHeight = context.height - 160;
    double desktopHeight = context.height - 150;

    return SizedBox(
      height: context.isPhone ? phoneHeight : desktopHeight,
      child: SingleChildScrollView(
        controller: c.childController,
        physics: c.isParentScrolling.isTrue
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        child: Obx(() {
          switch (c.currentTab()) {
            case StartupDetailEnum.idea:
              return Column(
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
              );
            case StartupDetailEnum.keyInfo:
              return Html(data: c.model.cms.keyInformation);
            case StartupDetailEnum.team:
              return TeamWidget();
            case StartupDetailEnum.updates:
              return UpdatesWidget();
            case StartupDetailEnum.investor:
              return InvestorWidget();
            case StartupDetailEnum.faq:
              return FAQWidget();
            case StartupDetailEnum.meet:
              return PitchWidget();
            case StartupDetailEnum.documents:
              return DocumentWidget();
            // case StartupDetailEnum.market:
            //   return MarketWidget();
          }
        }),
      ),
    );
  }
}

class PitchWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  PitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: c.model.pitches.isNotEmpty,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pitches",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            ListView.separated(
              shrinkWrap: true,
              itemCount: c.model.pitches.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var model = c.model.pitches[index];
                return CustomCardWidget(
                  radius: 14,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              model.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            Visibility(
                              visible: model.scheduledDate.isBefore(today),
                              child: CustomOutlinedButton(
                                width: 120,
                                onPressed: () {
                                  c.applyPitch(
                                      startupId: model.startupId,
                                      pitchId: model.id);
                                },
                                text: 'Apply',
                                // child: Text(
                                //   "Apply",
                                //   style: TextStyle(fontSize: 16),
                                // ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color:
                              context.theme.dividerColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.description,
                                style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Text(
                              model.scheduledDate.dateWithSortMonthYear,
                              style: TextStyle(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ],
        ),
      );
    });
  }
}

class DocumentWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  DocumentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Column(
          children: context.isPhone
              ? [
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "Pitch-deck",
                    file: c.model.cms.pitchDeck,
                    hint:
                        "A pitch deck is a brief presentation that gives potential investors or clients an overview of your business plan, products, services and growth traction.",
                  ),
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "Finacial Projections",
                    file: c.model.cms.financialProjection,
                    hint:
                        "A forecasts of your cash inflows and outlays, income and balance sheet for future course of time",
                  ),
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "DD Report",
                    file: c.model.cms.ddReport,
                    hint:
                        "Due diligence is an investigation, audit, or review performed to confirm facts or details of a matter under consideration.",
                  ),
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "DIPP start-up certificate",
                    file: c.model.cms.dpiitReport,
                    hint:
                        "A certificate that helps to get recognized as a startup by the Department of Industrial Policy and Promotion (DIPP) under the Ministry of Commerce and Industry.",
                  ),
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "Shuru-Up Research Report",
                    file: c.model.cms.shuruupResearchReport,
                    hint:
                        "A report made by the Shuru-Up team so as to provide deep understanding of the start-up",
                  ),
                  const SizedBox(height: 15),
                  DocumentTile(
                    title: "Valuation Report",
                    file: c.model.cms.valuationReport,
                    hint:
                        "A report of a registered valuer or merchant banker that aids in quantifying the valuation of the start-up.",
                  ),
                ]
              : [
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
      ],
    );
  }
}

class DocumentTile extends StatelessWidget {
  final String title;
  final String hint;
  final String icon;
  final String file;

  const DocumentTile({
    super.key,
    this.title = '',
    this.hint = '',
    this.icon = '',
    this.file = '',
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Row(
          children: [
            // const Icon(
            //   Icons.add_circle_outline,
            //   size: 22,
            // ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      splashRadius: 20,
                      onPressed: () {
                        showCustomDialog(
                            InfoDialogWidget(title: title, hint: hint));
                      },
                      icon: Icon(
                        Icons.info,
                        color: context.theme.dividerColor,
                      )),
                ],
              ),
            ),
            file.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      // logger.d('File path :${file}');
                      if (file.isExcelFileName) {
                        // Get.to(() => ExcelViewerScreen(url: file));
                      } else if (file.isPDFFileName) {
                        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
                          Get.to(() => PdfViewerPage(path: file));
                        } else {
                          showCustomDialog(PdfViewerDialog(path: file));
                        }
                      } else if (file.isVideoFileName) {
                        showCustomDialog(CustomVideoPlayer(url: file));
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'View',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.theme.primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    child: Text(
                      "Not Found",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: context.theme.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class InvestorWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  InvestorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: c.model.portfolio.isNotEmpty,
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
            ListView.separated(
              shrinkWrap: true,
              itemCount: c.model.portfolio.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var model = c.model.portfolio[index];
                return CustomCardWidget(
                  radius: 14,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: context.isPhone ? 15 : 30),
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
                                color:
                                    context.theme.colorScheme.onSurfaceVariant),
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
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ],
        ),
      );
    });
  }
}

class UpdatesWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  UpdatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: c.model.updates.isNotEmpty,
        child: Column(
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
            ListView.separated(
              shrinkWrap: true,
              itemCount: c.model.updates.length,
              physics: const NeverScrollableScrollPhysics(),
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
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color:
                              context.theme.dividerColor.withValues(alpha: 0.4),
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
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ],
        ),
      );
    });
  }
}

class FAQWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  FAQWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: c.model.faqs.isNotEmpty,
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
            ListView.separated(
              shrinkWrap: true,
              itemCount: c.model.faqs.length,
              // padding: const EdgeInsets.symmetric(vertical: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                var model = c.model.faqs[index];
                return ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide.none,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  textColor: context.textTheme.titleMedium?.color,
                  collapsedTextColor: context.textTheme.titleMedium?.color,
                  collapsedBackgroundColor: context.theme.colorScheme.surface,
                  dense: false,
                  tilePadding: context.isPhone
                      ? const EdgeInsets.symmetric(vertical: 10, horizontal: 15)
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
                              color: context.theme.colorScheme.onSurfaceVariant,
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
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}

class TeamWidget extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  TeamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: c.model.teamMembers.isNotEmpty,
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
            ListView.separated(
              shrinkWrap: true,
              itemCount: c.model.teamMembers.length,
              physics: const NeverScrollableScrollPhysics(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                          color:
                              context.theme.dividerColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          model.briefInformation,
                          style: TextStyle(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ],
        ),
      );
    });
  }
}

class CustomTabBarButton extends StatelessWidget {
  final StartupDetailEnum tab;
  final String title;

  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  CustomTabBarButton({super.key, required this.tab, required this.title});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = c.currentTab() == tab;
      return Padding(
        key: c.keys[tab.index],
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: InkWell(
          onTap: () {
            c.currentTab(tab);
            if (context.isPhone) {
              c.scrollToSelectedIndex(tab.index);
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.fast),
            curve: AppMotion.easeOut,
            padding: EdgeInsets.symmetric(
                horizontal: context.isPhone ? 10 : 25, vertical: 10),
            decoration: BoxDecoration(
              color:
                  isSelected ? context.theme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              isSelected ? title.toUpperCase() : title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : null,
                fontSize: context.isPhone ? 14 : 16,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class DetailWidget extends StatelessWidget {
  final Alignment alignment;
  final String title;
  final String subTitle;
  final Widget? child;
  final bool isUrl;

  const DetailWidget({
    super.key,
    this.alignment = Alignment.centerLeft,
    required this.title,
    this.subTitle = '',
    this.child,
    this.isUrl = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
              fontSize: context.isPhone ? 14 : 18,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: alignment,
            child: Clickable(
              onTap: isUrl ? () => Launcher.launchURL(subTitle) : null,
              child: child ??
                  Text(
                    subTitle,
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: context.isPhone ? 14 : 18,
                      decoration: isUrl ? TextDecoration.underline : null,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoDialogWidget extends StatelessWidget {
  final String title;
  final String hint;

  const InfoDialogWidget({super.key, required this.title, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(20),
      width: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.theme.scaffoldBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          // SizedBox(height: 5),
          Divider(
            height: 1,
            thickness: 0.7,
            color: context.theme.dividerColor.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 20),
          Text(
            hint,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
