import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class PhoneAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const PhoneAppBar({super.key, this.title = '', this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      // iconTheme: const IconThemeData(color: context.theme.colorScheme.onSurfaceVariant),
      // backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: Border(
        bottom: BorderSide(color: context.theme.colorScheme.outlineVariant),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBar extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const CustomAppBar({super.key, this.title = '', this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: context.theme.colorScheme.outlineVariant),
        ),
      ),
      width: context.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.end,
        children: [
          /*Clickable(
            onTap: () {
              Get.offAllNamed(
                Routes.option,
              );
            },
            child: CustomCardWidget(
              radius: 8,
              color: context.theme.primaryColor.withValues(alpha: 0.1),
              borderColor: context.theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // SizedBox(width: 10),
                  FutureBuilder(
                    future: prefs.getValue(key: 'title'),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data != null ? snapshot.data.toString() : "",
                        style: const TextStyle(
                          fontSize: 20,
                          // color: context.theme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    // color: context.theme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),*/
          // WAppbarOptionSwitcher(),
          // SizedBox(width: 10),
          WAppbarOptionSegmented(),
          const Spacer(),
          Clickable(
            onTap: onPressed,
            // borderRadius: BorderRadius.circular(50),
            child: CustomCardWidget(
              radius: 12,
              color: context.theme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications_outlined,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Obx(() {
            return Clickable(
              onTap: () async {
                await init.changeTheme();
                if (init.themeModes() == ThemeMode.dark) {
                  await AppTheme.getTheme();
                }
              },
              // borderRadius: BorderRadius.circular(50),
              child: CustomCardWidget(
                radius: 12,
                color: context.theme.scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SVGImage(
                    icon,
                    colorFilter: ColorFilter.mode(
                      context.textTheme.titleMedium?.color ?? Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 15),
          DropdownMenuWidget(),
        ],
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

class DropdownMenuWidget extends StatelessWidget {
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  DropdownMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItemEnum>(
      // enabled: !context.isPhone,
      position: PopupMenuPosition.under,
      style: ButtonStyle(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
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
                  await SessionNavigation.logout();
                },
              ),
            );
            break;
          case MenuItemEnum.deleteAccount:
            showCustomDialog(
              DeleteAccountDialog(
                title: "Permanently Delete",
                onDelete: () async {
                  await WAuthApi.deleteAccount();
                  await Get.offAllNamed(Routes.signIn);
                  await app.setUser(prefUser: {});
                },
              ),
            );
            break;
          case MenuItemEnum.none:
            break;
        }
        app.currentMenu(result);
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
      child: Obx(() {
        // logger.d("Logo :${app.user.startup.logoFile}");
        return SizedBox(
          height: 54,
          width: 54,
          child: app.wUser.profilePhoto.isEmpty
              ? SVGImage(app.wUser.placeholderImage)
              : CacheImage(
                  imageBuilder: (p0, p1) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.logoBgColor(context),
                        image: DecorationImage(image: p1, fit: BoxFit.contain),
                      ),
                    );
                  },
                  url: app.wUser.profile,
                  errorWidget: (p0, p1, p2) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.logoBgColor(context),
                      ),
                      child: SVGImage(app.wUser.placeholderImage),
                    );
                  },
                ),
        );

        // return CircleAvatar(
        //     radius: 27,
        //     foregroundImage: CachedNetworkImageProvider(
        //       app.user.photo,
        //     ));
      }),
    );
  }
}

