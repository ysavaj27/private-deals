import 'package:private_deals/src/shared/app_exports.dart';

import 'my_earning_page_ctrl.dart';
import '../widgets/workspace_widgets.dart';

class EarningsView extends StatefulWidget {
  const EarningsView({super.key});
  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
  final c = Get.find<MyEarningPageCtrl>();
  String _query = '';
  bool _highestFirst = true;

  @override
  Widget build(BuildContext context) => Obx(() {
    final fromInvestors = c.currentIndex() == MyEarningTypeEnum.investor;
    final loading = c.isLoading();
    final rows =
        <
              ({
                String name,
                String photo,
                String subtitle,
                double? investment,
                int? transactions,
                double commission,
              })
            >[
              if (fromInvestors)
                for (final item in c.investor().investorsList)
                  (
                    name: item.name,
                    photo: item.profilePhoto,
                    subtitle: 'Investor',
                    investment: item.amountInvested,
                    transactions: item.totalTransactions,
                    commission: item.commissionEarned,
                  )
              else
                for (final item in c.partner().list)
                  (
                    name: item.name,
                    photo: '',
                    subtitle: item.type.trim().isEmpty
                        ? 'Channel partner'
                        : item.type.trim(),
                    investment: null,
                    transactions: null,
                    commission: item.commissionEarned,
                  ),
            ]
            .where((item) => item.name.toLowerCase().contains(_query))
            .toList()
          ..sort(
            (a, b) => _highestFirst
                ? b.commission.compareTo(a.commission)
                : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    final unavailable = loading || c.error().isNotEmpty;
    return WorkspacePage(
      title: 'My Earnings',
      subtitle: 'A clear view of the investments and commissions across your network.',
      onRefresh: c.refreshData,
      loading: loading,
      error: c.error(),
      header: [
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            for (final type in MyEarningTypeEnum.values)
              ChoiceChip(
                label: Text(
                  type == MyEarningTypeEnum.investor
                      ? 'From investors'
                      : 'From channel partners',
                ),
                selected: c.currentIndex() == type,
                showCheckmark: false,
                onSelected: (_) => c.selectType(type),
              ),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
        WorkspaceMetrics(
          children: [
            if (fromInvestors) ...[
              WorkspaceMetric(
                label: 'Total transactions',
                value: unavailable ? '—' : '${c.investor().totalTransactions}',
                icon: Icons.receipt_long_outlined,
              ),
              WorkspaceMetric(
                label: 'Amount invested',
                value: unavailable
                    ? '—'
                    : c.investor().amountInvested.toFormattedPrice,
                icon: Icons.account_balance_outlined,
              ),
            ] else
              WorkspaceMetric(
                label: 'Channel partners',
                value: unavailable ? '—' : '${c.partner().list.length}',
                icon: Icons.people_outline_rounded,
              ),
            WorkspaceMetric(
              label: 'Commission earned',
              value: unavailable
                  ? '—'
                  : (fromInvestors
                            ? c.investor().commissionEarned
                            : c.partner().totalCommissionEarned)
                        .toFormattedPrice,
              icon: Icons.payments_outlined,
              selected: true,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Text(
          'Earnings breakdown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpace.md),
        WorkspaceSearch(
          hint: fromInvestors ? 'Search investors' : 'Search channel partners',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpace.md),
        Wrap(
          spacing: AppSpace.md,
          runSpacing: AppSpace.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              loading
                  ? 'Loading earnings…'
                  : '${rows.length} ${fromInvestors ? 'investors' : 'channel partners'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(
              width: 280,
              child: DropdownButton<bool>(
                isExpanded: true,
                value: _highestFirst,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: true,
                    child: Text(
                      'Highest commission first',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(value: false, child: Text('Name: A–Z')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _highestFirst = value);
                },
              ),
            ),
          ],
        ),
      ],
      itemCount: rows.length,
      empty: WorkspaceEmpty(
        icon: Icons.payments_outlined,
        title: _query.isEmpty ? 'No earnings yet' : 'No matching results',
        message: _query.isEmpty
            ? 'Investment and commission details will appear here when available.'
            : 'Try another name or clear your search.',
      ),
      itemBuilder: (context, index) {
        final item = rows[index];
        final colors = Theme.of(context).colorScheme;
        final letter = item.name.trim().isEmpty
            ? '?'
            : item.name.trim().characters.first.toUpperCase();
        final letterAvatar = CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: Text(letter),
        );
        final identity = Row(
          children: [
            if (item.photo.trim().isEmpty)
              letterAvatar
            else
              ClipOval(
                child: CacheImage(
                  url: item.photo,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => letterAvatar,
                  errorWidget: (_, _, _) => letterAvatar,
                ),
              ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isEmpty ? 'Unnamed contact' : item.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        );
        final investment = item.investment == null
            ? null
            : WorkspaceDetail(
                label: 'Amount invested',
                value: item.investment!.toFormattedPrice,
              );
        final transactions = item.transactions == null
            ? null
            : WorkspaceDetail(
                label: 'Transactions',
                value: '${item.transactions}',
              );
        final commission = WorkspaceDetail(
          label: 'Commission earned',
          value: item.commission.toFormattedPrice,
        );
        return CustomCardWidget(
          padding: AppSpace.paddingLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const Divider(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (investment != null) ...[
                          Expanded(child: investment),
                          const SizedBox(width: AppSpace.md),
                        ],
                        if (transactions != null) ...[
                          Expanded(child: transactions),
                          const SizedBox(width: AppSpace.md),
                        ],
                        Expanded(child: commission),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 3, child: identity),
                  const SizedBox(width: AppSpace.lg),
                  if (investment != null) Expanded(flex: 2, child: investment),
                  if (transactions != null)
                    Expanded(flex: 2, child: transactions),
                  Expanded(flex: 2, child: commission),
                ],
              );
            },
          ),
        );
      },
    );
  });
}
