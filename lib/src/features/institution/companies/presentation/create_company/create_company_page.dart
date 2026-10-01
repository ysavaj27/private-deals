import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/support/functions/on_back_logic.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/app_title_dropdown.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

import 'package:private_deals/src/features/institution/companies/presentation/create_company/create_company_page_ctrl.dart';

class CreateCompanyPage extends StatelessWidget {
  CreateCompanyPage({super.key});

  final CreateCompanyCtrl c = Get.put(CreateCompanyCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Create company"),
        leading: BackButton(onPressed: onBackPressed),
      ),
      body: CreateCompanyForm(),
    );
  }
}

class CreateCompanyForm extends StatelessWidget {
  final CreateCompanyCtrl c = Get.find<CreateCompanyCtrl>();

  CreateCompanyForm({super.key});

  @override
  Widget build(BuildContext context) {
    bool phone = context.isPhone;
    return SafeArea(
      child: Obx(() {
        final saving = c.saving.value;
        return AbsorbPointer(
          absorbing: saving,
          child: Form(
            key: c.formKey,
            child: ListView(
              padding: EdgeInsets.all(phone ? 16 : 28),
              children: [
                // Text('Create company', style: context.textTheme.headlineSmall),
                // const SizedBox(height: 6),
                // Text(
                //   'Add company details and investment information.'
                //   ' Fields marked * are required.',
                //   style: context.textTheme.bodyMedium?.copyWith(
                //     color: context.theme.colorScheme.onSurfaceVariant,
                //   ),
                // ),
                // const SizedBox(height: 24),
                CompanyLogoPicker(),
                const SizedBox(height: 24),
                _section(
                  context,
                  title: 'Company details',
                  subtitle: 'Identify the company and its sector.',
                  children: [
                    // Obx(
                    //   () => AppTitleDropdown<CompanyType>(
                    //     title: 'Type *',
                    //     value: c.companyType.value,
                    //     items: CompanyType.values,
                    //     labelBuilder: (value) => value.value.capitalFirst,
                    //     onChanged: c.changeType,
                    //   ),
                    // ),
                    _sectorDropdown(),
                    if (c.companyType == CompanyType.unlisted)
                      Obx(
                        () => AppTitleDropdown<UnListedShareCategoryEnum>(
                          // Remove this UnListedShareCategoryEnum.aToZ
                          title: 'Category',
                          value: c.category.value,
                          items: UnListedShareCategoryEnum.values,
                          labelBuilder: (value) => value.apiCategory,
                          onChanged: (value) => c.category.value = value,
                        ),
                      ),
                    ...CreateCompanyCtrl.identityFields
                        .where((field) => field.key != 'about')
                        .map(_field),
                  ],
                  footer: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DuplicateNotice(),
                      const SizedBox(height: 20),
                      _field(
                        CreateCompanyCtrl.identityFields.firstWhere(
                          (field) => field.key == 'about',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  title: 'Company fundamentals',
                  subtitle:
                      'Enter market cap in crores; other amounts are in rupees.',
                  children: CreateCompanyCtrl.financialFields
                      .map(_field)
                      .toList(),
                ),
                const SizedBox(height: 20),
                _section(
                  context,
                  title: 'Additional details',
                  subtitle:
                      'Optional company identifiers and fees.'
                      ' Separate alternative names with commas.',
                  children: CreateCompanyCtrl.additionalFields
                      .map(_field)
                      .toList(),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (c.submitError.value.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      c.submitError.value,
                      style: TextStyle(color: context.theme.colorScheme.error),
                    ),
                  );
                }),
                Obx(() {
                  final cancel = AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: c.saving.value ? null : () => Get.back(),
                  );

                  final save = AppButton(
                    label: 'Create company',
                    isLoading: c.saving.value,
                    onPressed: c.canSave ? c.submit : null,
                    expanded: phone,
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
      }),
    );
  }

  Widget _field(CompanyField field) {
    return AppTitleTextField(
      title: '${field.label}${field.required ? ' *' : ''}',
      controller: c.fields[field.key],
      hint: field.hint,
      maxLines: field.lines,
      minLines: field.lines > 1 ? field.lines : null,
      keyboardType: field.numeric
          ? TextInputType.numberWithOptions(
              decimal: true,
              signed: field.min == null,
            )
          : field.lines > 1
          ? TextInputType.multiline
          : TextInputType.text,
      textInputAction: field.lines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      validator: (value) => c.validate(field, value),
    );
  }

  Widget _sectorDropdown() {
    return Obx(() {
      if (c.sectorsLoading.value) {
        return const SizedBox(height: 80, child: Loader());
      }

      if (c.sectorsError.value.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.sectorsError.value),
            AppButton(
              label: 'Retry sectors',
              variant: AppButtonVariant.text,
              onPressed: c.fetchSectors,
            ),
          ],
        );
      }

      return AppTitleDropdown<int>(
        title: 'Sector *',
        hint: 'Select sector',
        value: c.sectorId.value,
        items: c.sectors.map((sector) => sector.id).toList(),
        labelBuilder: (id) =>
            c.sectors.firstWhere((sector) => sector.id == id).name,
        onChanged: (id) => c.sectorId.value = id,
        validator: (id) => id == null ? 'Select a sector' : null,
      );
    });
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
    Widget? footer,
  }) {
    return CustomCardWidget(
      padding: EdgeInsets.all(context.isPhone ? 18 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = context.isPhone || constraints.maxWidth < 600
                  ? 1
                  : constraints.maxWidth < 1000
                  ? 2
                  : 3;

              const gap = 20.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: 20,
                children: children
                    .map((child) => SizedBox(width: width, child: child))
                    .toList(),
              );
            },
          ),
          if (footer != null) ...[const SizedBox(height: 20), footer],
        ],
      ),
    );
  }
}

