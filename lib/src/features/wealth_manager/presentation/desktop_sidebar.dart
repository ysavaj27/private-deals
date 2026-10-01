import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';

class DSideBarWidget extends StatelessWidget {
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  DSideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        mouseCursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: context.height,
          width: c.isExpand.isTrue ? 260 : 100,
          decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                    color: context.theme.colorScheme.outlineVariant)),
            color: context.theme.colorScheme.surfaceContainerLow,
            borderRadius: context.isPhone
                ? const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : null,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                if (c.isExpand.isTrue)
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 14),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('WORKSPACE',
                            style: context.textTheme.labelSmall?.copyWith(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 1.6))),
                  ),
                DTabTileWidget(
                  icon: AppAssets.desktopDashboardIc,
                  title: 'Dashboard',
                  tab: WTabBarEnum.dashboard,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.transactionIc,
                  title: 'Transactions',
                  tab: WTabBarEnum.investorTransactions,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.portfolioIc,
                  title: 'Portfolio',
                  tab: WTabBarEnum.portfolio,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.investorsIc,
                  title: 'Investors',
                  tab: WTabBarEnum.investors,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.pendingKycIc,
                  title: 'Pending Task',
                  tab: WTabBarEnum.pendingTasks,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.myEarningIc,
                  title: 'My Earnings',
                  tab: WTabBarEnum.myEarnings,
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.downloadIc,
                  title: 'Upload Portfolio',
                  tab: WTabBarEnum.uploadPortfolio,
                ),
                const SizedBox(height: 8),
                Obx(() {
                  return Visibility(
                    visible: app.wUser.isPrimaryAccess ||
                        app.wUser.isSecondaryAccess,
                    child: DTabTileWidget(
                      icon: AppAssets.sendDocumentsIc,
                      title: 'Send Documents',
                      tab: WTabBarEnum.sendDocuments,
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                      visible: app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: SizedBox(height: 8));
                }),
                Obx(() {
                  return Visibility(
                    visible: app.wUser.isPrimaryAccess ||
                        app.wUser.isSecondaryAccess,
                    child: DTabTileWidget(
                      icon: AppAssets.misIc,
                      title: 'MIS',
                      tab: WTabBarEnum.mis,
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                      visible: app.wUser.isPrimaryAccess ||
                          app.wUser.isSecondaryAccess,
                      child: SizedBox(height: 8));
                }),
                Visibility(
                  visible: app.wUser.type !=
                      'Relation Manager',
                  child: DTabTileWidget(
                    icon: AppAssets.distributorsIc,
                    title: 'Channel Partner',
                    tab: WTabBarEnum.channelPartner,
                  ),
                ),
                const SizedBox(height: 8),
                DTabTileWidget(
                  icon: AppAssets.profileIc2,
                  title: 'Profile',
                  tab: WTabBarEnum.profile,
                ),
                const SizedBox(height: 8),
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 10),
                //   child: Divider(color: Colors.black54),
                // ),
                // const SizedBox(height: 30),
                // Obx(() {
                //   return InkWell(
                //     onTap: () {
                //       c.isExpand.toggle();
                //     },
                //     child: AnimatedSwitcher(
                //       duration: const Duration(milliseconds: 500),
                //       child: c.isExpand.isTrue
                //           ? Row(
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: [
                //                 const SizedBox(width: 20),
                //                 Icon(
                //                   Icons.arrow_back_outlined,
                //                   color: Colors.grey.shade600,
                //                 ),
                //                 const SizedBox(width: 20),
                //                 const Expanded(
                //                   child: Text(
                //                     "Collapse",
                //                     maxLines: 1,
                //                     style: TextStyle(color: Colors.black),
                //                   ),
                //                 ),
                //               ],
                //             )
                //           : Icon(
                //               Icons.arrow_forward_outlined,
                //               color: Colors.grey.shade600,
                //             ),
                //     ),
                //   );
                // }),
                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class DTabTileWidget extends StatelessWidget {
  final WTabBarEnum tab;
  final void Function()? onTap;
  final String title;
  final String icon;

  final HomePageCtrl c = Get.find<HomePageCtrl>();

  DTabTileWidget({
    super.key,
    this.onTap,
    required this.title,
    required this.tab,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Obx(() {
        if (SessionNavigation.check('/wealth-manager/${tab.slug}') != AccessResult.allowed) return const SizedBox.shrink();
        bool isSelected = c.currentTab() == tab;
        return Clickable(
          onTap: onTap ??
              () {
                c.onTap(tab);
              },
          borderRadius: BorderRadius.circular(12),
          child: CustomCardWidget(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            margin: const EdgeInsets.only(left: 16, right: 16),
            // height: 52,
            radius: 12,
            isBorder: isSelected,
            borderColor: context.theme.colorScheme.outlineVariant,
            color: isSelected
                ? context.theme.colorScheme.primaryContainer
                : Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SVGImage(
                  icon,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                      isSelected
                          ? context.theme.colorScheme.onPrimaryContainer
                          : context.theme.colorScheme.onSurfaceVariant,
                      BlendMode.srcIn),
                ),
                // Icon(
                //   icon,
                //   size: 24,
                //   color: isSelected ? context.theme.colorScheme.onPrimaryContainer : context.theme.colorScheme.onSurfaceVariant,
                // ),
                Obx(() {
                  return Visibility(
                    visible: c.isExpand.isTrue,
                    child: const SizedBox(width: 15),
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
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 14,
                                color: isSelected
                                    ? context
                                        .theme.colorScheme.onPrimaryContainer
                                    : context
                                        .theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
