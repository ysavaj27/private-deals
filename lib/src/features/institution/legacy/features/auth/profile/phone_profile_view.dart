import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/user/user_model.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/router/routes/routes.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/init_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/functions/dialog.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/delete_dialog_widget.dart';
import 'package:private_deals/src/features/institution/legacy/utils/widgets/dialog_widget/logout_dialog.dart';

import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page_ctrl.dart';

/// Phone profile tab — basic identity + account actions only.
class PhoneProfileView extends StatelessWidget {
  const PhoneProfileView({super.key});

  double _completion(UserModel profile) {
    final values = [
      profile.companyName,
      profile.email,
      profile.mobileNumber,
      profile.cin,
      profile.pan,
      profile.address,
      profile.logo,
      profile.bankName,
      profile.accountNumber,
      profile.ifsc,
      profile.dpId,
      profile.clientId,
    ];
    final filled = values.where((v) => v.trim().isNotEmpty).length;
    return filled / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return GetX<SellerProfilePageCtrl>(
      init: SellerProfilePageCtrl(),
      builder: (controller) {
        final profile = controller.profile.value;
        final colors = context.theme.colorScheme;
        final percent = (_completion(profile) * 100).round();
        final troubled = profile.isBlocked || profile.isDeleted;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshProfile();
            controller.logo.value = null;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              if (controller.error.value.isNotEmpty) ...[
                Material(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            controller.error.value,
                            style: TextStyle(color: colors.onErrorContainer),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.loading.value
                              ? null
                              : () async {
                                  if (await controller.refreshProfile()) {
                                    controller.logo.value = null;
                                  }
                                },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Material(
                color: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: profile.logo.isNotEmpty
                            ? Image.network(
                                profile.logo,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stack) => Icon(
                                  Icons.business_rounded,
                                  size: 32,
                                  color: colors.onPrimaryContainer,
                                ),
                              )
                            : Icon(
                                Icons.business_rounded,
                                size: 32,
                                color: colors.onPrimaryContainer,
                              ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        profile.companyName.isEmpty
                            ? 'Seller account'
                            : profile.companyName,
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _StatusChip(
                            label: profile.accountStatus,
                            success: !troubled,
                          ),
                          _StatusChip(
                            label: '$percent% complete',
                            success: percent >= 100,
                            neutral: percent < 100,
                          ),
                        ],
                      ),
                      if (profile.email.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _ContactLine(
                          icon: Icons.mail_outline_rounded,
                          text: profile.email,
                        ),
                      ],
                      if (profile.mobileNumber.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _ContactLine(
                          icon: Icons.call_outlined,
                          text: profile.mobileNumber,
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () =>
                              Get.to(() => const ProfileDetailPage()),
                          child: const Text('View profile'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'ACCOUNT',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () => Get.find<SellerHomePageCtrl>().onTap(
                  WTabBarEnum.changePassword,
                ),
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Change password'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
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
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  showCustomDialog(
                    DeleteAccountDialog(
                      title: 'Permanently Delete',
                      onDelete: () async {
                        Get.back();
                        await WAuthApi.deleteAccount();
                        await app.setUser(prefUser: {});
                        await Get.offAllNamed(Routes.signIn);
                      },
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: colors.error),
                child: const Text('Delete account'),
              ),
              const SizedBox(height: 16),
              Text(
                'v${init.packageVersion}',
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.45),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.success = false,
    this.neutral = false,
  });

  final String label;
  final bool success;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final Color bg;
    final Color fg;

    if (success) {
      bg = const Color(0xFF26A88A).withValues(alpha: 0.14);
      fg = const Color(0xFF167451);
    } else if (neutral) {
      bg = colors.primaryContainer;
      fg = colors.onPrimaryContainer;
    } else {
      bg = colors.errorContainer;
      fg = colors.onErrorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = context.theme.colorScheme.onSurface.withValues(alpha: 0.7);
    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ),
      ],
    );
  }
}
