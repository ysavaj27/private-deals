import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';

class DSideBarWidget extends StatelessWidget {
  const DSideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);

    return Container(
      width: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF7F9FC),
        borderRadius: context.isPhone
            ? const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : BorderRadius.zero,
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1),
        ),
      ),
      child: SafeArea(
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
            const DUnlistedMenu(),
            const SizedBox(height: 8),
            const DLpSecondaryMenu(),
            const SizedBox(height: 8),
            const DDealOfTheDayMenu(),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Transactions',
              tab: WTabBarEnum.preIPOTransactions,
            ),
            const SizedBox(height: 8),
            DTabTileWidget(
              icon: Icons.sell_outlined,
              title: 'Enquiry',
              tab: WTabBarEnum.sellEnquiries,
            ),
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

  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

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

/// Sidebar action row styled to match [DTabTileWidget] (no tab selection).
class DActionTileWidget extends StatelessWidget {
  const DActionTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);
    final color = destructive ? Theme.of(context).colorScheme.error : muted;
    final radius = BorderRadius.circular(12);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        mouseCursor: SystemMouseCursors.click,
        hoverColor: accent.withAlpha(18),
        focusColor: accent.withAlpha(26),
        splashColor: accent.withAlpha(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DExpandableMenu extends GetView<SellerHomePageCtrl> {
  const DExpandableMenu({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);
    final colors = context.theme.colorScheme;
    final foreground = selected ? accent : muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: selected
              ? (isDark ? const Color(0xFF1A2E48) : const Color(0xFFD5E2F2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (selected) return;
              onToggle();
            },
            hoverColor: accent.withAlpha(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: foreground),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.25,
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: foreground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: expanded
              ? Container(
                  margin: const EdgeInsets.only(left: 12, top: 8),
                  padding: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        if (i > 0) const SizedBox(height: 6),
                        children[i],
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class DUnlistedMenu extends GetView<SellerHomePageCtrl> {
  const DUnlistedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isUnlistedSection;
      final expanded = selected || controller.unlistedExpanded.value;

      return DExpandableMenu(
        title: 'Unlisted',
        icon: Icons.business_outlined,
        selected: selected,
        expanded: expanded,
        onToggle: controller.unlistedExpanded.toggle,
        children: [
          DTabTileWidget(
            icon: Icons.business_outlined,
            title: 'Manage Company',
            tab: WTabBarEnum.preIPOList,
          ),
          DTabTileWidget(
            icon: Icons.currency_rupee,
            title: 'Update Share Price',
            tab: WTabBarEnum.priceUpdate,
          ),
        ],
      );
    });
  }
}

class DLpSecondaryMenu extends GetView<SellerHomePageCtrl> {
  const DLpSecondaryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isLpSecondarySection;
      final expanded = selected || controller.lpSecondaryExpanded.value;

      return DExpandableMenu(
        title: 'LP Secondary',
        icon: Icons.swap_horiz_rounded,
        selected: selected,
        expanded: expanded,
        onToggle: controller.lpSecondaryExpanded.toggle,
        children: [
          DTabTileWidget(
            icon: Icons.swap_horiz_rounded,
            title: 'Manage Company',
            tab: WTabBarEnum.secondaryList,
          ),
          DTabTileWidget(
            icon: Icons.handshake_outlined,
            title: 'Manage Deals',
            tab: WTabBarEnum.manageDeals,
          ),
        ],
      );
    });
  }
}

class DDealOfTheDayMenu extends GetView<SellerHomePageCtrl> {
  const DDealOfTheDayMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.isDealOfTheDayTab;
      final expanded = selected || controller.dealOfTheDayExpanded.value;

      return DExpandableMenu(
        title: 'Deal of the day',
        icon: Icons.business_center_outlined,
        selected: selected,
        expanded: expanded,
        onToggle: controller.dealOfTheDayExpanded.toggle,
        children: [
          DTabTileWidget(
            icon: Icons.business_outlined,
            title: 'Unlisted',
            tab: WTabBarEnum.companyDeals,
          ),
          DTabTileWidget(
            icon: Icons.swap_horiz_rounded,
            title: 'LP Secondary',
            tab: WTabBarEnum.secondaryDeals,
          ),
        ],
      );
    });
  }
}
