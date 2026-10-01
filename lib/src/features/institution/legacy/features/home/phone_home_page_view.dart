import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/core/configuration/init_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/functions/dialog.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/dialog_widget/logout_dialog.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/home_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/phone_sidebar.dart';

class PhoneHomePageView extends StatelessWidget {
  final Widget? child;
  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

  PhoneHomePageView({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        showCustomDialog(
          LogoutDialog(
            title: 'Are you sure?',
            subTitle: 'Do you want to exit the App?',
            primaryText: 'Yes',
            secondaryText: 'No',
            onPressed: () {
              Get.back();
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        );
      },
      child: Obx(() {
        final showCompanyTabs = c.isCompanyTab;
        final showTransactionTabs = c.isTransactionTab;

        return Scaffold(
          appBar: AppBar(
            title: Text(c.appBarName),
            actions: [
              Obx(() {
                return IconButton(
                  onPressed: () async {
                    await init.changeTheme();
                    if (init.themeModes() == ThemeMode.dark) {
                      await AppTheme.getTheme();
                    }
                  },
                  icon: Icon(icon),
                );
              }),
            ],
            bottom: showCompanyTabs || showTransactionTabs
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: showCompanyTabs
                        ? _PhoneSubTabBar(
                            options: const [
                              (WTabBarEnum.preIPOList, 'Unlisted'),
                              (WTabBarEnum.secondaryList, 'LP Secondary'),
                            ],
                            selected: c.currentTab.value,
                            onSelected: c.onTap,
                          )
                        : _PhoneSubTabBar(
                            options: const [
                              (WTabBarEnum.preIPOTransactions, 'Unlisted'),
                              (
                                WTabBarEnum.secondaryTransactions,
                                'LP Secondary',
                              ),
                            ],
                            selected: c.currentTab.value,
                            onSelected: c.onTap,
                          ),
                  )
                : null,
          ),
          drawer: const Drawer(child: SafeArea(child: PSideBarWidget())),
          body: SafeArea(top: false, child: child ?? MainWidgets()),
          bottomNavigationBar: NavigationBar(
            selectedIndex: c.phoneNavIndex.clamp(0, 4),
            onDestinationSelected: c.onPhoneNavTap,
            height: 68,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Transactions',
              ),
              NavigationDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: 'Company',
              ),
              NavigationDestination(
                icon: Icon(Icons.currency_rupee),
                selectedIcon: Icon(Icons.currency_rupee),
                label: 'Share Price',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData get icon {
    switch (init.themeModes()) {
      case ThemeMode.light:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_6;
      case ThemeMode.dark:
        return Icons.light_mode;
    }
  }
}

class _PhoneSubTabBar extends StatelessWidget {
  const _PhoneSubTabBar({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(WTabBarEnum, String)> options;
  final WTabBarEnum selected;
  final void Function(WTabBarEnum tab) onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SegmentedButton<WTabBarEnum>(
        segments: [
          for (final option in options)
            ButtonSegment<WTabBarEnum>(
              value: option.$1,
              label: Text(option.$2, overflow: TextOverflow.ellipsis),
            ),
        ],
        selected: {selected},
        onSelectionChanged: (values) {
          if (values.isNotEmpty) onSelected(values.first);
        },
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