class _DuplicateNotice extends StatelessWidget {
  final CreateCompanyCtrl c = Get.find<CreateCompanyCtrl>();

  _DuplicateNotice();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = c.duplicateState.value;
      final colors = context.theme.colorScheme;

      final message = switch (state) {
        DuplicateState.idle =>
          'Enter CIN or legal company name to check for an existing company.',
        DuplicateState.checking => 'Checking for an existing company...',
        DuplicateState.clear => 'No existing company found.',
        DuplicateState.duplicate =>
          'This company already exists.'
              '${c.duplicateMatches.isEmpty ? '' : '\n${c.duplicateMatches.join('\n')}'}',
        DuplicateState.failed =>
          'Could not check for duplicates. Retry before creating the company.',
      };

      final hasError =
          state == DuplicateState.duplicate || state == DuplicateState.failed;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasError ? colors.errorContainer : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state == DuplicateState.checking)
              const SizedBox(width: 20, height: 20, child: Loader())
            else
              Icon(
                hasError
                    ? Icons.info_outline
                    : state == DuplicateState.clear
                    ? Icons.check_circle_outline
                    : Icons.search,
                size: 20,
                color: hasError ? colors.onErrorContainer : colors.primary,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? colors.onErrorContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                  if (state == DuplicateState.failed)
                    AppButton(
                      label: 'Retry check',
                      variant: AppButtonVariant.text,
                      onPressed: c.checkDuplicate,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CompanyLogoPicker extends StatelessWidget {
  final CreateCompanyCtrl c = Get.find<CreateCompanyCtrl>();

  CompanyLogoPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.theme.colorScheme;
      final selected = c.logo.value;
      final bytes = selected?.uint8list;
      final hasImage = bytes != null && bytes.isNotEmpty;

      final picking = c.pickingLogo.value;
      final disabled = picking || c.saving.value;
      final error = c.logoError.value;

      final preview = Container(
        width: 112,
        height: 112,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: picking
              ? const Loader()
              : hasImage
              ? Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  semanticLabel: 'Selected company logo',
                  errorBuilder: (_, _, _) => Icon(
                    Icons.broken_image_outlined,
                    color: colors.error,
                    size: 32,
                  ),
                )
              : Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 36,
                  color: colors.primary,
                ),
        ),
      );

      final details = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasImage ? 'Company logo selected' : 'Upload company logo',
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Optional. Choose a clear image, up to 2 MB.',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (hasImage && selected != null) ...[
            const SizedBox(height: 8),
            Text(
              selected.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton(
                label: picking
                    ? 'Selecting...'
                    : hasImage
                    ? 'Change logo'
                    : 'Choose logo',
                icon: Icons.upload_outlined,
                variant: AppButtonVariant.outline,
                onPressed: disabled ? null : c.pickLogo,
              ),
              if (hasImage)
                AppButton(
                  label: 'Remove',
                  variant: AppButtonVariant.text,
                  onPressed: disabled ? null : c.removeLogo,
                ),
            ],
          ),
        ],
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Company logo ',
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: colors.error),
                ),
              ],
            ),
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: error.isEmpty ? colors.outlineVariant : colors.error,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [preview, const SizedBox(height: 16), details],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview,
                    const SizedBox(width: 20),
                    Expanded(child: details),
                  ],
                );
              },
            ),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
