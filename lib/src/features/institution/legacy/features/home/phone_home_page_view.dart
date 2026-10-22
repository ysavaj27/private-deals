import 'package:private_deals/src/shared/widgets/custom_appbar.dart'
    show WAppbarOptionSegmented;
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
        final showUnlistedSubTabs = c.isUnlistedSection;
        final showLpSecondarySubTabs = c.isLpSecondarySection;

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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                64 + (showUnlistedSubTabs || showLpSecondarySubTabs ? 48 : 0),
              ),
              child: Column(
                children: [
                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: WAppbarOptionSegmented(institution: true),
                  ),
                  if (showUnlistedSubTabs)
                    _PhoneSubTabBar(
                      options: const [
                        (WTabBarEnum.preIPOList, 'Manage Company'),
                        (WTabBarEnum.priceUpdate, 'Share Price'),
                      ],
                      selected: c.currentTab.value,
                      onSelected: c.onTap,
                    ),
                  if (showLpSecondarySubTabs)
                    _PhoneSubTabBar(
                      options: const [
                        (WTabBarEnum.secondaryList, 'Manage Company'),
                        (WTabBarEnum.manageDeals, 'Manage Deals'),
                      ],
                      selected: c.currentTab.value,
                      onSelected: c.onTap,
                    ),
                ],
              ),
            ),
          ),
          drawer: const Drawer(child: SafeArea(child: PSideBarWidget())),
          body: SafeArea(
            top: false,
            bottom: false,
            child: child ?? MainWidgets(),
          ),
          bottomNavigationBar: _SellerPhoneNavBar(
            selectedIndex: c.phoneNavIndex.clamp(0, 5),
            onSelected: c.onPhoneNavTap,
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

class _SellerPhoneNavBar extends StatelessWidget {
  const _SellerPhoneNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _destinations = <(IconData, IconData, String)>[
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Transactions'),
    (Icons.business_outlined, Icons.business, 'Company'),
    (Icons.sell_outlined, Icons.sell, 'Enquiries'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet,
      'Portfolio',
    ),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelMedium;

    return Material(
      color: scheme.surfaceContainer,
      elevation: 3,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _destinations.length,
            itemBuilder: (context, index) {
              final destination = _destinations[index];
              final selected = index == selectedIndex;
              return Semantics(
                button: true,
                selected: selected,
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 84,
                      minHeight: 48,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: selected
                                  ? scheme.secondaryContainer
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              width: 64,
                              height: 32,
                              child: Icon(
                                selected ? destination.$2 : destination.$1,
                                size: 24,
                                color: selected
                                    ? scheme.onSecondaryContainer
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination.$3,
                            maxLines: 1,
                            softWrap: false,
                            style: labelStyle?.copyWith(
                              color: selected
                                  ? scheme.onSurface
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
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
