import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';
import 'package:private_deals/src/shared/app_exports.dart';

/// Shared desktop and mobile presentation; values use the holding model's basis.
class StartupPortfolioView extends StatefulWidget {
  const StartupPortfolioView({
    super.key,
    required this.list,
    required this.onRefresh,
    required this.type,
  });
  final EquityTypeEnum type;
  final List<StartupPortfolioListModel> list;
  final Future<void> Function() onRefresh;

  @override
  State<StartupPortfolioView> createState() => _StartupPortfolioViewState();
}

class _StartupPortfolioViewState extends State<StartupPortfolioView> {
  final _search = TextEditingController();
  String _query = '';
  String? _selectedInvestor;
  bool _refreshing = false;

  String _investorKey(StartupPortfolioListModel group) => group.investor.id > 0
      ? 'id:${group.investor.id}'
      : group.investor.uuid.isNotEmpty
      ? 'uuid:${group.investor.uuid}'
      : 'name:${group.investor.name}';

  @override
  void didUpdateWidget(covariant StartupPortfolioView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedInvestor != null &&
        !widget.list.any((group) => _investorKey(group) == _selectedInvestor)) {
      _selectedInvestor = null;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = [
      for (final group in widget.list)
        for (final holding in group.holdings)
          (
            holding: holding,
            investor: group.investor.name,
            investorKey: _investorKey(group),
          ),
    ];
    final investors = {
      for (final group in widget.list) _investorKey(group): group.investor.name,
    };
    final filtered = entries
        .where(
          (entry) =>
              (_selectedInvestor == null ||
                  entry.investorKey == _selectedInvestor) &&
              (entry.holding.startup.brandName.toLowerCase().contains(_query) ||
                  entry.investor.toLowerCase().contains(_query)),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16, bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _searchField()),
                          const SizedBox(width: 8),
                          AppRefreshButton(
                            tooltip: 'Refresh portfolio',
                            loading: _refreshing,
                            onPressed: _refresh,
                          ),
                        ],
                      ),
                      if (investors.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All investors'),
                              selected: _selectedInvestor == null,
                              onSelected: (_) =>
                                  setState(() => _selectedInvestor = null),
                            ),
                            for (final investor in investors.entries)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth,
                                ),
                                child: ChoiceChip(
                                  key: ValueKey('investor-${investor.key}'),
                                  label: Text(investor.value),
                                  selected: _selectedInvestor == investor.key,
                                  onSelected: (_) => setState(
                                    () => _selectedInvestor = investor.key,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (_query.isNotEmpty || _selectedInvestor != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            '${filtered.length} of ${entries.length} holdings',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: _Surface(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            entries.isEmpty
                                ? Icons.account_balance_wallet_outlined
                                : Icons.search_off_rounded,
                            size: 36,
                            color: colors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entries.isEmpty
                                ? 'Your portfolio starts here'
                                : 'No matching holdings',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entries.isEmpty
                                ? 'Your ${widget.type == EquityTypeEnum.equity ? 'equity' : widget.type.name.toUpperCase()} holdings will appear here once available.'
                                : 'Try another search or select a different investor.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: entries.isEmpty
                                ? _refresh
                                : () {
                                    _search.clear();
                                    setState(() {
                                      _query = '';
                                      _selectedInvestor = null;
                                    });
                                  },
                            child: Text(
                              entries.isEmpty
                                  ? 'Refresh portfolio'
                                  : 'Reset filters',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HoldingCard(
                        holding: entry.holding,
                        investor: entry.investor,
                        onRefresh: _refresh,
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Widget _searchField() => TextField(
    controller: _search,
    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
    decoration: InputDecoration(
      hintText: 'Search company or investor',
      prefixIcon: const Icon(Icons.search_rounded),
      border: const OutlineInputBorder(),
      suffixIcon: _query.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: () {
                _search.clear();
                setState(() => _query = '');
              },
            ),
    ),
  );
}

String _money(double value) => value == 0 ? '₹ 0' : value.abs().toCurrency;

String _signed(double value) =>
    '${value > 0
        ? '+'
        : value < 0
        ? '−'
        : ''}${_money(value)}';
String _returnPercentage(PortfolioModel holding) {
  if (holding.usesReportedReturn) return holding.profitPercentage;
  return holding.totalPurchasePrice > 0 ? holding.profitPercentage : '—';
}

Color _returnColor(BuildContext context, double value) => value == 0
    ? Theme.of(context).colorScheme.onSurfaceVariant
    : value < 0
    ? Theme.of(context).colorScheme.error
    : Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF6EE7B7)
    : const Color(0xFF087A55);

class _Surface extends StatelessWidget {
  const _Surface({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(AppRadii.card),
    ),
    child: child,
  );
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.holding,
    required this.investor,
    required this.onRefresh,
  });
  final PortfolioModel holding;
  final String investor;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final priced =
        holding.reportedCurrentValue != null ||
        holding.currentSharePrice > 0 ||
        holding.shares == 0;
    final hasReturn = holding.usesReportedReturn || priced;
    return _Surface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (holding.startup.cms.logo.isEmpty)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  )
                else
                  LogoImage(
                    url: holding.startup.cms.logo,
                    width: 44,
                    height: 44,
                    radius: AppRadii.control,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.startup.brandName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        investor,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (holding.isPrimaryTransaction ||
                holding.isSecondaryTransaction) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (holding.isPrimaryTransaction)
                    const _TransactionLabel('Primary'),
                  if (holding.isSecondaryTransaction)
                    const _TransactionLabel('LP Secondary'),
                ],
              ),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth >= 850
                    ? 6
                    : box.maxWidth >= 500
                    ? 3
                    : 2;
                final metrics = [
                  ('Shares held', _quantity(holding.shares)),
                  ('Average buy price', _money(holding.purchasePrice)),
                  (
                    'Current share price',
                    holding.currentSharePrice > 0
                        ? _money(holding.currentSharePrice)
                        : 'Unavailable',
                  ),
                  (
                    'Invested value',
                    _money(
                      holding.usesReportedReturn
                          ? holding.investmentAmount
                          : holding.totalPurchasePrice,
                    ),
                  ),
                  (
                    'Current value',
                    priced ? _money(holding.totalCurrentPrice) : '—',
                  ),
                  (
                    'Unrealised return',
                    hasReturn
                        ? '${_signed(holding.profitAmount)} (${_returnPercentage(holding)})'
                        : '—',
                  ),
                ];
                return Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  children: [
                    for (var i = 0; i < metrics.length; i++)
                      SizedBox(
                        width: (box.maxWidth - (columns - 1) * 16) / columns,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metrics[i].$1,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              metrics[i].$2,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: i == 5 && hasReturn
                                    ? _returnColor(
                                        context,
                                        holding.profitAmount,
                                      )
                                    : colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Divider(color: colors.outlineVariant, height: 1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_quantity(holding.availableShares)} shares available',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                if (holding.onSellShares > 0)
                  Chip(
                    label: Text(
                      '${_quantity(holding.onSellShares)} listed for sale',
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                if (holding.canSell && !holding.investor.isPreIpoKycComplete)
                  CompleteInvestorKycButton(
                    investor: holding.investor,
                    onSaved: onRefresh,
                  ),
                if (holding.startup.urlSlug.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => Get.toNamed(
                      Routes.primaryDetailPath(
                        Routes.catalogPath(WTabBarEnum.primary.slug),
                        holding.startup.urlSlug,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_outward_rounded, size: 16),
                    label: const Text('View company'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _quantity(double value) => value == value.truncateToDouble()
    ? value.toInt().toString()
    : value.toString();

class _TransactionLabel extends StatelessWidget {
  const _TransactionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
