import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'kyc_pending_investor_page_ctrl.dart';
import '../widgets/workspace_widgets.dart';

class PendingTasksView extends StatefulWidget {
  const PendingTasksView({super.key});
  @override
  State<PendingTasksView> createState() => _PendingTasksViewState();
}

class _PendingTasksViewState extends State<PendingTasksView> {
  final c = Get.find<KycPendingInvestorPageCtrl>();
  String _query = '';
  static const _categories = [
    (
      type: PendingTaskEnum.kyc,
      title: 'KYC pending',
      icon: Icons.verified_user_outlined,
    ),
    (
      type: PendingTaskEnum.document,
      title: 'Document signing',
      icon: Icons.draw_outlined,
    ),
    (
      type: PendingTaskEnum.fundTransfer,
      title: 'Fund transfer',
      icon: Icons.account_balance_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Obx(() {
    final selected = c.type();
    final kyc = selected == PendingTaskEnum.kyc;
    final documents = selected == PendingTaskEnum.document;
    final investors = c.investors
        .where(
          (item) =>
              '${item.name} ${item.email} ${item.mobileNumber}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    final documentItems = c.documents
        .where(
          (item) =>
              '${item.company.brandName} ${item.investor.name} ${item.type} ${item.name} ${item.transactionInvoiceNo}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    final transfers = c.fundTransfers
        .where(
          (item) =>
              '${item.company.brandName} ${item.investor.name} ${item.transactionInvoiceNo} ${item.orderStep}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    final counts = [
      c.pendingTask().pendingKyc.count,
      c.pendingTask().pendingDocuments.count,
      c.pendingTask().pendingFundTransfer.count,
    ];
    final itemCount = kyc
        ? investors.length
        : documents
            ? documentItems.length
            : transfers.length;
    return WorkspacePage(
      title: 'Pending Tasks',
      subtitle: 'Keep investor onboarding and investments moving forward.',
      onRefresh: c.refreshData,
      loading: c.isLoading(),
      error: c.error(),
      header: [
        WorkspaceMetrics(
          children: [
            for (var i = 0; i < _categories.length; i++)
              WorkspaceMetric(
                label: _categories[i].title,
                value: c.isLoading() && counts.every((n) => n == 0)
                    ? '—'
                    : '${counts[i]}',
                icon: _categories[i].icon,
                selected: selected == _categories[i].type,
                onTap: () => c.selectType(_categories[i].type),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Text(
          kyc
              ? 'Complete investor KYC'
              : documents
                  ? 'Documents awaiting signature'
                  : 'Payments awaiting transfer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          kyc
              ? 'Review investor details and continue their verification.'
              : documents
                  ? 'Unsigned Pre-IPO Deal Slip, Buy Mandate, and Sell Mandate documents.'
                  : 'Review unlisted transactions waiting for fund transfer.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpace.lg),
        WorkspaceSearch(
          hint: kyc
              ? 'Search name, email or mobile number'
              : 'Search company, investor or invoice',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          c.isLoading() ? 'Loading tasks…' : '$itemCount tasks shown',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      itemCount: itemCount,
      empty: WorkspaceEmpty(
        icon: _query.isEmpty
            ? Icons.task_alt_rounded
            : Icons.search_off_rounded,
        title: _query.isEmpty ? 'You’re all caught up' : 'No matching tasks',
        message: _query.isEmpty
            ? 'There are no pending tasks in this category.'
            : 'Try another search or choose a different category.',
      ),
      itemBuilder: (context, index) {
        if (kyc) return _investorCard(context, investors[index]);
        if (documents) return _documentCard(context, documentItems[index]);
        return _fundTransferCard(context, transfers[index]);
      },
    );
  });

  Widget _investorCard(BuildContext context, InvestorModel investor) =>
      CustomCardWidget(
        padding: AppSpace.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LogoImage(
                  url: investor.profile,
                  placeHolderImage: investor.placeholderImage,
                  height: 48,
                  width: 48,
                  radius: 12,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        investor.investorType.isEmpty
                            ? 'Investor'
                            : investor.investorType,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: AppSpace.xl,
                runSpacing: AppSpace.lg,
                children: [
                  SizedBox(
                    width: constraints.maxWidth < 600
                        ? constraints.maxWidth
                        : (constraints.maxWidth - AppSpace.xl) / 2,
                    child: WorkspaceDetail(
                      label: 'Email address',
                      value: investor.email,
                    ),
                  ),
                  WorkspaceDetail(
                    label: 'Mobile number',
                    value: investor.mobileDisplay,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            CompleteInvestorKycButton(
              investor: investor,
              onSaved: c.refreshData,
            ),
          ],
        ),
      );

  Widget _documentCard(BuildContext context, PendingDocumentItem document) {
    final colors = Theme.of(context).colorScheme;
    final canOpenTx = document.transactionId > 0;
    return CustomCardWidget(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoImage(
                url: document.company.logoUrl,
                height: 44,
                width: 44,
                radius: 10,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.company.brandName.isEmpty
                          ? 'Company'
                          : document.company.brandName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      document.investor.name,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          WorkspaceDetail(
            label: 'Document',
            value: document.name.isNotEmpty ? document.name : document.type,
          ),
          if (document.type.isNotEmpty && document.name.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(label: 'Type', value: document.type),
          ],
          if (document.transactionInvoiceNo.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(
              label: 'Invoice',
              value: document.transactionInvoiceNo,
            ),
          ],
          if (document.expireOn != null) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(
              label: 'Expires on',
              value: document.expireOn!.dateWithSortMonthYear,
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.md,
            runSpacing: AppSpace.sm,
            children: [
              OutlinedButton.icon(
                onPressed: canOpenTx
                    ? () => c.openDocumentDetail(document)
                    : null,
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text('View details'),
              ),
              FilledButton.tonalIcon(
                onPressed: canOpenTx
                    ? () => c.openDocumentSignLink(document)
                    : null,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Open signing link'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fundTransferCard(
    BuildContext context,
    PendingFundTransferItem transfer,
  ) {
    final colors = Theme.of(context).colorScheme;
    return CustomCardWidget(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoImage(
                url: transfer.company.logoUrl,
                height: 44,
                width: 44,
                radius: 10,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.company.brandName.isEmpty
                          ? 'Company'
                          : transfer.company.brandName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      transfer.investor.name,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          WorkspaceDetail(
            label: 'Transfer amount',
            value: transfer.payableAmount.toFormattedPrice,
          ),
          if (transfer.transactionInvoiceNo.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(
              label: 'Invoice',
              value: transfer.transactionInvoiceNo,
            ),
          ],
          if (transfer.orderStep.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(label: 'Order step', value: transfer.orderStep),
          ],
          if (transfer.investor.mobileDisplay.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            WorkspaceDetail(
              label: 'Mobile number',
              value: transfer.investor.mobileDisplay,
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: transfer.id > 0
                  ? () => c.openFundTransferDetail(transfer)
                  : null,
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('View details'),
            ),
          ),
        ],
      ),
    );
  }
}