class WAppbarOptionSegmented extends StatelessWidget {
  const WAppbarOptionSegmented({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: prefs.getValue(key: 'title').then((v) => v is String ? v : null),
      builder: (context, snapshot) {
        final currentTitle = snapshot.data;
        final visible = wLandingOptions.where((o) => o.isVisible()).toList();
        if (visible.isEmpty) return const SizedBox.shrink();

        final c = _SwitcherColors.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < visible.length; i++) ...[
                _SegmentButton(
                  option: visible[i],
                  selected: visible[i].title == currentTitle,
                  onTap: () => _selectLandingOption(visible[i]),
                ),
                if (i != visible.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SegmentButton extends StatefulWidget {
  final WLandingOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SegmentButton> createState() => _SegmentButtonState();
}

class _SegmentButtonState extends State<_SegmentButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final c = _SwitcherColors.of(context);
    final selected = widget.selected;

    final colors = context.theme.colorScheme;
    final selectedFg = colors.onPrimaryContainer;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer
                : (_hover ? colors.surfaceContainerHigh : Colors.transparent),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? colors.outlineVariant : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                o.icon,
                size: 16,
                color: selected ? selectedFg : c.titleText,
              ),
              const SizedBox(width: 7),
              Text(
                o.title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? selectedFg : c.titleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitcherColors {
  final Color surface;
  final Color border;
  final Color shadow;
  final Color titleText;
  final Color subtitleText;
  final Color hoverOverlayBoost; // multiplier feel, used as alpha bump

  const _SwitcherColors({
    required this.surface,
    required this.border,
    required this.shadow,
    required this.titleText,
    required this.subtitleText,
    required this.hoverOverlayBoost,
  });

  static _SwitcherColors of(BuildContext context) {
    final colors = context.theme.colorScheme;
    return _SwitcherColors(
      surface: colors.surfaceContainerLow,
      border: colors.outlineVariant,
      shadow: Colors.black.withValues(alpha: context.isDarkMode ? 0.20 : 0.06),
      titleText: colors.onSurface,
      subtitleText: colors.onSurfaceVariant,
      hoverOverlayBoost: Colors.transparent,
    );
  }
}

Future<void> _selectLandingOption(WLandingOption option) async {
  await prefs.setValue(key: 'title', value: option.title);
  await AppTheme.setTheme(index: option.themeIndex);
  Get.offAllNamed('/wealth-manager/${option.slug}');
}

class WAppbarOptionSwitcher extends StatefulWidget {
  const WAppbarOptionSwitcher({super.key});

  @override
  State<WAppbarOptionSwitcher> createState() => _WAppbarOptionSwitcherState();
}

class _WAppbarOptionSwitcherState extends State<WAppbarOptionSwitcher>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
  );
  bool _open = false;

  WLandingOption? _current(dynamic title) {
    if (title == null) return null;
    for (final o in wLandingOptions) {
      if (o.title == title) return o;
    }
    return null;
  }

  void _toggle(WLandingOption? current) {
    if (_open) {
      _close();
    } else {
      _openMenu(current);
    }
  }

  void _openMenu(WLandingOption? current) {
    final visible = wLandingOptions.where((o) => o.isVisible()).toList();
    if (visible.isEmpty) return;

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap-away catcher
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 8),
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              child: FadeTransition(
                opacity: _anim,
                child: ScaleTransition(
                  scale: Tween(begin: 0.96, end: 1.0).animate(
                    CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
                  ),
                  alignment: Alignment.topLeft,
                  // was topRight — keeps the scale-in anchored to the same corner
                  child: Material(
                    color: Colors.transparent,
                    child: Builder(
                      builder: (context) {
                        final c = _SwitcherColors.of(context);
                        return Container(
                          width: 300,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: c.border),
                            boxShadow: [
                              BoxShadow(
                                color: c.shadow,
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < visible.length; i++) ...[
                                _OptionRow(
                                  option: visible[i],
                                  selected: current?.title == visible[i].title,
                                  onTap: () {
                                    _close();
                                    _selectLandingOption(visible[i]);
                                  },
                                ),
                                if (i != visible.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: c.border,
                                  ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_entry!);
    setState(() => _open = true);
    _anim.forward(from: 0);
  }

  void _close() {
    if (!_open) return;
    _anim.reverse().whenComplete(() {
      _entry?.remove();
      _entry = null;
    });
    setState(() => _open = false);
  }

  @override
  void dispose() {
    _entry?.remove();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: prefs.getValue(key: 'title').then((v) => v is String ? v : null),
      builder: (context, snapshot) {
        final current = _current(snapshot.data);
        final accent = context.theme.colorScheme.primary;
        final c = _SwitcherColors.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return CompositedTransformTarget(
          link: _link,
          child: Material(
            color: Colors.transparent,
            child: Clickable(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _toggle(current),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                // padding: EdgeInsets.symmetric(horizontal: 20,vertical: 12),
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 20,
                  top: 12,
                  bottom: 12,
                ),
                decoration: BoxDecoration(
                  // Blend accent over the surface tone so it reads as a chip against
                  // BOTH pure-black and pure-white backdrops, not just alpha-over-transparent.
                  color: Color.alphaBlend(
                    accent.withValues(alpha: isDark ? 0.1 : 0.14),
                    context.theme.colorScheme.surfaceContainerLow,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 26,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      current?.title ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: c.titleText,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OptionRow extends StatefulWidget {
  final WLandingOption option;
  final bool selected;
  final VoidCallback onTap;

  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.option;
    final c = _SwitcherColors.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Clickable(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hover
              ? context.theme.colorScheme.surfaceContainerHigh
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  o.icon,
                  size: 18,
                  color: context.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.titleText,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      o.subTitle,
                      style: TextStyle(fontSize: 11.5, color: c.subtitleText),
                    ),
                  ],
                ),
              ),
              if (widget.selected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WLandingOption {
  final String title;
  final String subTitle;
  final Color color;
  final IconData icon;
  final int themeIndex;
  final String slug;
  final bool Function() isVisible;

  const WLandingOption({
    required this.title,
    required this.subTitle,
    required this.color,
    required this.icon,
    required this.themeIndex,
    required this.slug,
    required this.isVisible,
  });
}

final List<WLandingOption> wLandingOptions = [
  WLandingOption(
    title: 'Private Equity',
    subTitle: 'Early-stage start-up investing',
    color: AppColors.sectionPrivateEquity,
    icon: Icons.trending_up_rounded,
    themeIndex: 0,
    slug: WTabBarEnum.primary.slug,
    isVisible: () => app.wUser.isPrimaryAccess,
  ),
  WLandingOption(
    title: 'LP Secondary',
    subTitle: 'Liquidity for existing portfolios',
    color: AppColors.sectionLpSecondary,
    icon: Icons.swap_horiz_rounded,
    themeIndex: 1,
    slug: WTabBarEnum.secondary.slug,
    isVisible: () => app.wUser.isSecondaryAccess,
  ),
  WLandingOption(
    title: 'Unlisted Shares',
    subTitle: 'Pre-IPO company access',
    color: AppColors.sectionUnlistedShares,
    icon: Icons.workspace_premium_rounded,
    themeIndex: 2,
    slug: WTabBarEnum.preIPO.slug,
    isVisible: () => app.wUser.isPreIpoAccess,
  ),
];
