import 'package:private_deals/src/features/account/presentation/profile_page_ctrl.dart';
import 'package:private_deals/src/features/account/presentation/profile_photo_section.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class DesktopProfileView extends StatelessWidget {
  final ProfilePageCtrl c = Get.find<ProfilePageCtrl>();

  DesktopProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('My Profile', style: context.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              'Account details and preferences',
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 36),
            CustomCardWidget(
              radius: AppRadii.lg,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Account', style: context.textTheme.titleMedium),
                  const SizedBox(height: 24),
                  Obx(() => ProfilePhotoSection(controller: c)),
                  Obx(() {
                    if (c.error.value.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        c.error.value,
                        style: TextStyle(color: scheme.error),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TitleTextField(
                          readOnly: true,
                          name: "Full Name",
                          hintText: "Enter Full Name",
                          controller: c.nameCTRL,
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: TitleTextField(
                          readOnly: true,
                          name: "Mobile",
                          hintText: "Enter Mobile",
                          controller: c.mobileCTRL,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TitleTextField(
                          readOnly: true,
                          name: "Email",
                          hintText: "Enter Email",
                          controller: c.emailCTRL,
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: TitleTextField(
                          readOnly: true,
                          name: "Commission",
                          hintText: "Enter Commission",
                          controller: c.commissionCTRL,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  Text('Settings', style: context.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _DesktopSettingChip(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        onTap: () {
                          if (Get.isRegistered<HomePageCtrl>()) {
                            Get.find<HomePageCtrl>()
                                .onTap(WTabBarEnum.changePassword);
                          } else {
                            Get.toNamed(Routes.changePassword);
                          }
                        },
                      ),
                      _DesktopSettingChip(
                        icon: Icons.palette_outlined,
                        label: 'Toggle theme',
                        onTap: () async {
                          await init.changeTheme();
                          if (init.themeModes() == ThemeMode.dark) {
                            await AppTheme.getTheme();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopSettingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DesktopSettingChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(label, style: context.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
