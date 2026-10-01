import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/transaction/pre_ipo_transaction_model.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';

class PreIPOTransactionPage extends StatefulWidget {
  const PreIPOTransactionPage({super.key});
  @override
  State<PreIPOTransactionPage> createState() => _PreIPOTransactionPageState();
}

class _PreIPOTransactionPageState extends State<PreIPOTransactionPage> {
  final c = PreIPOTransactionPageCtrl();
  final money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final count = NumberFormat.decimalPattern('en_IN');

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

  String date(DateTime? value) =>
      value == null ? '—' : DateFormat('dd MMM yyyy').format(value.toLocal());
  String label(String value) => value.isEmpty ? '—' : value;

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
              'Track pending, processing, and completed transactions.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final filter in PreIPOTransactionFilter.values)
                  ChoiceChip(
                    label: Text(filter.label),
                    selected: c.filter.value == filter,
                    onSelected: (_) => c.selectFilter(filter),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppTextField(
                controller: c.searchController,
                hint: 'Search company brand name...',
                prefixIcon: Icons.search_rounded,
                onChanged: c.search,
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    c.searchController.clear();
                    c.search('');
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (c.loading.value) {
              return const SizedBox(
                height: 280,
                child: Center(child: Loader()),
              );
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
            if (c.transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: Text('No transactions found')),
              );
            }
            final rows = c.transactions.toList();
            if (phone) return Column(children: rows.map(_mobileCard).toList());
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
                    dataRowMinHeight: 80,
                    dataRowMaxHeight: 96,
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text('Transaction')),
                      DataColumn(label: Text('Company')),
                      DataColumn(label: Text('Investor')),
                      DataColumn(label: Text('Shares'), numeric: true),
                      DataColumn(label: Text('Share price'), numeric: true),
                      DataColumn(label: Text('Payable amount'), numeric: true),
                      DataColumn(label: Text('Status')),
                      if (c.filter.value == PreIPOTransactionFilter.pending)
                        const DataColumn(label: Text('Actions')),
                      DataColumn(label: Text('Details')),
                    ],
                    rows: rows
                        .map(
                          (row) => DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label(row.transactionInvoiceNo),
                                      style: context.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(date(row.createdAt)),
                                  ],
                                ),
                              ),
                              DataCell(
                                SizedBox(width: 190, child: _company(row)),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 180,
                                  child: Text(label(row.investor.name)),
                                ),
                              ),
                              DataCell(Text(count.format(row.shares))),
                              DataCell(Text(money.format(row.sharePrice))),
                              DataCell(Text(money.format(row.payableAmount))),
                              DataCell(
                                SizedBox(width: 190, child: _status(row)),
                              ),
                              if (c.filter.value ==
                                  PreIPOTransactionFilter.pending)
                                DataCell(_pendingActions()),
                              DataCell(
                                IconButton(
                                  tooltip: 'Transaction details',
                                  icon: const Icon(Icons.chevron_right),
                                  onPressed: () => _details(row),
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
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    c.transactions.isEmpty
                        ? '0 transactions'
                        : 'Showing ${c.page.value * PreIPOTransactionPageCtrl.pageSize + 1}–${c.page.value * PreIPOTransactionPageCtrl.pageSize + c.transactions.length}',
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Previous page',
                        onPressed: !c.loading.value && c.page.value > 0
                            ? c.previousPage
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Page ${c.page.value + 1}'),
                      IconButton(
                        tooltip: 'Next page',
                        onPressed: !c.loading.value && c.hasNext.value
                            ? c.nextPage
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Widget _company(PreIPOTransactionModel row) => Row(
    children: [
      LogoImage(
        url: row.company.logo.startsWith('http')
            ? row.company.logo
            : Parse.parseUrl(row.company.logo),
        radius: 12,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label(row.company.brandName),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleSmall,
        ),
      ),
    ],
  );

  Widget _status(PreIPOTransactionModel row) {
    final progress = row.percentage.isFinite
        ? row.percentage.clamp(0, 100).toDouble()
        : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.currentStatus.isEmpty ? c.filter.value.label : row.currentStatus,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress / 100,
          semanticsLabel: 'Transaction progress',
          semanticsValue: '${progress.round()}%',
        ),
      ],
    );
  }

  Widget _mobileCard(PreIPOTransactionModel row) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: () => _details(row),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _company(row),
            const SizedBox(height: 12),
            Text(
              label(row.transactionInvoiceNo),
              style: context.textTheme.titleMedium,
            ),
            Text('${label(row.investor.name)} • ${date(row.createdAt)}'),
            const Divider(height: 28),
            _value('Shares', count.format(row.shares)),
            _value('Share price', money.format(row.sharePrice)),
            _value('Payable amount', money.format(row.payableAmount)),
            const SizedBox(height: 12),
            _status(row),
            if (c.filter.value == PreIPOTransactionFilter.pending) ...[
              const SizedBox(height: 16),
              _pendingActions(),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _details(row),
                child: const Text('View details'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _pendingActions() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      FilledButton(
        // Placeholder only; no transaction action is connected yet.
        onPressed: () {},
        child: const Text('Accept'),
      ),
      OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
        child: const Text('Reject'),
      ),
    ],
  );

  Widget _value(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );

  void _details(PreIPOTransactionModel row) => showDialog<void>(
    context: context,
    builder: (_) => PreIPOTransactionDialog(transaction: row),
  );
}
