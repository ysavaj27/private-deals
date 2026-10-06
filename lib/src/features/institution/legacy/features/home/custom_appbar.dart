import 'package:private_deals/src/shared/widgets/header_action.dart';
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
    return AppBar(title: Text(title), actions: actions);
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
    final colors = Theme.of(context).colorScheme;
    final background = colors.surfaceContainerLow;
    final border = colors.outlineVariant;
    final foreground = colors.onSurface;
    final accent = colors.onPrimaryContainer;

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
                            color: colors.primaryContainer,
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
                  // HeaderAction(
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

                    return HeaderAction(
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

class DropdownMenuWidget extends StatelessWidget {
  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

  DropdownMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = colors.onPrimaryContainer;
    final border = colors.outlineVariant;

    return PopupMenuButton<MenuItemEnum>(
      // enabled: !context.isPhone,
      position: PopupMenuPosition.under,
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      tooltip: 'Account menu',
      color: colors.surfaceContainer,
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
          color: colors.primaryContainer,
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
              placeHolderImage: app.wUser.placeholderImage,
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
