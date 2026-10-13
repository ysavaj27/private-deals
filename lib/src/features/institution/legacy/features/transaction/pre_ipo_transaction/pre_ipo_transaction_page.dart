import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_dialog.dart';
import 'package:private_deals/src/features/institution/legacy/features/transaction/pre_ipo_transaction/pre_ipo_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/widgets/no_data_view.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/unlisted_transaction_card.dart';

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
              'Manage your buying and selling orders from mandate to settlement.',
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
              return NoDataView(
                title: 'No transactions found',
                subtitle: c.searchQuery.value.isNotEmpty
                    ? 'Try a different company or investor name, or change the status filter.'
                    : c.filter.value == PreIPOTransactionFilter.all
                    ? 'New buying and selling orders will appear here.'
                    : 'There are no ${c.filter.value.label.toLowerCase()} transactions right now.',
                onPressed: c.retry,
              );
            }
            return Column(
              children: [
                for (final row in c.filtered)
                  Obx(
                    () => UnlistedTransactionCard(
                      key: ValueKey(row.id),
                      order: row,
                      isActionLoading: c.actionLoadingId.value == row.id,
                      onDetails: () => _openDetail(row),
                      onAction: (action) => c.handleAction(row, action),
                    ),
                  ),
              ],
            );
          }),
        ],
      );
    },
  );

  Future<void> _openDetail(PreIpoOrderModel row) async {
    await showDialog(
      context: context,
      builder: (_) => PreIPOTransactionDialog(
        transactionId: row.id,
        initial: row,
        onAction: c.handleAction,
        loadDetail: () => c.loadDetail(row.id),
      ),
    );
  }
}
