import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

import 'package:private_deals/src/features/institution/companies/presentation/manage_shareholders/manage_shareholders_page_ctrl.dart';

// Import your controller and common widgets:
// AppTitleTextField, AppButton, AppButtonVariant, CustomCardWidget.

class CompanyShareholdersPage extends StatelessWidget {
  final CompanyShareholdersCtrl controller = Get.put(CompanyShareholdersCtrl());

  CompanyShareholdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage shareholders')),
          body: const Loader(),
        );
      }

      if (controller.loadError.value.isNotEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage shareholders')),
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
            title: const Text('Manage shareholders'),
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
                    'Manage shareholders and their ownership percentages by year.',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() {
                    final rows = controller.years.toList();

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
                              'No shareholder years added',
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Add a year below. Saving an empty list '
                              'removes all existing shareholders.',
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
                            child: _ShareholderYearCard(
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
                      label: 'Add year',
                      icon: Icons.add_rounded,
                      variant: AppButtonVariant.outline,
                      onPressed: controller.addYear,
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

class _ShareholderYearCard extends StatelessWidget {
  const _ShareholderYearCard({
    required this.row,
    required this.number,
    required this.controller,
  });
  final ShareholderYearFields row;
  final int number;
  final CompanyShareholdersCtrl controller;

  @override
  Widget build(BuildContext context) => CustomCardWidget(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Year group $number',
                style: context.textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Remove year',
              onPressed: () => controller.removeYear(row),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        AppTitleTextField(
          title: 'Year *',
          controller: row.year,
          hint: '2025',
          keyboardType: TextInputType.number,
          validator: (value) => controller.requiredText(value, 'Year'),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
              if (row.shareholders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('No shareholders for this year.'),
                ),
              for (final shareholder in row.shareholders)
                Padding(
                  key: shareholder.key,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Shareholder',
                              style: context.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove shareholder',
                            onPressed: () =>
                                controller.removeShareholder(row, shareholder),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                        ],
                      ),
                      AppTitleTextField(
                        title: 'Name *',
                        controller: shareholder.name,
                        validator: (value) =>
                            controller.requiredText(value, 'Name'),
                      ),
                      const SizedBox(height: 12),
                      AppTitleTextField(
                        title: 'Percentage *',
                        controller: shareholder.percentage,
                        hint: '0–100',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: controller.validatePercentage,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        AppButton(
          label: 'Add shareholder',
          icon: Icons.add_rounded,
          variant: AppButtonVariant.outline,
          onPressed: () => controller.addShareholder(row),
        ),
      ],
    ),
  );
}
