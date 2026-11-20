import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/account/presentation/additional_profile_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/plugins/loader.dart';

List<Widget> _optionalProfileFields(PartnerPublicProfile data) {
  final fields = <({String label, String value})>[
    if (data.yearsOfExperience.isNotEmpty)
      (label: 'Years of Experience', value: data.yearsOfExperience),
    if (data.totalTradesExecuted.isNotEmpty)
      (label: 'Total Trades Executed', value: data.totalTradesExecuted),
    if (data.totalInvestorBase.isNotEmpty)
      (label: 'Total Investor Base', value: data.totalInvestorBase),
    if (data.verifiedStatus.isNotEmpty)
      (
        label: 'Verified User / Verified Seller Status',
        value: data.verifiedStatus,
      ),
    if (data.companiesPreviouslyListed.isNotEmpty)
      (
        label: 'Companies Previously Listed / Transacted on the Platform',
        value: data.companiesPreviouslyListed,
      ),
    if (data.geographicPresence.isNotEmpty)
      (label: 'Cities / Geographic Presence', value: data.geographicPresence),
    if (data.approach.isNotEmpty)
      (label: 'How We Do It / Our Approach', value: data.approach),
  ];
  return [
    for (var i = 0; i < fields.length; i++) ...[
      if (i > 0) const SizedBox(height: 16),
      _ReadOnlyProfileField(label: fields[i].label, value: fields[i].value),
    ],
  ];
}

/// Same additional-profile card used on Institution and WM/partner profiles.
class AdditionalProfileSection extends StatelessWidget {
  const AdditionalProfileSection({super.key, this.controller});

  /// When null, registers [AdditionalProfileCtrl] via GetX for this section.
  final AdditionalProfileCtrl? controller;

  @override
  Widget build(BuildContext context) {
    final AdditionalProfileCtrl c;
    if (controller != null) {
      c = controller!;
    } else if (Get.isRegistered<AdditionalProfileCtrl>()) {
      c = Get.find<AdditionalProfileCtrl>();
    } else {
      c = Get.put(AdditionalProfileCtrl());
    }
    return Obx(() {
      // Read observables here so Obx tracks them (child build is not tracked).
      c.publicEditing.value;
      c.publicSaving.value;
      c.publicLoading.value;
      c.publicError.value;
      c.publicProfile.value;
      return _AdditionalProfileCard(controller: c);
    });
  }
}

class _AdditionalProfileCard extends StatelessWidget {
  const _AdditionalProfileCard({required this.controller});

  final AdditionalProfileCtrl controller;

  @override
  Widget build(BuildContext context) {
    final editing = controller.publicEditing.value;
    final saving = controller.publicSaving.value;
    final loading = controller.publicLoading.value;
    final error = controller.publicError.value;
    final data = controller.publicProfile.value;

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
                Icon(
                  Icons.storefront_outlined,
                  size: 22,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seller profile',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shown to partners on company detail before they invest.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!editing)
                  OutlinedButton.icon(
                    onPressed: loading || saving
                        ? null
                        : controller.editPublicProfile,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(context.isPhone ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error.isNotEmpty) ...[
                  Text(
                    error,
                    style: TextStyle(color: context.theme.colorScheme.error),
                  ),
                  if (!editing)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: loading || saving
                            ? null
                            : controller.refreshPublicProfile,
                        child: const Text('Retry'),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
                if (editing) ...[
                  _PublicProfileField(
                    label: 'Years of Experience',
                    controller: controller.yearsOfExperienceCtrl,
                    maxLength: 255,
                  ),
                  _PublicProfileField(
                    label: 'Total Trades Executed',
                    controller: controller.totalTradesExecutedCtrl,
                    maxLength: 255,
                  ),
                  _PublicProfileField(
                    label: 'Total Investor Base',
                    controller: controller.totalInvestorBaseCtrl,
                    maxLength: 255,
                  ),
                  _PublicProfileField(
                    label: 'Verified User / Verified Seller Status',
                    controller: controller.verifiedStatusCtrl,
                    maxLength: 255,
                    hint: 'e.g. Verified Seller',
                  ),
                  _PublicProfileField(
                    label:
                        'Companies Previously Listed / Transacted on the Platform',
                    controller: controller.companiesPreviouslyListedCtrl,
                    maxLength: 5000,
                    maxLines: 3,
                  ),
                  _PublicProfileField(
                    label: 'Cities / Geographic Presence',
                    controller: controller.geographicPresenceCtrl,
                    maxLength: 5000,
                    maxLines: 2,
                  ),
                  _PublicProfileField(
                    label: 'How We Do It / Our Approach',
                    controller: controller.approachCtrl,
                    maxLength: 5000,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: saving ? null : controller.savePublicProfile,
                        child: Text(saving ? 'Saving…' : 'Save'),
                      ),
                      TextButton(
                        onPressed: saving
                            ? null
                            : controller.cancelPublicProfile,
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ] else if (loading && data.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Loader(),
                  ),
                ] else if (data.isEmpty) ...[
                  Text(
                    'No seller profile yet. Add details partners will see on your deals.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  ..._optionalProfileFields(data),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicProfileField extends StatelessWidget {
  const _PublicProfileField({
    required this.label,
    required this.controller,
    required this.maxLength,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final int maxLength;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
        SelectableText(
          value,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
