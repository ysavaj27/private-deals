import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

import 'package:private_deals/src/features/institution/companies/presentation/manage_promoters/manage_promoters_page_ctrl.dart';

// Import your controller and common widgets:
// AppTitleTextField, AppButton, AppButtonVariant, CustomCardWidget.

class CompanyPromotersPage extends StatelessWidget {
  final CompanyPromotersCtrl controller = Get.put(CompanyPromotersCtrl());

  CompanyPromotersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage promoters')),
          body: const Loader(),
        );
      }

      if (controller.loadError.value.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage promoters')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(controller.loadError.value, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  AppButton(label: 'Retry', onPressed: controller.fetchCompany),
                ],
              ),
            ),
          ),
        );
      }
      final saving = controller.saving.value;

      return PopScope(
        canPop: !saving,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Manage promoters'),
            automaticallyImplyLeading: !saving,
          ),
          body: AbsorbPointer(
            absorbing: saving,
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: EdgeInsets.all(context.isPhone ? 16 : 28),
                children: [
                  Text(
                    controller.companyName.value,
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add or update the people leading this company.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    final rows = controller.promoters.toList();

                    if (rows.isEmpty) {
                      return CustomCardWidget(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Icon(
                              Icons.groups_outlined,
                              size: 40,
                              color: context.theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No promoters added',
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add a promoter below. Saving an empty list '
                              'removes all existing promoters.',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (var index = 0; index < rows.length; index++)
                          Padding(
                            key: rows[index].key,
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PromoterCard(
                              row: rows[index],
                              number: index + 1,
                              controller: controller,
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Add promoter',
                      icon: Icons.add_rounded,
                      variant: AppButtonVariant.outline,
                      onPressed: controller.addPromoter,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final error = controller.errorMessage.value;

                    return error.isEmpty
                        ? const SizedBox.shrink()
                        : Text(
                            error,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.theme.colorScheme.error,
                            ),
                          );
                  }),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: context.theme.colorScheme.outlineVariant,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: saving ? null : () => Get.back(),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: AppButton(
                        label: 'Save changes',
                        isLoading: saving,
                        onPressed: saving ? null : controller.save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _PromoterCard extends StatelessWidget {
  const _PromoterCard({
    required this.row,
    required this.number,
    required this.controller,
  });

  final PromoterFields row;
  final int number;
  final CompanyPromotersCtrl controller;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      AppTitleTextField(
        title: 'Name *',
        controller: row.name,
        hint: 'Enter full name',
        textInputAction: TextInputAction.next,
        validator: (value) => controller.requiredText(value, 'Name'),
      ),
      AppTitleTextField(
        title: 'Designation *',
        controller: row.designation,
        hint: 'Example: Director',
        textInputAction: TextInputAction.next,
        validator: (value) => controller.requiredText(value, 'Designation'),
      ),
      AppTitleTextField(
        title: 'Experience *',
        controller: row.experience,
        hint: 'Example: 10 years',
        textInputAction: TextInputAction.next,
        validator: (value) => controller.requiredText(value, 'Experience'),
      ),
      AppTitleTextField(
        title: 'Profile URL',
        controller: row.url,
        hint: 'https://linkedin.com/in/...',
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        validator: controller.validateUrl,
      ),
    ];

    return CustomCardWidget(
      padding: EdgeInsets.all(context.isPhone ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Promoter $number',
                  style: context.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Remove promoter $number',
                color: context.theme.colorScheme.error,
                onPressed: () => controller.removePromoter(row),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 650 ? 2 : 1;
              const spacing = 20.0;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 20,
                children: fields
                    .map((field) => SizedBox(width: width, child: field))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
