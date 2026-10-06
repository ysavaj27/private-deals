import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart';

class PSideBarWidget extends StatelessWidget {
  const PSideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    final foreground = isDark
        ? const Color(0xFFF0F6FC)
        : const Color(0xFF1A2233);
    final muted = isDark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);

    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(isDark ? 30 : 22),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    Icons.business_center_outlined,
                    color: accent,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Private Deals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: foreground,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Divider(height: 1, color: muted.withValues(alpha: 0.35)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
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
          const DUnlistedMenu(),
          const DLpSecondaryMenu(),
          const DDealOfTheDayMenu(),
          DTabTileWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Transactions',
            tab: WTabBarEnum.preIPOTransactions,
          ),
          DTabTileWidget(
            icon: Icons.sell_outlined,
            title: 'Inquiry',
            tab: WTabBarEnum.sellEnquiries,
          ),
        ],
      ),
    );
  }
}
