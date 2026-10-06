import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/deals/presentation/price_excel/update_prices_excel_dialog.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';

import 'package:private_deals/src/features/institution/legacy/features/company/update_share_price/update_share_price_ctrl.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

// Import your controller and common widgets.

class UpdateSharePricePage extends StatelessWidget {
  UpdateSharePricePage({super.key});

  final UpdateSharePriceCtrl c = Get.put(UpdateSharePriceCtrl());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final saving = c.saving.value;

      return PopScope(
        canPop: !saving,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Fixed header and search.
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * .45,
                  ),
                  child: SingleChildScrollView(
                    child: SharePriceFixedHeader(controller: c),
                  ),
                ),
                _DealTypeToggle(controller: c),

                // Only this area scrolls.
                Expanded(
                  child: Obx(() {
                    if (c.loading.value) return const Loader();

                    if (c.loadError.value.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(c.loadError.value),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Retry',
                              onPressed: c.fetchCompanies,
                            ),
                          ],
                        ),
                      );
                    }

                    final rows = c.visibleRows;

                    if (rows.isEmpty) {
                      return const Center(child: Text('No companies found'));
                    }

                    return AbsorbPointer(
                      absorbing: c.saving.value,
                      child: SharePriceTable(controller: c, rows: rows),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _DealTypeToggle extends StatelessWidget {
  const _DealTypeToggle({required this.controller});

  final UpdateSharePriceCtrl controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final phone = context.isPhone;

    return Obx(() {
      final saving = controller.saving.value;
      final buying = controller.dealType.value == 'buy';
      final options = controller.settlementOptions;

      final button = SegmentedButton<String>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: const [
          ButtonSegment(
            value: 'sell',
            label: Text('Sell'),
            tooltip: 'Prices you are offering to sell',
          ),
          ButtonSegment(
            value: 'buy',
            label: Text('Buy'),
            tooltip: 'Prices you are willing to buy',
          ),
        ],
        selected: {controller.dealType.value},
        onSelectionChanged: saving
            ? null
            : (values) => controller.selectType(values.first),
      );

      final hint = Text(
        buying
            ? 'Prices and quantities you are willing to buy.'
            : 'Default settlement applies to all sell rows. Change any row to override.',
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );

      final commonPicker = buying
          ? null
          : SizedBox(
              width: phone ? double.infinity : 220,
              child: SettlementDaysDropdown(
                key: ValueKey(
                  'common-settlement-${controller.commonSettlementDays.value}',
                ),
                options: options,
                value: controller.commonSettlementDays.value,
                enabled: !saving && options.isNotEmpty,
                isDense: true,
                labelText: 'Default settlement *',
                hintText: options.isEmpty
                    ? 'Settlement list unavailable'
                    : 'Select settlement',
                onChanged: controller.setCommonSettlement,
              ),
            );

      return Material(
        color: colors.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              phone ? 12 : 24,
              12,
              phone ? 12 : 24,
              12,
            ),
            child: phone
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Price to update',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      button,
                      if (commonPicker != null) ...[
                        const SizedBox(height: 12),
                        commonPicker,
                      ],
                      const SizedBox(height: 6),
                      hint,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      button,
                      const SizedBox(width: 16),
                      Expanded(child: hint),
                      if (commonPicker != null) ...[
                        const SizedBox(width: 16),
                        commonPicker,
                      ],
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

class SharePriceFixedHeader extends StatelessWidget {
  const SharePriceFixedHeader({super.key, required this.controller});

  final UpdateSharePriceCtrl controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final phone = context.isPhone;

    if (phone) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final saving = controller.saving.value;
                    final hasSearch = controller.query.value.isNotEmpty;

                    return TextField(
                      controller: controller.searchController,
                      enabled: !saving,
                      onChanged: controller.updateSearch,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search company...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: hasSearch
                            ? IconButton(
                                tooltip: 'Clear search',
                                onPressed: saving
                                    ? null
                                    : controller.clearSearch,
                                icon: const Icon(Icons.close_rounded, size: 18),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'More actions',
                  onSelected: (value) async {
                    if (value == 'Update from Excel') {
                      final saved = await showUpdatePricesExcelDialog(context);
                      if (saved == true) {
                        await controller.fetchCompanies();
                      }
                      return;
                    }
                    toast('$value are Coming soon', MessageEnum.info);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'Update from Excel',
                      child: Text('Update from Excel'),
                    ),
                    PopupMenuItem(
                      value: 'Update from image',
                      child: Text('Update from image'),
                    ),
                    PopupMenuItem(
                      value: 'Update using API',
                      child: Text('Update using API'),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final count = controller.pendingCount;
              final saving = controller.saving.value;
              final loading = controller.loading.value;
              final hasInput = controller.hasAnyInput;

              return AppButton(
                label: count > 0 ? 'Save ($count)' : 'Save changes',
                icon: Icons.save_outlined,
                expanded: true,
                isLoading: saving,
                onPressed: saving || loading || !hasInput
                    ? null
                    : controller.save,
              );
            }),
            Obx(() {
              if (controller.feedback.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  controller.feedback.value,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: controller.feedbackIsError.value
                        ? colors.error
                        : colors.primary,
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                'Update Unlisted Share Price',
                style: context.textTheme.headlineSmall,
              );

              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppButton(
                    label: 'Update from Excel',
                    icon: Icons.table_view_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () async {
                      final saved = await showUpdatePricesExcelDialog(context);
                      if (saved == true) {
                        await controller.fetchCompanies();
                      }
                    },
                  ),
                  _futureAction('Update from image'),
                  _futureAction('Update using API'),
                  Obx(() {
                    final count = controller.pendingCount;
                    final saving = controller.saving.value;
                    final loading = controller.loading.value;
                    final hasInput = controller.hasAnyInput;

                    return AppButton(
                      label: count > 0
                          ? 'Save changes ($count)'
                          : 'Save changes',
                      icon: Icons.save_outlined,
                      variant: AppButtonVariant.primary,
                      isLoading: saving,
                      onPressed: saving || loading || !hasInput
                          ? null
                          : controller.save,
                    );
                  }),
                ],
              );

              if (constraints.maxWidth >= 1150) {
                return Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 20),
                    actions,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 16), actions],
              );
            },
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Obx(() {
              final saving = controller.saving.value;
              final hasSearch = controller.query.value.isNotEmpty;

              return TextField(
                controller: controller.searchController,
                enabled: !saving,
                onChanged: controller.updateSearch,
                decoration: InputDecoration(
                  hintText: 'Search by company name...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: hasSearch
                      ? IconButton(
                          tooltip: 'Clear search',
                          onPressed: saving ? null : controller.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            '* Required for companies you update',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          Obx(() {
            if (controller.feedback.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  controller.feedback.value,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: controller.feedbackIsError.value
                        ? colors.error
                        : colors.primary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _futureAction(String label) {
    return Tooltip(
      message: 'This action will be available later',
      child: AppButton(
        label: label,
        variant: AppButtonVariant.outline,
        onPressed: () {
          toast('$label are Coming soon', MessageEnum.info);
        },
      ),
    );
  }
}

class SharePriceTable extends StatelessWidget {
  const SharePriceTable({
    super.key,
    required this.controller,
    required this.rows,
  });

  final UpdateSharePriceCtrl controller;
  final List<SharePriceDraft> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.isPhone ? 12 : 24,
        16,
        context.isPhone ? 12 : 24,
        16,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useCards = constraints.maxWidth < 700 || context.isPhone;

              if (useCards) {
                return ListView.separated(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return _SharePriceMobileCard(
                      key: ValueKey(row.company.id),
                      row: row,
                      controller: controller,
                    );
                  },
                );
              }

              final tableWidth = constraints.maxWidth <
                      (controller.isSell ? 1200 : 1040)
                  ? (controller.isSell ? 1200.0 : 1040.0)
                  : constraints.maxWidth;

              return Scrollbar(
                controller: controller.horizontalScrollController,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                notificationPredicate: (notification) =>
                    notification.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: controller.horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        _SharePriceTableHeader(
                          priceLabel: controller.priceLabel,
                          showSettlement: controller.isSell,
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: controller.scrollController,
                            child: ListView.separated(
                              controller: controller.scrollController,
                              padding: const EdgeInsets.only(bottom: 14),
                              itemCount: rows.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                return _SharePriceTableRow(
                                  key: ValueKey(row.company.id),
                                  row: row,
                                  controller: controller,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SharePriceTableHeader extends StatelessWidget {
  const _SharePriceTableHeader({
    required this.priceLabel,
    required this.showSettlement,
  });
  final String priceLabel;
  final bool showSettlement;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: DefaultTextStyle(
        style: context.textTheme.labelLarge!,
        child: _PriceColumns(
          company: Text('Company'),
          price: Text('$priceLabel (₹) *'),
          minQty: Text('Minimum Qty *'),
          totalQty: Text('Total Qty'),
          settlement: showSettlement ? const Text('Settlement *') : null,
        ),
      ),
    );
  }
}

class _SharePriceTableRow extends StatelessWidget {
  const _SharePriceTableRow({
    super.key,
    required this.row,
    required this.controller,
  });

  final SharePriceDraft row;
  final UpdateSharePriceCtrl controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.theme.colorScheme;
      final hasError = row.errors.isNotEmpty;
      return Container(
        color: hasError ? colors.errorContainer.withAlpha(45) : colors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: _PriceColumns(
          company: _SharePriceCompanyCell(row: row),
          price: _sharePriceInput(
            context,
            row: row,
            controller: controller,
            label: controller.priceLabel,
            fieldKey: 'price',
            input: row.price,
            decimal: true,
          ),
          minQty: _sharePriceInput(
            context,
            row: row,
            controller: controller,
            label: 'Minimum Quantity',
            fieldKey: 'min_qty',
            input: row.minQty,
          ),
          totalQty: _sharePriceInput(
            context,
            row: row,
            controller: controller,
            label: 'Total quantity',
            fieldKey: 'total_qty',
            input: row.totalQty,
          ),
          settlement: controller.isSell
              ? _shareSettlementPicker(
                  context,
                  row: row,
                  controller: controller,
                )
              : null,
        ),
      );
    });
  }
}

class _SharePriceMobileCard extends StatelessWidget {
  const _SharePriceMobileCard({
    super.key,
    required this.row,
    required this.controller,
  });

  final SharePriceDraft row;
  final UpdateSharePriceCtrl controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = context.theme.colorScheme;
      final hasError = row.errors.isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasError
              ? colors.errorContainer.withAlpha(45)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SharePriceCompanyCell(row: row),
            const SizedBox(height: 16),
            _sharePriceInput(
              context,
              row: row,
              controller: controller,
              label: '${controller.priceLabel} (₹) *',
              fieldKey: 'price',
              input: row.price,
              decimal: true,
              showLabel: true,
            ),
            const SizedBox(height: 12),
            _sharePriceInput(
              context,
              row: row,
              controller: controller,
              label: 'Minimum Qty *',
              fieldKey: 'min_qty',
              input: row.minQty,
              showLabel: true,
            ),
            const SizedBox(height: 12),
            _sharePriceInput(
              context,
              row: row,
              controller: controller,
              label: 'Total Qty',
              fieldKey: 'total_qty',
              input: row.totalQty,
              showLabel: true,
            ),
            if (controller.isSell) ...[
              const SizedBox(height: 12),
              _shareSettlementPicker(
                context,
                row: row,
                controller: controller,
                showLabel: true,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _SharePriceCompanyCell extends StatelessWidget {
  const _SharePriceCompanyCell({required this.row});

  final SharePriceDraft row;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;

    return Row(
      children: [
        LogoImage(url: row.company.logo, width: 42, height: 42, radius: 10),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.company.brandName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall,
              ),
              if (row.company.companyName != row.company.brandName) ...[
                const SizedBox(height: 4),
                Text(
                  row.company.companyName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Widget _sharePriceInput(
  BuildContext context, {
  required SharePriceDraft row,
  required UpdateSharePriceCtrl controller,
  required String label,
  required String fieldKey,
  required TextEditingController input,
  bool decimal = false,
  bool showLabel = false,
}) {
  final error = row.errors[fieldKey];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showLabel) ...[
        Text(label, style: context.textTheme.bodySmall),
        const SizedBox(height: 6),
      ],
      Semantics(
        label: '${row.company.brandName}, $label',
        child: AppTextField(
          inputFormatters: decimal
              ? [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    return RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)
                        ? newValue
                        : oldValue;
                  }),
                ]
              : null,
          controller: input,
          hint: decimal ? '0.00' : 'Qty',
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          textInputAction: TextInputAction.next,
          onChanged: (_) => controller.fieldChanged(row),
        ),
      ),
      if (error != null) ...[
        const SizedBox(height: 6),
        Text(
          error,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.theme.colorScheme.error,
          ),
        ),
      ],
    ],
  );
}

Widget _shareSettlementPicker(
  BuildContext context, {
  required SharePriceDraft row,
  required UpdateSharePriceCtrl controller,
  bool showLabel = false,
}) {
  final error = row.errors['settlement_days'];
  final options = controller.settlementOptions;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showLabel) ...[
        Text('Settlement *', style: context.textTheme.bodySmall),
        const SizedBox(height: 6),
      ],
      SettlementDaysDropdown(
        key: ValueKey(
          'row-settlement-${row.company.id}-${row.settlementDays.value}',
        ),
        options: options,
        value: row.settlementDays.value,
        enabled: !controller.saving.value && options.isNotEmpty,
        isDense: true,
        labelText: showLabel ? null : 'Settlement',
        hintText: 'Select',
        errorText: error,
        onChanged: (value) => controller.setRowSettlement(row, value),
      ),
    ],
  );
}

// Shared widths keep headings and row inputs aligned.
class _PriceColumns extends StatelessWidget {
  const _PriceColumns({
    required this.company,
    required this.price,
    required this.minQty,
    required this.totalQty,
    this.settlement,
  });

  final Widget company;
  final Widget price;
  final Widget minQty;
  final Widget totalQty;
  final Widget? settlement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: company),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: price),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: minQty),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: totalQty),
        if (settlement != null) ...[
          const SizedBox(width: 16),
          Expanded(flex: 2, child: settlement!),
        ],
      ],
    );
  }
}
