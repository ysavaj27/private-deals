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
    final kyc = c.type() == PendingTaskEnum.kyc;
    final investors = c.investorList
        .where(
          (item) =>
              '${item.name} ${item.email} ${item.mobileNumber} ${item.investorType}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    final transactions = c.transactions
        .where(
          (item) =>
              '${item.startup.brandName} ${item.investor.name} ${item.currentStatus} ${item.nextStep}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    final counts = [
      c.pendingTask().pendingKyc,
      c.pendingTask().documentSign,
      c.pendingTask().pendingPayment,
    ];
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
                value: c.countsLoading() || c.countsError().isNotEmpty
                    ? '—'
                    : '${counts[i]}',
                icon: _categories[i].icon,
                selected: c.type() == _categories[i].type,
                onTap: () => c.selectType(_categories[i].type),
              ),
          ],
        ),
        if (c.countsError().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Text(
              'Task totals are unavailable. Refresh to try again.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: AppSpace.xl),
        Text(
          kyc
              ? 'Complete investor KYC'
              : c.type() == PendingTaskEnum.document
              ? 'Documents awaiting signature'
              : 'Payments awaiting transfer',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          kyc
              ? 'Review investor details and continue their verification.'
              : 'Review the current status and next step for each investment.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        WorkspaceSearch(
          hint: kyc
              ? 'Search name, email or mobile number'
              : 'Search company, investor or status',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          c.isLoading()
              ? 'Loading tasks…'
              : '${kyc ? investors.length : transactions.length} tasks shown',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
      itemCount: kyc ? investors.length : transactions.length,
      empty: WorkspaceEmpty(
        icon: _query.isEmpty
            ? Icons.task_alt_rounded
            : Icons.search_off_rounded,
        title: _query.isEmpty ? 'You’re all caught up' : 'No matching tasks',
        message: _query.isEmpty
            ? 'There are no pending tasks in this category.'
            : 'Try another search or choose a different category.',
      ),
      itemBuilder: (context, index) => kyc
          ? _investorCard(context, investors[index])
          : _transactionCard(context, transactions[index]),
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
            FilledButton.icon(
              onPressed: () async {
                final result = await Get.toNamed(
                  Routes.kycPath(Get.currentRoute, investor.uuid),
                );
                if (result == true) await c.refreshData();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('Complete KYC'),
            ),
          ],
        ),
      );

  Widget _transactionCard(
    BuildContext context,
    PrimaryTransactionModel transaction,
  ) {
    final colors = Theme.of(context).colorScheme;
    final documents = [
      (label: 'SSA', document: transaction.ssaDocument),
      (label: 'Offer', document: transaction.offerDocument),
      (label: 'SHA', document: transaction.shaDocument),
    ].where((item) => item.document.signedPath.isNotEmpty).toList();
    return CustomCardWidget(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LogoImage(
                url: transaction.startup.cms.logo,
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
                      transaction.startup.brandName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      transaction.investor.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (documents.isNotEmpty)
                PopupMenuButton<int>(
                  tooltip: 'Download signed documents',
                  icon: const Icon(Icons.download_outlined),
                  onSelected: (index) => DownloadFile.downloadFromUrl(
                    url: documents[index].document.signedPath,
                    fileName: documents[index].document.meta.name,
                  ),
                  itemBuilder: (_) => [
                    for (var i = 0; i < documents.length; i++)
                      PopupMenuItem(
                        value: i,
                        child: Text('Download ${documents[i].label}'),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          WorkspaceDetail(
            label: 'Investment amount',
            value: transaction.investmentAmount.toFormattedPrice,
          ),
          const SizedBox(height: AppSpace.lg),
          Container(
            width: double.infinity,
            padding: AppSpace.paddingLg,
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: AppRadii.mdAll,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final status = WorkspaceDetail(
                  label: 'Current status',
                  value: transaction.currentStatus,
                );
                final next = WorkspaceDetail(
                  label: 'Next step',
                  value: transaction.nextStep,
                );
                return constraints.maxWidth < 500
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          status,
                          const SizedBox(height: AppSpace.lg),
                          next,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: status),
                          const SizedBox(width: AppSpace.lg),
                          Expanded(child: next),
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Text(
            '${transaction.percentage.clamp(0, 100).toStringAsFixed(0)}% completed',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpace.sm),
          LinearProgressIndicator(
            value: (transaction.percentage / 100).clamp(0, 1),
            minHeight: 6,
            borderRadius: AppRadii.pill,
            backgroundColor: colors.surfaceContainerLow,
          ),
        ],
      ),
    );
  }
}
