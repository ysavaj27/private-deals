import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_dialog.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_order_widgets.dart';

class PreIPOTransactionPage extends StatefulWidget {
  const PreIPOTransactionPage({super.key});

  @override
  State<PreIPOTransactionPage> createState() => _PreIPOTransactionPageState();
}

class _PreIPOTransactionPageState extends State<PreIPOTransactionPage> {
  late final PreIPOTransactionPageCtrl c;

  @override
  void initState() {
    super.initState();
    c = Get.put(PreIPOTransactionPageCtrl());
  }

  @override
  void dispose() {
    if (Get.isRegistered<PreIPOTransactionPageCtrl>()) {
      Get.delete<PreIPOTransactionPageCtrl>();
    }
    super.dispose();
  }

  String _money(double value) => '₹${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final phone = constraints.maxWidth < 700;
      return ListView(
        padding: EdgeInsets.all(phone ? 16 : 28),
        children: [
          if (!phone) ...[
            Text(
              'Unlisted transactions',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage Pre-IPO orders after the investor signs the mandate.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppTextField(
                hint: 'Search company or investor...',
                prefixIcon: Icons.search_rounded,
                onChanged: c.search,
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () => c.search(''),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in PreIPOTransactionFilter.values)
                  ChoiceChip(
                    label: Text(status.label),
                    selected: c.filter.value == status,
                    showCheckmark: false,
                    onSelected: (_) => c.selectFilter(status),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (c.loading.value) {
              return const SizedBox(height: 280, child: Loader(size: 36));
            }
            if (c.error.value.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(c.error.value, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    TextButton(onPressed: c.retry, child: const Text('Retry')),
                  ],
                ),
              );
            }
            if (c.filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: Text('No transactions found')),
              );
            }
            final rows = c.filtered.toList();
            if (phone) {
              return Column(
                children: rows.map((row) => _mobileCard(row)).toList(),
              );
            }
            return Card(
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - 56,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      context.theme.colorScheme.surfaceContainerLow,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 72,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Company')),
                      DataColumn(label: Text('Investor')),
                      DataColumn(label: Text('Shares'), numeric: true),
                      DataColumn(label: Text('Payable'), numeric: true),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                      DataColumn(label: Text('Details')),
                    ],
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: [
                              DataCell(
                                SizedBox(width: 200, child: _company(row)),
                              ),
                              DataCell(Text(row.investor.displayName)),
                              DataCell(Text('${row.shares}')),
                              DataCell(Text(_money(row.payableAmount))),
                              DataCell(
                                SizedBox(
                                  width: 320,
                                  child: PreIpoOrderStepHeader(
                                    order: row,
                                    compact: true,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 280,
                                  child: Obx(() {
                                    if (c.actionLoadingId.value == row.id) {
                                      return const Loader(size: 22);
                                    }
                                    return PreIpoOrderActionBar(
                                      order: row,
                                      compact: true,
                                      onAction: (action) =>
                                          c.handleAction(row, action),
                                    );
                                  }),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  tooltip: 'Details',
                                  onPressed: () => _openDetail(row),
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    },
  );

  Widget _mobileCard(PreIpoOrderModel row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _company(row),
            const SizedBox(height: 12),
            Text(row.investor.displayName),
            const SizedBox(height: 8),
            Text('${row.shares} shares · ${_money(row.payableAmount)}'),
            const SizedBox(height: 12),
            PreIpoOrderStepHeader(order: row),
            if (row.hasAction) ...[
              const SizedBox(height: 12),
              Obx(() {
                if (c.actionLoadingId.value == row.id) {
                  return const Loader(size: 22);
                }
                return PreIpoOrderActionBar(
                  order: row,
                  compact: true,
                  onAction: (action) => c.handleAction(row, action),
                );
              }),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _openDetail(row),
                child: const Text('View details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _company(PreIpoOrderModel row) {
    final side = row.tradeSide.isEmpty
        ? ''
        : (row.tradeSide == 'sell' ? ' · Sell' : ' · Buy');
    final name =
        '${row.company.brandName.isEmpty ? '—' : row.company.brandName}$side';
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CacheImage(url: row.company.logo, height: 40, width: 40),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _openDetail(PreIpoOrderModel row) async {
    await showDialog(
      context: context,
      builder: (_) => PreIPOTransactionDialog(
        transactionId: row.id,
        initial: row,
        onAction: (action) => c.handleAction(row, action),
        loadDetail: () => c.loadDetail(row.id),
      ),
    );
  }
}

