import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/user/user_model.dart';

import 'package:private_deals/src/features/institution/legacy/features/auth/profile/phone_profile_view.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page_ctrl.dart';

// ==================== PAGE ====================

/// Profile tab entry — phone shows summary; desktop shows full detail.
class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return const PhoneProfileView();
    }
    return const ProfileDetailView();
  }
}

/// Full profile (desktop layout). Also used when phone taps “View profile”.
class ProfileDetailView extends StatelessWidget {
  const ProfileDetailView({super.key, this.showPageTitle = true});

  final bool showPageTitle;

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;

    return GetX<SellerProfilePageCtrl>(
      init: SellerProfilePageCtrl(),
      builder: (controller) {
        final profile = controller.profile.value;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshProfile();
            controller.logo.value = null;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isPhone ? 16 : 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showPageTitle) ...[
                      Text(
                        'My profile',
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your company, contact and account information.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _ProfileHeader(profile: profile, controller: controller),
                    if (controller.error.value.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        controller.error.value,
                        style: TextStyle(
                          color: context.theme.colorScheme.error,
                        ),
                      ),
                      if (!controller.editing.value)
                        TextButton(
                          onPressed:
                              controller.loading.value ||
                                  controller.saving.value
                              ? null
                              : () async {
                                  if (await controller.refreshProfile()) {
                                    controller.logo.value = null;
                                  }
                                },
                          child: const Text('Retry refresh'),
                        ),
                    ],
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: 'Company details',
                      icon: Icons.business_outlined,
                      fields: [
                        _ProfileField(
                          label: 'Company name',
                          value: profile.companyName,
                        ),
                        _ProfileField(
                          label: 'CIN',
                          value: profile.cin,
                          copyable: true,
                        ),
                        _ProfileField(
                          label: 'PAN',
                          value: profile.pan,
                          copyable: true,
                        ),
                        _ProfileField(label: 'Address', value: profile.address),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: 'Contact details',
                      icon: Icons.contact_mail_outlined,
                      fields: [
                        _ProfileField(
                          label: 'Email address',
                          value: profile.email,
                          copyable: true,
                        ),
                        _ProfileField(
                          label: 'Mobile number',
                          value: profile.mobileNumber,
                          copyable: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: 'Demat account',
                      icon: Icons.account_balance_wallet_outlined,
                      fields: [
                        _ProfileField(
                          label: 'DP ID',
                          value: profile.dpId,
                          copyable: true,
                        ),
                        _ProfileField(
                          label: 'Client ID',
                          value: profile.clientId,
                          copyable: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: 'Bank details',
                      icon: Icons.account_balance_outlined,
                      fields: [
                        _ProfileField(
                          label: 'Bank name',
                          value: profile.bankName,
                        ),
                        _ProfileField(
                          label: 'Account number',
                          value: profile.accountNumber,
                          copyable: true,
                        ),
                        _ProfileField(
                          label: 'IFSC',
                          value: profile.ifsc,
                          copyable: true,
                        ),
                        _ProfileField(label: 'Branch', value: profile.branch),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _ProfileSection(
                      title: 'Account information',
                      icon: Icons.info_outline_rounded,
                      fields: [
                        _ProfileField(
                          label: 'Account status',
                          value: profile.accountStatus,
                        ),
                        _ProfileField(
                          label: 'Password change required',
                          value: profile.askPasswordChange ? 'Yes' : 'No',
                        ),
                        _ProfileField(
                          label: 'Created on (IST)',
                          value: formatProfileDate(profile.createdAt),
                        ),
                        _ProfileField(
                          label: 'Last updated (IST)',
                          value: formatProfileDate(profile.updatedAt),
                        ),
                      ],
                    ),
                    if (isPhone) const SizedBox(height: 24),
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

/// Full-screen wrapper used when opening detail from the phone summary tab.
class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: const ProfileDetailView(showPageTitle: false),
    );
  }
}

// ==================== PROFILE HEADER ====================

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.controller});

  final SellerProfilePageCtrl controller;
  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;

    return Obx(() {
      final selectedLogo = controller.logo.value;
      final saving = controller.saving.value;
      final picking = controller.picking.value;
      final editing = controller.editing.value;
      return Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(context.isPhone ? 16 : 24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 560 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;

              final avatar = Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: selectedLogo?.uint8list != null
                    ? Image.memory(selectedLogo!.uint8list!, fit: BoxFit.cover)
                    : profile.logo.isNotEmpty
                    ? Image.network(
                        profile.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stack) => Icon(
                          Icons.business_rounded,
                          color: scheme.onPrimaryContainer,
                        ),
                      )
                    : Icon(
                        Icons.business_rounded,
                        size: 32,
                        color: scheme.onPrimaryContainer,
                      ),
              );

              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.companyName.isEmpty
                        ? 'Seller account'
                        : profile.companyName,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (profile.email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      profile.email,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              );

              final status = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileStatus(profile: profile),
                  const SizedBox(height: 12),
                  if (!editing)
                    OutlinedButton.icon(
                      onPressed: saving ? null : controller.edit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit profile'),
                    )
                  else ...[
                    const Text('Only your logo can be edited. Maximum 2 MB.'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: picking || saving
                              ? null
                              : controller.pickLogo,
                          child: Text(picking ? 'Selecting…' : 'Choose logo'),
                        ),
                        FilledButton(
                          onPressed: saving || picking || selectedLogo == null
                              ? null
                              : controller.save,
                          child: Text(saving ? 'Saving…' : 'Save'),
                        ),
                        TextButton(
                          onPressed: saving || picking
                              ? null
                              : controller.cancel,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    avatar,
                    const SizedBox(height: 16),
                    details,
                    const SizedBox(height: 16),
                    status,
                  ],
                );
              }

              return Row(
                children: [
                  avatar,
                  const SizedBox(width: 20),
                  Expanded(child: details),
                  const SizedBox(width: 20),
                  Flexible(child: status),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

// ==================== STATUS BADGE ====================

class _ProfileStatus extends StatelessWidget {
  const _ProfileStatus({required this.profile});

  final UserModel profile;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final dark = context.theme.brightness == Brightness.dark;

    final Color foreground;
    final Color background;

    if (profile.isDeleted) {
      foreground = scheme.onSurfaceVariant;
      background = scheme.surfaceContainerHighest;
    } else if (profile.isBlocked) {
      foreground = scheme.onErrorContainer;
      background = scheme.errorContainer;
    } else {
      foreground = dark ? const Color(0xFF6BDDB2) : const Color(0xFF167451);
      background = foreground.withValues(alpha: 0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        profile.accountStatus,
        style: context.textTheme.labelLarge?.copyWith(color: foreground),
      ),
    );
  }
}

// ==================== SECTION CARD ====================

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.fields,
  });

  final String title;
  final IconData icon;
  final List<_ProfileField> fields;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(context.isPhone ? 16 : 20),
            child: Row(
              children: [
                Icon(icon, size: 22, color: context.theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: context.textTheme.titleMedium),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(context.isPhone ? 16 : 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final singleColumn =
                    constraints.maxWidth < 600 ||
                    MediaQuery.textScalerOf(context).scale(16) > 24;

                const spacing = 28.0;

                final width = singleColumn
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: 24,
                  children: fields.map((field) {
                    return SizedBox(width: width, child: field);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== READ-ONLY FIELD ====================

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final trimmed = value.trim();
    final display = trimmed.isEmpty ? '—' : value;
    final canCopy = copyable && trimmed.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                display,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (canCopy)
              IconButton(
                tooltip: 'Copy $label',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: trimmed));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$label copied'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: context.theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ==================== DATE FORMAT ====================

String formatProfileDate(DateTime? value) {
  if (value == null) return '';

  final date = value.toUtc().add(const Duration(hours: 5, minutes: 30));

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'AM' : 'PM';

  return '${date.day} ${months[date.month - 1]} ${date.year}, '
      '$hour:$minute $period';
}
