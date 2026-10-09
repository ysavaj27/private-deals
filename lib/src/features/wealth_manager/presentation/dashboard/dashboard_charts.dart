import 'dart:math' as math;

import 'package:private_deals/src/shared/app_exports.dart';

import 'dashboard_components.dart';
import 'dashboard_details.dart';
import 'dashboard_insights.dart';

class DashboardActivityChart extends StatefulWidget {
  const DashboardActivityChart({super.key, required this.model});
  final WDashboardModel model;
  @override
  State<DashboardActivityChart> createState() => _DashboardActivityChartState();
}

class _DashboardActivityChartState extends State<DashboardActivityChart> {
  bool? _monthly;
  int? _selected;

  @override
  void didUpdateWidget(covariant DashboardActivityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.model != widget.model) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final insights = DashboardInsights(widget.model);
    final monthly =
        _monthly ??
        (widget.model.investments.monthly.isNotEmpty ||
            widget.model.investments.quarterly.isEmpty);
    final all = insights.periods(monthly: monthly);
    final periods = all.length > 12 ? all.sublist(all.length - 12) : all;
    final total = periods.fold<double>(0, (sum, p) => sum + p.amount);
    final selected = _selected != null && _selected! < periods.length
        ? periods[_selected!]
        : null;
    final hasMovement = periods.any((p) => p.amount != 0);
    return DashboardPanel(
      title: 'Investment activity',
      subtitle: 'Amounts invested during each reported period.',
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in [true, false])
            ChoiceChip(
              label: Text(option ? 'Monthly' : 'Quarterly'),
              selected: monthly == option,
              showCheckmark: false,
              onSelected: (_) => setState(() {
                _monthly = option;
                _selected = null;
              }),
            ),
        ],
      ),
      child: periods.isEmpty
          ? DashboardEmpty(
              title: 'No ${monthly ? 'monthly' : 'quarterly'} history yet',
              message: 'Investment activity will appear when period data is available. You can also check the other time view.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected?.displayLabel ??
                      (periods.length == 1
                          ? periods.single.displayLabel
                          : 'Total across ${periods.length} displayed periods'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                DashboardAmount(
                  selected?.amount ?? total,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selected != null && selected.range.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(selected.range, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 16),
                if (periods.length == 1) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'One period available',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'More periods are needed to compare investment activity.',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (periods.single.range.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            periods.single.range,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (!hasMovement)
                  const DashboardEmpty(
                    title: 'No investment recorded in these periods',
                    message: 'All reported amounts are ₹0. The period details remain available below.',
                  )
                else ...[
                  SizedBox(
                    height: 220,
                    child: SfCartesianChart(
                      margin: EdgeInsets.zero,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: CategoryAxis(
                        majorGridLines: const MajorGridLines(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        axisLine: const AxisLine(width: 0),
                        labelIntersectAction: AxisLabelIntersectAction.hide,
                        labelStyle: theme.textTheme.labelSmall!.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        axisLabelFormatter: (details) {
                          final index = int.tryParse(details.text);
                          final p = index == null || index >= periods.length
                              ? null
                              : periods[index];
                          return ChartAxisLabel(
                            p?.displayLabel ?? '',
                            theme.textTheme.labelSmall!.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: periods.every((p) => p.amount >= 0) ? 0 : null,
                        axisLine: const AxisLine(width: 0),
                        majorTickLines: const MajorTickLines(size: 0),
                        majorGridLines: MajorGridLines(
                          width: 1,
                          dashArray: const [4, 4],
                          color: colors.outlineVariant.withValues(alpha: .5),
                        ),
                        axisLabelFormatter: (details) => ChartAxisLabel(
                          dashboardMoney(details.value),
                          theme.textTheme.labelSmall!.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        header: '',
                        color: colors.inverseSurface,
                        textStyle: TextStyle(color: colors.onInverseSurface),
                        builder:
                            (
                              dynamic data,
                              dynamic point,
                              dynamic series,
                              int pointIndex,
                              int seriesIndex,
                            ) {
                              final period = periods[pointIndex];
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '${period.displayLabel}\n${dashboardMoney(period.amount, full: true)}${period.range.isEmpty ? '' : '\n${period.range}'}',
                                  style: TextStyle(
                                    color: colors.onInverseSurface,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                      ),
                      series: <CartesianSeries<DashboardPeriod, String>>[
                        ColumnSeries<DashboardPeriod, String>(
                          dataSource: periods,
                          xValueMapper: (p, i) => '$i',
                          yValueMapper: (p, _) => p.amount,
                          name: 'Invested capital',
                          color: colors.primary,
                          width: periods.length <= 3 ? .32 : .55,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5),
                          ),
                          animationDuration: 0,
                          pointColorMapper: (_, index) =>
                              _selected == null || _selected == index
                              ? colors.primary
                              : colors.primary.withValues(alpha: .35),
                          onPointTap: (details) => setState(
                            () => _selected = _selected == details.pointIndex
                                ? null
                                : details.pointIndex,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a bar for the exact amount.${all.length > 12 ? ' Showing the latest 12 of ${all.length} reported periods.' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    'View all period details (${all.length})',
                    style: theme.textTheme.labelLarge,
                  ),
                  children: [
                    for (final p in all)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 20,
                              runSpacing: 6,
                              children: [
                                Text(
                                  p.displayLabel,
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  dashboardMoney(p.amount, full: true),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            if (p.range.isNotEmpty)
                              Text(p.range, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}

class DashboardSectorChart extends StatefulWidget {
  const DashboardSectorChart({super.key, required this.model});
  final WDashboardModel model;
  @override
  State<DashboardSectorChart> createState() => _DashboardSectorChartState();
}

class _DashboardSectorChartState extends State<DashboardSectorChart> {
  bool _showAll = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insights = DashboardInsights(widget.model);
    final sectors = insights.sectors;
    final total = insights.sectorTotal;
    final shown = _showAll ? sectors : sectors.take(5);
    return DashboardPanel(
      title: 'Sector exposure',
      subtitle:
          'Where capital is allocated. Select a sector to see its investments.',
      child: sectors.isEmpty
          ? const DashboardEmpty(
              title: 'No sector allocation yet',
              message: 'Sector amounts and company details will appear as investment data becomes available.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DashboardAmount(
                      total,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'across ${sectors.length} ${sectors.length == 1 ? 'sector' : 'sectors'}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  total > 0 ? 'Share of reported sector investment' : 'Sector amounts are ₹0; allocation percentages are unavailable.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                for (final sector in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () =>
                            showDashboardSector(context, sector.sector),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sector.sector.name.isEmpty
                                          ? 'Unspecified sector'
                                          : sector.sector.name,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    total > 0
                                        ? dashboardPercent(
                                            sector.amount / total * 100,
                                          )
                                        : '—',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              DashboardBar(
                                fraction: total > 0 ? sector.amount / total : 0,
                                color: theme.colorScheme.primary,
                                label:
                                    '${sector.sector.name}: ${dashboardMoney(sector.amount, full: true)}',
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  DashboardAmount(
                                    sector.amount,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${sector.companies} ${sector.companies == 1 ? 'company' : 'companies'}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (sectors.length > 5)
                  TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    child: Text(
                      _showAll
                          ? 'Show fewer sectors'
                          : 'View all ${sectors.length} sectors',
                    ),
                  ),
              ],
            ),
    );
  }
}

class DashboardPerformanceChart extends StatefulWidget {
  const DashboardPerformanceChart({super.key, required this.model});
  final WDashboardModel model;
  @override
  State<DashboardPerformanceChart> createState() =>
      _DashboardPerformanceChartState();
}

class _DashboardPerformanceChartState extends State<DashboardPerformanceChart> {
  bool _showAll = false;
  String _sort = 'invested';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final rows = DashboardInsights(widget.model).companies;
    if (_sort != 'invested') {
      rows.sort((a, b) {
        if (a.change == null) return b.change == null ? 0 : 1;
        if (b.change == null) return -1;
        return _sort == 'gains'
            ? b.change!.compareTo(a.change!)
            : a.change!.compareTo(b.change!);
      });
    }
    final shown = (_showAll ? rows : rows.take(5)).toList();
    final maxValue = rows.fold<double>(
      0,
      (value, row) => math.max(
        value,
        math.max(row.invested, row.hasValuation ? row.company.currentValue : 0),
      ),
    );
    return DashboardPanel(
      title: 'Company performance',
      subtitle: 'Invested capital vs reported current value. Change is not annualised.',
      trailing: rows.length < 2
          ? null
          : DropdownButton<String>(
              value: _sort,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 'invested',
                  child: Text('Largest investments'),
                ),
                DropdownMenuItem(
                  value: 'gains',
                  child: Text('Largest value gains'),
                ),
                DropdownMenuItem(
                  value: 'declines',
                  child: Text('Largest value declines'),
                ),
              ],
              onChanged: (value) => setState(() => _sort = value ?? 'invested'),
            ),
      child: rows.isEmpty
          ? const DashboardEmpty(
              title: 'No company performance yet',
              message: 'Invested amounts and available valuations will appear here for your companies.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    DashboardLegend(label: 'Invested', color: colors.primary),
                    DashboardLegend(
                      label: 'Current value',
                      color: colors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final row in shown) ...[
                  const SizedBox(height: 20),
                  Text(
                    row.company.startupName.isEmpty
                        ? 'Unnamed company'
                        : row.company.startupName,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (row.change != null) ...[
                        Icon(
                          row.change! > 0
                              ? Icons.trending_up
                              : row.change! < 0
                              ? Icons.trending_down
                              : Icons.trending_flat,
                          size: 17,
                          color: row.change! < 0
                              ? colors.error
                              : colors.primary,
                        ),
                        DashboardAmount(
                          row.change!,
                          signed: true,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: row.change! < 0
                                ? colors.error
                                : colors.primary,
                          ),
                        ),
                        Text(
                          row.changePercent == null
                              ? 'Change % unavailable'
                              : '(${row.changePercent! > 0 ? '+' : ''}${dashboardPercent(row.changePercent!)})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: row.change! < 0
                                ? colors.error
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ] else
                        Text(
                          'Current value unavailable',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CompanyBar(
                    label: 'Invested',
                    amount: row.invested,
                    maxValue: maxValue,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 8),
                  if (row.hasValuation)
                    _CompanyBar(
                      label: 'Current',
                      amount: row.company.currentValue,
                      maxValue: maxValue,
                      color: colors.secondary,
                    ),
                  const SizedBox(height: 16),
                  if (row != shown.last)
                    Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: .6),
                    ),
                ],
                Text(
                  '${rows.length} ${rows.length == 1 ? 'company' : 'companies'} reported · Bars share the same scale',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (rows.length > 5)
                  TextButton(
                    onPressed: () => setState(() => _showAll = !_showAll),
                    child: Text(
                      _showAll
                          ? 'Show fewer companies'
                          : 'View all ${rows.length} companies',
                    ),
                  ),
              ],
            ),
    );
  }
}

class _CompanyBar extends StatelessWidget {
  const _CompanyBar({
    required this.label,
    required this.amount,
    required this.maxValue,
    required this.color,
  });
  final String label;
  final double amount;
  final double maxValue;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          DashboardAmount(
            amount,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      const SizedBox(height: 5),
      DashboardBar(
        fraction: maxValue > 0 ? amount / maxValue : 0,
        color: color,
        label: '$label ${dashboardMoney(amount, full: true)}',
        height: 7,
      ),
    ],
  );
}

class DashboardInvestorChart extends StatelessWidget {
  const DashboardInvestorChart({
    super.key,
    required this.model,
    this.readOnly = false,
  });
  final WDashboardModel model;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    final insights = DashboardInsights(model);
    return DashboardPanel(
      title: 'Investor readiness',
      subtitle: 'Activity and KYC are separate checks. Select a status to view investors.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InvestorStatusGroup(
            title: 'KYC status',
            readOnly: readOnly,
            total: model.investorChartModel.kyc.length,
            rows: [
              ('Verified', insights.verified),
              ('KYC pending', insights.pendingKyc),
              ('Other KYC status', insights.otherKyc),
            ],
            empty: 'No KYC records available yet.',
          ),
          const Divider(height: 36),
          _InvestorStatusGroup(
            title: 'Account activity',
            readOnly: readOnly,
            total: model.investorChartModel.active.length,
            rows: [
              ('Active', insights.active),
              ('Inactive', insights.inactive),
              ('Other activity status', insights.unknownActivity),
            ],
            empty: 'No activity records available yet.',
          ),
        ],
      ),
    );
  }
}

class _InvestorStatusGroup extends StatelessWidget {
  const _InvestorStatusGroup({
    required this.title,
    required this.total,
    required this.rows,
    required this.empty,
    required this.readOnly,
  });
  final String title;
  final int total;
  final List<(String, List<Active>)> rows;
  final String empty;
  final bool readOnly;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.outline,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(
          total == 0
              ? empty
              : '$total ${total == 1 ? 'investor' : 'investors'} with reported status',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (total > 0) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    if (rows[i].$2.isNotEmpty)
                      Expanded(
                        flex: rows[i].$2.length,
                        child: Semantics(
                          label: '${rows[i].$1}: ${rows[i].$2.length}',
                          child: ColoredBox(
                            color: palette[i],
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++)
            if (i < 2 || rows[i].$2.isNotEmpty)
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 0,
                  ),
                ),
                onPressed: rows[i].$2.isEmpty
                    ? null
                    : () => showDashboardInvestors(
                        context,
                        rows[i].$1,
                        rows[i].$2,
                        pendingKyc: rows[i].$1 == 'KYC pending',
                        readOnly: readOnly,
                      ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: palette[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(rows[i].$1, style: theme.textTheme.bodySmall),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${rows[i].$2.length}  ·  ${dashboardPercent(rows[i].$2.length / total * 100)}',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
        ],
      ],
    );
  }
}
