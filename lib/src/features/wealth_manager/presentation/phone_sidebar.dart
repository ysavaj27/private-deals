import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';

class PSideBarWidget extends StatelessWidget {
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  PSideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height,
      width: 271,
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // SizedBox(height: 20),
          Container(
            height: 19,
            width: Get.width,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
              ),
            ),
          ),
          // SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 16, top: 9),
                    child: Image.asset(
                      AppAssets.newLogo,
                      height: 45,

                      // width: 74.05,
                      // colorFilter: ColorFilter.mode(
                      //   context.iconColor!,
                      //   BlendMode.srcIn,
                      // ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    color: context.theme.colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 15),
                  PTabTileWidget(
                    icon: AppAssets.desktopDashboardIc,
                    title: 'Dashboard',
                    tab: WTabBarEnum.dashboard,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.transactionIc,
                    title: 'Transactions',
                    tab: WTabBarEnum.investorTransactions,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.portfolioIc,
                    title: 'Portfolio',
                    tab: WTabBarEnum.portfolio,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.myEarningIc,
                    title: 'My Earnings',
                    tab: WTabBarEnum.myEarnings,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.investorsIc,
                    title: 'Investors',
                    tab: WTabBarEnum.investors,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.sendDocumentsIc,
                    title: 'My Inquiries',
                    tab: WTabBarEnum.myInquiries,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.pendingKycIc,
                    title: 'Pending Task',
                    tab: WTabBarEnum.pendingTasks,
                  ),
                  const SizedBox(height: 5),
                  Obx(() {
                    return Visibility(
                      visible:
                          app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: PTabTileWidget(
                        icon: AppAssets.sendDocumentsIc,
                        title: 'Send Documents',
                        tab: WTabBarEnum.sendDocuments,
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible:
                          app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: const SizedBox(height: 5),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible:
                          app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: PTabTileWidget(
                        icon: AppAssets.misIc,
                        title: 'MIS',
                        tab: WTabBarEnum.mis,
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible:
                          app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: const SizedBox(height: 5),
                    );
                  }),
                  Visibility(
                    visible: app.wUser.type != 'Relation Manager',
                    child: PTabTileWidget(
                      icon: AppAssets.distributorsIc,
                      title: 'Channel Partner',
                      tab: WTabBarEnum.channelPartner,
                    ),
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.uploadIc,
                    title: 'Upload Portfolio',
                    tab: WTabBarEnum.uploadPortfolio,
                  ),
                  const SizedBox(height: 5),
                  PTabTileWidget(
                    icon: AppAssets.profileIc2,
                    title: 'Profile',
                    tab: WTabBarEnum.profile,
                  ),
                  const SizedBox(height: 5),
                  const LogoutWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            height: 19,
            width: Get.width,
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PTabTileWidget extends StatelessWidget {
  final WTabBarEnum tab;
  final void Function()? onTap;
  final String title;
  final String icon;

  final HomePageCtrl c = Get.find<HomePageCtrl>();

  PTabTileWidget({
    super.key,
    this.onTap,
    required this.title,
    required this.tab,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Obx(() {
        if (SessionNavigation.check('/wealth-manager/${tab.slug}') !=
            AccessResult.allowed)
          return const SizedBox.shrink();
        if (SessionNavigation.check('/wealth-manager/${tab.slug}') !=
            AccessResult.allowed)
          return const SizedBox.shrink();
        bool isSelected = c.currentTab() == tab;
        return Row(
          children: [
            AnimatedContainer(
              margin: const EdgeInsets.only(left: 3),
              duration: const Duration(milliseconds: 200),
              height: 0,
              width: 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: context.theme.primaryColor,
              ),
            ),
            Expanded(
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap:
                    onTap ??
                    () {
                      Get.back();
                      c.onTap(tab);
                      // c.currentTab(tab);
                      c.isExpand(true);
                    },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
                child: CustomCardWidget(
                  isBorder: isSelected,
                  borderColor: context.theme.colorScheme.outlineVariant,
                  color: isSelected
                      ? context.theme.colorScheme.primaryContainer
                      : Colors.transparent,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  borderRadius: BorderRadius.circular(12),
                  // duration: const Duration(milliseconds: 200),
                  height: 40,
                  // margin: const EdgeInsets.only(left: 10),
                  // decoration: BoxDecoration(
                  //   borderRadius: const BorderRadius.only(
                  //     topLeft: Radius.circular(6),
                  //     bottomLeft: Radius.circular(6),
                  //   ),
                  //   color: isSelected
                  //       ? context.theme.primaryColor.withValues(alpha: 0.1)
                  //       : Colors.transparent,
                  // ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        return Visibility(
                          visible: c.isExpand.isTrue,
                          child: const SizedBox(width: 20),
                        );
                      }),
                      SVGImage(
                        icon,
                        height: 24,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? context.theme.colorScheme.onPrimaryContainer
                              : context.theme.colorScheme.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      // Icon(
                      //   icon,
                      //   size: 24,
                      //   color: isSelected ? context.theme.primaryColor : Colors.grey,
                      // ),
                      Obx(() {
                        return Visibility(
                          visible: c.isExpand.isTrue,
                          child: const SizedBox(width: 20),
                        );
                      }),
                      c.isExpand.isTrue
                          ? Expanded(
                              child: Obx(() {
                                return Visibility(
                                  visible: c.isExpand.isTrue,
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      fontSize: 14,
                                      // fontSize: isSelected ? 14 : 12,
                                      color: isSelected
                                          ? context
                                                .theme
                                                .colorScheme
                                                .onPrimaryContainer
                                          : context
                                                .theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          AnimatedContainer(
            margin: const EdgeInsets.only(left: 3),
            duration: const Duration(milliseconds: 200),
            height: 0,
            width: 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: context.theme.primaryColor,
            ),
          ),
          Expanded(
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                Get.back();
                showCustomDialog(
                  LogoutDialog(
                    onPressed: () async {
                      await SessionNavigation.logout();
                    },
                  ),
                );
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
              child: CustomCardWidget(
                isBorder: false,
                borderRadius: BorderRadius.circular(12),
                // duration: const Duration(milliseconds: 200),
                height: 40,
                // margin: const EdgeInsets.only(left: 10),
                // decoration: BoxDecoration(
                //   borderRadius: const BorderRadius.only(
                //     topLeft: Radius.circular(6),
                //     bottomLeft: Radius.circular(6),
                //   ),
                //   color: isSelected
                //       ? context.theme.primaryColor.withValues(alpha: 0.1)
                //       : Colors.transparent,
                // ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.logout_outlined,
                      size: 24,
                      color: Colors.grey,
                    ),
                    // Icon(
                    //   icon,
                    //   size: 24,
                    //   color: isSelected ? context.theme.primaryColor : Colors.grey,
                    // ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Logout",
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
