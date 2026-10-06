import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';

class DSideBarWidget extends StatelessWidget {
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  DSideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);

    // Parent Positioned(top/bottom) supplies height; keep width fixed at 260.
    return Material(
      color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF7F9FC),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1),
            ),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 14),
              child: Text(
                'WORKSPACE',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            DTabTileWidget(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              tab: WTabBarEnum.dashboard,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Transactions',
              tab: WTabBarEnum.investorTransactions,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.pie_chart_outline_rounded,
              title: 'Portfolio',
              tab: WTabBarEnum.portfolio,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.people_outline,
              title: 'Investors',
              tab: WTabBarEnum.investors,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.question_answer_outlined,
              title: 'My Inquiries',
              tab: WTabBarEnum.myInquiries,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.pending_actions_outlined,
              title: 'Pending Task',
              tab: WTabBarEnum.pendingTasks,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.payments_outlined,
              title: 'My Earnings',
              tab: WTabBarEnum.myEarnings,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.upload_file_outlined,
              title: 'Upload Portfolio',
              tab: WTabBarEnum.uploadPortfolio,
            ),
            Obx(() {
              final showDocs =
                  app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess;
              if (!showDocs) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 8),
                  DTabTileWidget(
                    icon: Icons.send_outlined,
                    title: 'Send Documents',
                    tab: WTabBarEnum.sendDocuments,
                  ),
                  const SizedBox(height: 8),
                  DTabTileWidget(
                    icon: Icons.analytics_outlined,
                    title: 'MIS',
                    tab: WTabBarEnum.mis,
                  ),
                ],
              );
            }),
            if (app.wUser.type != 'Relation Manager') ...[
              const SizedBox(height: 8),
              DTabTileWidget(
                icon: Icons.handshake_outlined,
                title: 'Channel Partner',
                tab: WTabBarEnum.channelPartner,
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
              child: Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF30363D)
                    : const Color(0xFFB8C2D1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14, bottom: 14),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            DTabTileWidget(
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              tab: WTabBarEnum.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class DTabTileWidget extends StatelessWidget {
  final WTabBarEnum tab;
  final VoidCallback? onTap;
  final String title;
  final IconData icon;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);
    final radius = BorderRadius.circular(12);

    return Obx(() {
      if (SessionNavigation.check('/wealth-manager/${tab.slug}') !=
          AccessResult.allowed) {
        return const SizedBox.shrink();
      }

      final isSelected = c.currentTab() == tab;

      return Semantics(
        selected: isSelected,
        child: Material(
          color: isSelected
              ? (isDark ? const Color(0xFF1A2E48) : const Color(0xFFD5E2F2))
              : Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap:
                onTap ??
                () {
                  final scaffold = Scaffold.maybeOf(context);
                  if (scaffold?.isDrawerOpen ?? false) {
                    Navigator.of(context).pop();
                  }
                  c.onTap(tab);
                },
            borderRadius: radius,
            mouseCursor: SystemMouseCursors.click,
            hoverColor: accent.withAlpha(18),
            focusColor: accent.withAlpha(26),
            splashColor: accent.withAlpha(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: isSelected ? accent : muted),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? accent : muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
