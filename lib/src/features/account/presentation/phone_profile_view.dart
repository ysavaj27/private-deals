import 'package:private_deals/src/features/auth/presentation/login/login_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/account/presentation/profile_page_ctrl.dart';

class PhoneProfileView extends StatelessWidget {
  final ProfilePageCtrl c = Get.find<ProfilePageCtrl>();

  PhoneProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xl,
        vertical: AppSpace.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account', style: context.textTheme.titleLarge),
          const SizedBox(height: AppSpace.lg),
          TitleTextField(
            readOnly: true,
            name: "Full Name",
            hintText: "Enter Full Name",
            controller: c.nameCTRL,
          ),
          const SizedBox(height: AppSpace.lg),
          TitleTextField(
            readOnly: true,
            name: "Mobile",
            hintText: "Enter Mobile",
            controller: c.mobileCTRL,
          ),
          const SizedBox(height: AppSpace.lg),
          TitleTextField(
            readOnly: true,
            name: "Email",
            hintText: "Enter Email",
            controller: c.emailCTRL,
          ),
          const SizedBox(height: AppSpace.lg),
          TitleTextField(
            readOnly: true,
            name: "Commission",
            hintText: "Enter Commission",
            controller: c.commissionCTRL,
          ),
          const SizedBox(height: AppSpace.xxl),
          Text('Settings', style: context.textTheme.titleLarge),
          const SizedBox(height: AppSpace.md),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              if (Get.isRegistered<HomePageCtrl>()) {
                Get.find<HomePageCtrl>().onTap(WTabBarEnum.changePassword);
              } else {
                Get.toNamed(Routes.changePassword);
              }
            },
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: _themeLabel(),
            onTap: () async {
              await init.changeTheme();
              if (init.themeModes() == ThemeMode.dark) {
                await AppTheme.getTheme();
              }
            },
          ),
          const SizedBox(height: AppSpace.xxl),
          CustomOutlinedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_outlined, color: scheme.error),
                const SizedBox(width: AppSpace.sm),
                Text(
                  "Delete Account",
                  style: context.textTheme.labelLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            onPressed: () {
              showCustomDialog(
                DeleteAccountDialog(
                  title: "Permanently Delete",
                  onDelete: () async {
                    await WAuthApi.deleteAccount();
                    await Get.offAll(() => LoginPage());
                    await app.setUser(prefUser: {});
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _themeLabel() {
    switch (init.themeModes()) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Material(
        color: scheme.surface,
        borderRadius: AppRadii.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleSmall),
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
