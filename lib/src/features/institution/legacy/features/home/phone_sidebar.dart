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
          DTabTileWidget(
            icon: Icons.business_outlined,
            title: 'Unlisted Companies',
            tab: WTabBarEnum.preIPOList,
          ),
          DTabTileWidget(
            icon: Icons.swap_horiz_rounded,
            title: 'LP Secondary Companies',
            tab: WTabBarEnum.secondaryList,
          ),
          const DHotDealsMenu(),
          DTabTileWidget(
            icon: Icons.currency_rupee,
            title: 'Update Unlisted Share Price',
            tab: WTabBarEnum.priceUpdate,
          ),
          DTabTileWidget(
            icon: Icons.sell_outlined,
            title: 'Sell Enquiries',
            tab: WTabBarEnum.sellEnquiries,
          ),
          // const SizedBox(height: 4),
          const DTransactionsMenu(),
          const SizedBox(height: 8),
          DTabTileWidget(
            icon: Icons.people_outline,
            title: 'Investors & CML',
            tab: WTabBarEnum.investors,
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          //   child: Divider(height: 1, color: muted.withValues(alpha: 0.35)),
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 14, bottom: 10),
          //   child: Text(
          //     'ACCOUNT',
          //     style: TextStyle(
          //       color: muted,
          //       fontSize: 10,
          //       fontWeight: FontWeight.w600,
          //       letterSpacing: 1.6,
          //     ),
          //   ),
          // ),
          // DTabTileWidget(
          //   icon: Icons.person_outline_rounded,
          //   title: 'Profile',
          //   tab: WTabBarEnum.profile,
          // ),
          // DTabTileWidget(
          //   icon: Icons.lock_outline,
          //   title: 'Change Password',
          //   tab: WTabBarEnum.changePassword,
          // ),
          // DActionTileWidget(
          //   icon: Icons.delete_outline,
          //   title: 'Delete Account',
          //   destructive: true,
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       showCustomDialog(
          //         DeleteAccountDialog(
          //           title: 'Permanently Delete',
          //           onDelete: () async {
          //             Get.back();
          //             await WAuthApi.deleteAccount();
          //             await app.setUser(prefUser: {});
          //             await Get.offAllNamed(Routes.signIn);
          //           },
          //         ),
          //       );
          //     });
          //   },
          // ),
          // DActionTileWidget(
          //   icon: Icons.logout,
          //   title: 'Logout',
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       showCustomDialog(
          //         LogoutDialog(
          //           onPressed: () async {
          //             Get.back();
          //             await WAuthApi.logout();
          //             await app.setUser(prefUser: {});
          //             await Get.offAllNamed(Routes.signIn);
          //           },
          //         ),
          //       );
          //     });
          //   },
          // ),
        ],
      ),
    );
  }
}
