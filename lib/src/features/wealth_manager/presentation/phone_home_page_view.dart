import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/investor_filter_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/phone_sidebar.dart';

class PhoneHomePageView extends StatelessWidget {
  final Widget? child;
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  PhoneHomePageView({super.key, this.child});

  final GlobalKey _one = GlobalKey();

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
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        );
      },
      child: ShowCaseWidget(
        builder: (context) {
          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   ShowCaseWidget.of(context).startShowCase([_one]);
          // });
          return Obx(() {
            return Scaffold(
              appBar: AppBar(
                title: Text(c.appBarName),
                actions: [
                  Obx(() {
                    return IconButton(
                      tooltip: 'Toggle theme',
                      onPressed: () async {
                        await init.changeTheme();
                        if (init.themeModes() == ThemeMode.dark) {
                          await AppTheme.getTheme();
                        }
                      },
                      icon: SVGImage(
                        icon,
                        colorFilter: ColorFilter.mode(
                          context.textTheme.titleMedium?.color ?? Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  }),
                  Obx(() {
                    return Visibility(
                      visible:
                          c.currentTab() == WTabBarEnum.investors &&
                          child == null,
                      child: IconButton(
                        tooltip: 'Filter investors',
                        onPressed: () {
                          showCustomDialog(const InvestorFilterDialog());
                        },
                        icon: SVGImage(
                          AppAssets.filterIc,
                          colorFilter: ColorFilter.mode(
                            context.theme.primaryColor,
                            BlendMode.srcIn,
                          ),
                          height: 24,
                          width: 24,
                        ),
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Showcase(
                      key: _one,
                      description: 'Here you can see all the notifications',
                      child: IconButton(
                        tooltip: 'Notifications',
                        splashRadius: 20,
                        onPressed: () {
                          Get.toNamed(Routes.notificationPage);
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: context.theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              drawer: Drawer(child: SafeArea(child: PSideBarWidget())),
              body: child ?? MainWidgets(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Semantics(
                label: 'Switch investment section',
                button: true,
                child: SpeedDial(
                  animatedIcon: AnimatedIcons.home_menu,
                  backgroundColor: context.theme.primaryColor,
                  children: [
                    SpeedDialChild(
                      child: const RotatedBox(
                        quarterTurns: 1,
                        child: Icon(Icons.swap_vert, color: Colors.white),
                      ),
                      backgroundColor: context.sectionAccents.privateEquity,
                      label: "Private Equity",
                      labelStyle: context.textTheme.titleMedium,
                      onTap: () async {
                        await prefs.setValue(
                          key: 'title',
                          value: 'Private Equity',
                        );
                        await AppTheme.setTheme(index: 0);
                        c.onTap(WTabBarEnum.primary);
                        c.closeMenu();
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.repeat, color: Colors.white),
                      backgroundColor: context.sectionAccents.lpSecondary,
                      label: "LP Secondary",
                      labelStyle: context.textTheme.titleMedium,
                      onTap: () async {
                        await prefs.setValue(
                          key: 'title',
                          value: 'LP Secondary',
                        );
                        await AppTheme.setTheme(index: 1);
                        c.onTap(WTabBarEnum.secondary);
                        c.closeMenu();
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.insights, color: Colors.white),
                      backgroundColor: context.sectionAccents.unlistedShares,
                      label: "Unlisted Shares",
                      labelStyle: context.textTheme.titleMedium,
                      onTap: () async {
                        await prefs.setValue(
                          key: 'title',
                          value: 'Unlisted Shares',
                        );
                        await AppTheme.setTheme(index: 2);
                        c.onTap(WTabBarEnum.preIPO);
                        c.closeMenu();
                      },
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                color: context.theme.colorScheme.surfaceContainerLow,
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                height: 68,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CustomNavigationIcon(
                      type: WTabBarEnum.dashboard,
                      icon: AppAssets.dashboardIc2,
                      label: 'Home',
                      size: 22,
                    ),
                    CustomNavigationIcon(
                      type: WTabBarEnum.investorTransactions,
                      icon: AppAssets.transactionIc,
                      label: 'Txns',
                      size: 22,
                    ),
                    const SizedBox(width: 48),
                    CustomNavigationIcon(
                      type: WTabBarEnum.portfolio,
                      icon: AppAssets.sendDocumentsIc,
                      label: 'Portfolio',
                      size: 24,
                    ),
                    CustomNavigationIcon(
                      type: WTabBarEnum.profile,
                      icon: AppAssets.profileIc,
                      label: 'Profile',
                      size: 24,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  String get icon {
    switch (init.themeModes()) {
      case ThemeMode.light:
        return AppAssets.darkModeBg;
      case ThemeMode.system:
        return AppAssets.lightModeBg;
      case ThemeMode.dark:
        return AppAssets.lightModeBg;
    }
  }
}

class CustomNavigationIcon extends StatelessWidget {
  final WTabBarEnum? type;
  final String icon;
  final String label;
  final HomePageCtrl c = Get.find<HomePageCtrl>();
  final double size;
  final void Function()? onPressed;

  CustomNavigationIcon({
    super.key,
    this.type,
    required this.icon,
    required this.label,
    required this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = type == c.currentTab();
      final color = isSelected
          ? context.theme.primaryColor
          : context.theme.colorScheme.onSurfaceVariant;
      return Semantics(
        label: label,
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap:
              onPressed ??
              () {
                c.currentTab(type);
              },
          borderRadius: AppRadii.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SVGImage(
                  icon,
                  height: size,
                  width: size,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
