import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/features/institution/support/functions/on_back_logic.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page_ctrl.dart';

class CreateDealPage extends StatelessWidget {
  CreateDealPage({super.key});

  final CreateDealPageCtrl c = Get.put(CreateDealPageCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBackPressed),
        title: Text(c.pageTitle, style: context.textTheme.headlineSmall),
      ),
      body: SafeArea(
        child: context.isPhone
            ? const PhoneCreateDealView()
            : const DesktopCreateDealView(),
      ),
    );
  }
}

class DesktopCreateDealView extends StatelessWidget {
  const DesktopCreateDealView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CreateDealForm(phone: false);
  }
}

class PhoneCreateDealView extends StatelessWidget {
  const PhoneCreateDealView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CreateDealForm(phone: true);
  }
}

class _CreateDealForm extends GetView<CreateDealPageCtrl> {
  const _CreateDealForm({required this.phone});

  final bool phone;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;

    return Obx(() {
      final saving = controller.saving.value;

      return AbsorbPointer(
        absorbing: saving,
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(phone ? 16 : 28),
            children: [
              const SizedBox(height: 6),
              // Text(
              //   'Select a company and set the deal terms.',
              //   style: context.textTheme.bodyMedium?.copyWith(
              //     color: colors.onSurfaceVariant,
              //   ),
              // ),
              // const SizedBox(height: 24),
              CustomCardWidget(
                padding: EdgeInsets.all(phone ? 18 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Deal details', style: context.textTheme.titleLarge),
                    const SizedBox(height: 20),
                    Text('Deal for *', style: context.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: controller.dealType.value,
                      items: const [
                        DropdownMenuItem(value: 'buy', child: Text('Buy')),
                        DropdownMenuItem(value: 'sell', child: Text('Sell')),
                      ],
                      validator: (value) => value == 'buy' || value == 'sell'
                          ? null
                          : 'Select Buy or Sell',
                      onChanged: (value) {
                        if (value != null) controller.dealType.value = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      if (controller.companiesLoading.value) {
                        return const SizedBox(height: 80, child: Loader());
                      }

                      if (controller.companiesError.value.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(controller.companiesError.value),
                            AppButton(
                              label: 'Retry',
                              variant: AppButtonVariant.text,
                              onPressed: controller.fetchCompanies,
                            ),
                          ],
                        );
                      }

                      return DealCompanyDropdown(
                        items: controller.companies.toList(),
                        value: controller.selectedCompany.value,
                        onChanged: (company) =>
                            controller.selectedCompany.value = company,
                      );
                    }),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = phone || constraints.maxWidth < 650
                            ? 1
                            : 3;
                        final width =
                            (constraints.maxWidth - 20 * (columns - 1)) /
                            columns;

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            SizedBox(
                              width: width,
                              child: AppTitleTextField(
                                title: controller.availableQuantityLabel,
                                controller: controller.availableQuantityCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: controller.validateQuantity,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: AppTitleTextField(
                                title: controller.sharePriceLabel,
                                controller: controller.sharePriceCtrl,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.next,
                                validator: controller.validatePrice,
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: AppTitleTextField(
                                title: controller.minimumQuantityLabel,
                                controller: controller.minimumQuantityCtrl,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: controller.validateMinimumQuantity,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomCardWidget(
                padding: EdgeInsets.all(phone ? 18 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Deal options', style: context.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Obx(
                      () => SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hot deal'),
                        subtitle: const Text(
                          'Mark this company deal as a hot deal.',
                        ),
                        value: controller.isHotDeal.value,
                        onChanged: (value) =>
                            controller.isHotDeal.value = value,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Text(
                      'Expiry · optional',
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select date and time in IST, or leave both empty.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          AppButton(
                            label: controller.expiryDateLabel,
                            icon: Icons.calendar_today_outlined,
                            variant: AppButtonVariant.outline,
                            onPressed: () => controller.pickExpiryDate(context),
                          ),
                          AppButton(
                            label: controller.expiryTimeLabel,
                            icon: Icons.schedule_outlined,
                            variant: AppButtonVariant.outline,
                            onPressed: () => controller.pickExpiryTime(context),
                          ),
                          if (controller.expiryDate.value != null ||
                              controller.expiryTime.value != null)
                            AppButton(
                              label: 'Clear expiry',
                              variant: AppButtonVariant.text,
                              onPressed: controller.clearExpiry,
                            ),
                        ],
                      ),
                    ),
                    Obx(() {
                      final error = controller.expiryError.value;
                      if (error.isEmpty) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          error,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() {
                final canSubmit =
                    !controller.companiesLoading.value &&
                    controller.companiesError.value.isEmpty &&
                    controller.companies.isNotEmpty &&
                    !controller.saving.value;

                final cancel = AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: controller.saving.value ? null : () => Get.back(),
                );

                final save = AppButton(
                  label: 'Create deal',
                  expanded: phone,
                  isLoading: controller.saving.value,
                  onPressed: canSubmit ? controller.submit : null,
                );

                if (phone) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [save, const SizedBox(height: 12), cancel],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [cancel, const SizedBox(width: 12), save],
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

// Add your DealModel and LogoImage imports.

class DealCompanyDropdown extends StatelessWidget {
  const DealCompanyDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<LiteCompanyModel> items;
  final LiteCompanyModel? value;
  final ValueChanged<LiteCompanyModel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<LiteCompanyModel>(
      key: ValueKey(value?.uuid),
      initialValue: value,
      validator: (company) => company == null ? 'Select a company' : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Company *', style: context.textTheme.bodyMedium),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final selected = await showDialog<LiteCompanyModel>(
                  context: context,
                  builder: (_) => _CompanySearchDialog(items: items),
                );

                if (selected == null || !context.mounted) return;

                field.didChange(selected);
                onChanged(selected);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  errorText: field.errorText,
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                child: Text(
                  field.value?.brandName ?? 'Select company',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CompanySearchDialog extends StatelessWidget {
  _CompanySearchDialog({required this.items});

  final List<LiteCompanyModel> items;
  final query = ''.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select company'),
      content: SizedBox(
        width: math.min(480, MediaQuery.sizeOf(context).width - 48),
        height: context.height * 0.55,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => query.value = value,
              decoration: const InputDecoration(
                hintText: 'Search company name...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final search = query.value.trim().toLowerCase();
                final filtered = items.where((company) {
                  return '${company.brandName} ${company.companyName}'
                      .toLowerCase()
                      .contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No companies found'));
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final company = filtered[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: LogoImage(
                        url: company.logo,
                        width: 40,
                        height: 40,
                        radius: 8,
                      ),
                      title: Text(company.brandName),
                      subtitle: company.brandName != company.brandName
                          ? Text(company.brandName)
                          : null,
                      onTap: () => Navigator.pop(context, company),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
