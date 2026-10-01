import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/legacy/router/routes/routes.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/init_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/functions/dialog.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/delete_dialog_widget.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/dialog_widget/logout_dialog.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';

class PhoneAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const PhoneAppBar({super.key, this.title = '', this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      // iconTheme: const IconThemeData(color: context.theme.primaryColor),
      // backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const CustomAppBar({super.key, this.title = '', this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFFF7F9FC);
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1);
    final foreground = isDark
        ? const Color(0xFFF0F6FC)
        : const Color(0xFF1A2233);
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    // final foreground = isDark
    //     ? const Color(0xFFF0F6FC)
    //     : const Color(0xFF1A2233);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 24,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: compact ? 18 : 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // _AppBarAction(
                  //   icon: Icons.notifications_outlined,
                  //   tooltip: 'Notifications',
                  //   onPressed: onPressed,
                  // ),
                  // const SizedBox(width: 8),
                  Obx(() {
                    final mode = init.themeModes();

                    final IconData icon;
                    final String tooltip;

                    switch (mode) {
                      case ThemeMode.light:
                        icon = Icons.dark_mode_outlined;
                        tooltip = 'Change theme · currently light';
                        break;
                      case ThemeMode.dark:
                        icon = Icons.light_mode_outlined;
                        tooltip = 'Change theme · currently dark';
                        break;
                      case ThemeMode.system:
                        icon = Icons.brightness_auto_outlined;
                        tooltip = 'Change theme · follows system';
                        break;
                    }

                    return _AppBarAction(
                      icon: icon,
                      tooltip: tooltip,
                      onPressed: () async {
                        await init.changeTheme();

                        if (init.themeModes() == ThemeMode.dark) {
                          await AppTheme.getTheme();
                        }
                      },
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 16,
                    ),
                    child: SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: border,
                      ),
                    ),
                  ),
                  DropdownMenuWidget(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _AppBarAction({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);

    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          onPressed: onPressed,
          tooltip: tooltip,
          icon: Icon(icon, size: 22),
          color: accent,
          hoverColor: accent.withAlpha(18),
          focusColor: accent.withAlpha(26),
          splashColor: accent.withAlpha(30),
        ),
      ),
    );
  }
}

class DropdownMenuWidget extends StatelessWidget {
  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

  DropdownMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF8BAAD4) : const Color(0xFF2B5996);
    final border = isDark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1);

    return PopupMenuButton<MenuItemEnum>(
      // enabled: !context.isPhone,
      position: PopupMenuPosition.under,
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      tooltip: 'Account menu',
      color: isDark ? const Color(0xFF161B22) : const Color(0xFFF7F9FC),
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      onSelected: (MenuItemEnum result) {
        switch (result) {
          case MenuItemEnum.dashboard:
            // c.currentTab(WTabBarEnum.primary);
            // if (app.currentMenu() != MenuItemEnum.dashboard) {
            //   Get.offAll(() => HomePage());
            // }
            break;
          case MenuItemEnum.profile:
            break;
          case MenuItemEnum.manageBankAccounts:
            break;
          case MenuItemEnum.kyc:
            break;
          case MenuItemEnum.changePassword:
            c.onTap(WTabBarEnum.changePassword);

            break;
          case MenuItemEnum.dematAccount:
            break;
          case MenuItemEnum.switchUser:
            break;
          case MenuItemEnum.logout:
            showCustomDialog(
              LogoutDialog(
                onPressed: () async {
                  Get.back();
                  await WAuthApi.logout();
                  await app.setUser(prefUser: {});
                  await Get.offAllNamed(Routes.signIn);
                },
              ),
            );
            break;
          case MenuItemEnum.deleteAccount:
            showCustomDialog(
              DeleteAccountDialog(
                title: "Permanently Delete",
                onDelete: () async {
                  Get.back();
                  await WAuthApi.deleteAccount();
                  await app.setUser(prefUser: {});
                  await Get.offAllNamed(Routes.signIn);
                },
              ),
            );
            break;
          case MenuItemEnum.none:
            break;
        }
        // app.currentMenu(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItemEnum>>[
        // PopupMenuItem<MenuItemEnum>(
        //   mouseCursor: SystemMouseCursors.click,
        //   value: MenuItemEnum.dashboard,
        //   child: ListTile(
        //     dense: context.isPhone ? true : false,
        //     visualDensity: context.isPhone ? VisualDensity.compact : null,
        //     leading: Icon(Icons.dashboard, size: context.isPhone ? 20 : 24),
        //     title: const Text('Dashboard'),
        //   ),
        // ),
        // PopupMenuItem<MenuItemEnum>(
        //   value: MenuItemEnum.profile,
        //   child: ListTile(
        //     dense: context.isPhone ? true : false,
        //     visualDensity: context.isPhone ? VisualDensity.compact : null,
        //     leading: Icon(Icons.person, size: context.isPhone ? 20 : 24),
        //     title: const Text('Profile'),
        //   ),
        // ),
        PopupMenuItem<MenuItemEnum>(
          value: MenuItemEnum.changePassword,
          child: ListTile(
            dense: context.isPhone ? true : false,
            visualDensity: context.isPhone ? VisualDensity.compact : null,
            leading: Icon(Icons.lock, size: context.isPhone ? 20 : 24),
            title: const Text('Change Password'),
          ),
        ),
        PopupMenuDivider(height: context.isPhone ? 0 : 20),
        PopupMenuItem<MenuItemEnum>(
          value: MenuItemEnum.deleteAccount,
          child: ListTile(
            textColor: Colors.red,
            dense: context.isPhone ? true : false,
            visualDensity: context.isPhone ? VisualDensity.compact : null,
            leading: Icon(
              Icons.delete,
              size: context.isPhone ? 20 : 24,
              color: Colors.red,
            ),
            title: const Text('Delete Account'),
          ),
        ),
        PopupMenuItem<MenuItemEnum>(
          value: MenuItemEnum.logout,
          child: ListTile(
            dense: context.isPhone ? true : false,
            visualDensity: context.isPhone ? VisualDensity.compact : null,
            leading: Icon(Icons.logout, size: context.isPhone ? 20 : 24),
            title: const Text('Logout'),
          ),
        ),
      ],
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: accent.withAlpha(isDark ? 28 : 18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Obx(() {
            if (app.wUser.profilePhoto.isEmpty) {
              return Icon(
                Icons.person_outline_rounded,
                color: accent,
                size: 23,
              );
            }
            return CacheImage(
              url: app.wUser.profile,
              imageBuilder: (context, imageProvider) {
                return Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  width: 38,
                  height: 38,
                );
              },
              errorWidget: (context, url, error) {
                return Center(
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: accent,
                    size: 23,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
