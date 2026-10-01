import 'package:flutter/material.dart';
import 'package:private_deals/src/features/institution/deals/presentation/edit_deal_dialog.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';

import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page_ctrl.dart';

class DealListView extends StatefulWidget {
  const DealListView({super.key});

  @override
  State<DealListView> createState() => _DealListViewState();
}

class _DealListViewState extends State<DealListView> {
  final DealListPageCtrl c = DealListPageCtrl();

  @override
  void initState() {
    super.initState();
    c.onStart();
  }

  @override
  void dispose() {
    c.onDelete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            constraints.maxWidth < 800 ||
            MediaQuery.textScalerOf(context).scale(16) > 24;

        return ListView(
          padding: EdgeInsets.all(mobile ? 16 : 28),
          children: [
            Text(c.title, style: context.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Browse and manage your company deals.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (mobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: c.searchController,
                    onChanged: c.updateSearch,
                    hint: 'Search deals...',
                    prefixIcon: Icons.search_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    onPressed: () async {
                      var routes = InstitutionRoutes.createDeal(
                        Get.currentRoute,
                      );
                      var update = await Get.toNamed(routes);
                      if (update == true) c.fetchDeals();
                    },
                    icon: Icons.add_rounded,
                    label: 'Create deal',
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: AppTextField(
                          controller: c.searchController,
                          onChanged: c.updateSearch,
                          hint: 'Search deals...',
                          prefixIcon: Icons.search_rounded,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    onPressed: () async {
                      var routes = InstitutionRoutes.createDeal(
                        Get.currentRoute,
                      );
                      var update = await Get.toNamed(routes);
                      if (update == true) c.fetchDeals();
                    },
                    icon: Icons.add_rounded,
                    label: 'Create deal',
                  ),
                ],
              ),
            const SizedBox(height: 20),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Obx(() {
                if (c.isLoading.value) {
                  return SizedBox(
                    height: context.height * 0.4,
                    child: Loader(),
                  );
                }

                if (c.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text(c.errorMessage.value),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: c.retry,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final deals = c.filteredDeals;
                final now = c.now.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '${deals.length} deals',
                        style: context.textTheme.titleMedium,
                      ),
                    ),

                    if (deals.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('No deals found')),
                      )
                    else if (mobile)
                      ...deals.map(
                        (deal) => _MobileDealItem(deal: deal, now: now, c: c),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                headingRowColor: WidgetStatePropertyAll(
                                  context.theme.colorScheme.surfaceContainerLow,
                                ),
                                headingTextStyle: context.textTheme.titleSmall,
                                dataTextStyle: context.textTheme.bodyMedium,
                                horizontalMargin: 20,
                                columnSpacing: 28,
                                dataRowMinHeight: 80,
                                dataRowMaxHeight: 100,
                                columns: const [
                                  DataColumn(label: Text('Company')),
                                  DataColumn(label: Text('Type')),
                                  DataColumn(label: Text('Qty'), numeric: true),
                                  DataColumn(
                                    label: Text('Price'),
                                    numeric: true,
                                  ),
                                  DataColumn(
                                    label: Text('Min qty'),
                                    numeric: true,
                                  ),
                                  DataColumn(label: Text('Active until (IST)')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(
                                    label: Text('Action'),
                                    headingRowAlignment:
                                        MainAxisAlignment.center,
                                  ),
                                ],
                                rows: deals.map((deal) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 260,
                                          child: _DealCompany(deal: deal),
                                        ),
                                      ),
                                      DataCell(Text(deal.dealTypeLabel)),
                                      DataCell(
                                        Text('${deal.availableQuantity}'),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${deal.sharePrice.toStringAsFixed(2)} (final)\nBase: ${deal.basePrice?.toStringAsFixed(2) ?? '—'}',
                                          style: context.textTheme.titleSmall,
                                        ),
                                      ),
                                      DataCell(Text('${deal.minimumQty}')),
                                      DataCell(
                                        Text(
                                          deal.isExpiryDate
                                              ? _formatDealDate(deal.expiredAt)
                                              : "No Expire Limit",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      DataCell(
                                        deal.isExpired
                                            ? SizedBox()
                                            : _DealStatus(
                                                active: !deal.isExpired,
                                              ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: DealDeleteButton(
                                            deal: deal,
                                            c: c,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),

                    const Divider(height: 1),
                    DealPagination(c: c),
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

// ==================== COMPANY CELL ====================

class _DealCompany extends StatelessWidget {
  const _DealCompany({required this.deal});

  final DealModel deal;

  @override
  Widget build(BuildContext context) {
    // logger.d(deal.toJson());
    return Row(
      children: [
        LogoImage(url: deal.company.logo, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            deal.company.brandName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

// ==================== MOBILE ITEM ====================

class _MobileDealItem extends StatelessWidget {
  const _MobileDealItem({
    required this.deal,
    required this.now,
    required this.c,
  });

  final DealModel deal;
  final DateTime now;
  final DealListPageCtrl c;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DealCompany(deal: deal)),
              DealDeleteButton(deal: deal, c: c),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DealTypeChip(deal: deal),
              _DealStatus(active: !deal.isExpired),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final singleColumn =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;

              final width = singleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 16) / 2;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _field(
                    context,
                    width,
                    deal.quantityLabel,
                    '${deal.availableQuantity}',
                  ),
                  _field(
                    context,
                    width,
                    deal.priceLabel,
                    '₹${deal.sharePrice.toStringAsFixed(2)} (final)\nBase: ${deal.basePrice?.toStringAsFixed(2) ?? '—'}',
                  ),
                  _field(context, width, 'Min qty', '${deal.minimumQty}'),
                  _field(
                    context,
                    width,
                    'Active until (IST)',
                    deal.isExpiryDate
                        ? _formatDealDate(deal.expiredAt)
                        : "No Expire Limit",
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _field(
    BuildContext context,
    double width,
    String label,
    String value,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 5),
          Text(value, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class DealDeleteButton extends StatelessWidget {
  const DealDeleteButton({super.key, required this.deal, required this.c});

  final DealListPageCtrl c;

  final DealModel deal;

  @override
  Widget build(BuildContext context) {
    if (!deal.isMine) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final disabled = c.isDeleting.value || c.isLoading.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit deal',
            icon: const Icon(Icons.edit_outlined),
            onPressed: disabled
                ? null
                : () async {
                    final saved = await editDealDialog(context, deal);
                    if (saved == true && !c.isClosed) await c.fetchDeals();
                  },
          ),
          IconButton(
            tooltip: 'Delete deal',
            color: Theme.of(context).colorScheme.error,
            onPressed: disabled
                ? null
                : () => showDeleteDealDialog(context, deal),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      );
    });
  }

  Future<void> showDeleteDealDialog(
    BuildContext context,
    DealModel deal,
  ) async {
    if (!deal.isMine || c.isDeleting.value) return;

    c.deleteError.value = '';

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Obx(() {
          final deleting = c.isDeleting.value;
          final error = c.deleteError.value;

          return PopScope(
            canPop: !deleting,
            child: AlertDialog(
              title: const Text('Delete deal?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to delete this deal? '
                    'This action cannot be undone.',
                  ),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: deleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    foregroundColor: Theme.of(
                      dialogContext,
                    ).colorScheme.onError,
                  ),
                  onPressed: deleting
                      ? null
                      : () async {
                          final success = await c.deleteDeal(deal);

                          if (!dialogContext.mounted || !success) return;

                          Navigator.of(dialogContext).pop(true);
                        },
                  child: deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            ),
          );
        });
      },
    );

    if (!context.mounted || deleted != true) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Deal deleted successfully.')));
  }
}

// ==================== STATUS ====================

class _DealTypeChip extends StatelessWidget {
  const _DealTypeChip({required this.deal});

  final DealModel deal;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final color = deal.isBuyDeal ? colors.primary : colors.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        deal.dealTypeLabel,
        style: context.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _DealStatus extends StatelessWidget {
  const _DealStatus({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final dark = context.theme.brightness == Brightness.dark;

    final color = active
        ? (dark ? const Color(0xFF6BDDB2) : const Color(0xFF167451))
        : context.theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        active ? 'Active' : 'Expired',
        style: context.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

// ==================== PAGINATION ====================

class DealPagination extends StatelessWidget {
  const DealPagination({super.key, required this.c});

  final DealListPageCtrl c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = c.currentPage.value;
      final count = c.deals.length;
      final loading = c.isLoading.value;
      final hasNext = c.hasNextPage.value;
      final start = page * DealListPageCtrl.pageSize;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              count == 0 ? 'No deals' : 'Showing ${start + 1}–${start + count}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: !loading && page > 0 ? c.previousPage : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Page ${page + 1}',
                    style: context.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: !loading && hasNext ? c.nextPage : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ==================== DATE FORMAT ====================

String _formatDealDate(DateTime value) {
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

  return '${date.day} ${months[date.month - 1]} ${date.year}\n'
      '$hour:$minute $period';
}
