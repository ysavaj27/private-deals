import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'pre_ipo_detail_table.dart';

/// Shared contract so Pre-IPO and Secondary detail screens can reuse sections.
abstract class CompanyDetailSectionsCtrl {
  Rx<CompanyModel> get model;
  RxBool get isExpanded;
  RxInt get financialTab;
  RxInt get shareHoldingTab;
  List<GlobalKey> get sectionKeys;
}

class PreIPOCompanyHeader extends StatelessWidget {
  const PreIPOCompanyHeader({super.key, required this.company});
  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return _Surface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final identity = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 52 : 64,
                height: compact ? 52 : 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: company.logo.isEmpty
                    ? Icon(
                        Icons.business_rounded,
                        size: 28,
                        color: colors.onPrimaryContainer,
                      )
                    : LogoImage(
                        url: company.logo,
                        width: compact ? 52 : 64,
                        height: compact ? 52 : 64,
                        radius: 14,
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.brandName.isEmpty
                          ? company.companyName
                          : company.brandName,
                      style:
                          (compact
                                  ? theme.textTheme.headlineSmall
                                  : theme.textTheme.headlineMedium)
                              ?.copyWith(letterSpacing: -0.6),
                    ),
                    if (company.companyName.isNotEmpty &&
                        company.companyName != company.brandName) ...[
                      const SizedBox(height: 4),
                      Text(
                        company.companyName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: company.category.isEmpty
                              ? 'Pre-IPO'
                              : company.category,
                          accent: true,
                        ),
                        if (company.sector.isNotEmpty)
                          _Badge(label: company.sector),
                        if (company.isDrhp) const _Badge(label: 'DRHP filed'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(height: 1),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 560 ? 2 : 4;
                  final facts = [
                    (
                      'Market cap',
                      '${company.fundamentals.marketCap.toShowNum} cr.',
                    ),
                    ('P/E ratio', '${company.fundamentals.peRatio}'),
                    ('ROE', '${company.fundamentals.roe}%'),
                    (
                      'Lot size',
                      '${company.fundamentals.lotSize.toShowNum} shares',
                    ),
                  ];
                  return Wrap(
                    spacing: 16,
                    runSpacing: 20,
                    children: [
                      for (final fact in facts)
                        SizedBox(
                          width:
                              (constraints.maxWidth - (columns - 1) * 16) /
                              columns,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fact.$1,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(fact.$2, style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class PreIPODetailSections extends StatelessWidget {
  const PreIPODetailSections({
    super.key,
    required this.c,
    required this.phone,
    this.showPriceChart = false,
  });
  final CompanyDetailSectionsCtrl c;
  final bool phone;

  /// Pre-IPO detail shows share-price history; secondary keeps it hidden.
  final bool showPriceChart;

  @override
  Widget build(BuildContext context) {
    final company = c.model();
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          key: c.sectionKeys[0],
          number: '01',
          title: 'Company overview',
          subtitle: 'Get to know the business',
          child: company.about.trim().isEmpty
              ? const _EmptyState('Company information is not available yet.')
              : Obx(() {
                  final expanded = c.isExpanded.value;
                  final shorten = phone && company.about.length > 100;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSize(
                        duration: AppMotion.duration(context, AppMotion.normal),
                        curve: AppMotion.easeInOut,
                        alignment: Alignment.topLeft,
                        child: Text(
                          shorten && !expanded
                              ? '${company.about.substring(0, 100)}…'
                              : company.about,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.85,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (shorten)
                        TextButton.icon(
                          onPressed: () => c.isExpanded.toggle(),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            expanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                          ),
                          label: Text(expanded ? 'Read less' : 'Read more'),
                        ),
                    ],
                  );
                }),
        ),
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[1],
          number: '02',
          title: 'Fundamentals',
          subtitle: 'Key figures and company information',
          child: _Fundamentals(company: company),
        ),
        if (showPriceChart) ...[
          const SizedBox(height: 24),
          _Section(
            number: null,
            title: 'Share price history',
            subtitle: 'Recent unlisted share price movement',
            child: _SharePriceChart(
              prices: company.sharePrices,
              brandName: company.brandName,
              phone: phone,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[2],
          number: '03',
          title: 'Financials',
          subtitle: 'Figures in crores, unless stated otherwise',
          child: _Financials(c: c),
        ),
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[3],
          number: '04',
          title: 'Shareholding pattern',
          subtitle: 'Ownership composition by year',
          child: _Shareholding(c: c),
        ),
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[4],
          number: '05',
          title: 'Peer comparison',
          subtitle: 'Revenue and EPS: FY23 · Market cap and P/E: 6 Jan 2024',
          child: company.peerRatios.length < 2
              ? const _EmptyState('Peer comparison data is not available yet.')
              : PreIPODetailTable(
                  headers: const [
                    'Company',
                    'Revenue (cr.)',
                    'EPS',
                    'Market cap (cr.)',
                    'P/E',
                  ],
                  // The existing feed reserves its first entry for column labels.
                  rows: company.peerRatios
                      .skip(1)
                      .map(
                        (e) => [
                          e.perticular,
                          '${e.revenue}',
                          '${e.eps}',
                          '${e.marketCap}',
                          e.pe,
                        ],
                      )
                      .toList(),
                ),
        ),
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[5],
          number: '06',
          title: 'Events & updates',
          subtitle: 'Company announcements and documents',
          child: _Events(events: company.events),
        ),
        const SizedBox(height: 24),
        _Section(
          key: c.sectionKeys[6],
          number: '07',
          title: 'Promoters & management',
          subtitle: 'The people behind the company',
          child: _Management(promoters: company.promoters),
        ),
      ],
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: child,
  );
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String? number;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (number != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    number!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent ? colors.secondaryContainer : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: accent ? colors.onSecondaryContainer : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Fundamentals extends StatelessWidget {
  const _Fundamentals({required this.company});
  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    final f = company.fundamentals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FactGroup(
          title: 'Valuation & performance',
          facts: [
            ('Market cap (cr.)', '${f.marketCap}'),
            ('P/E ratio', '${f.peRatio}'),
            ('P/B ratio', '${f.pbRatio}'),
            ('Debt to equity', '${f.debtToEquity}'),
            ('ROE', '${f.roe}%'),
            ('Book value', '${f.bookValue}'),
          ],
        ),
        const SizedBox(height: 24),
        _FactGroup(
          title: 'Share information',
          facts: [
            ('Lot size', '${f.lotSize}'),
            ('Face value', '${f.faceValue}'),
            ('Total shares', '${f.totalShares}'),
            ('Depository', f.depository),
            ('ISIN', f.isinNumber),
          ],
        ),
        const SizedBox(height: 24),
        _FactGroup(
          title: 'Company details',
          facts: [
            ('Company name', company.companyName),
            ('PAN', f.panNumber),
            ('CIN', f.cinNumber),
            ('Registrar & transfer agent', f.rta),
          ],
        ),
      ],
    );
  }
}

class _FactGroup extends StatelessWidget {
  const _FactGroup({required this.title, required this.facts});
  final String title;
  final List<(String, String)> facts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 520 ? 1 : 2;
            return Wrap(
              spacing: 28,
              children: [
                for (final fact in facts)
                  Container(
                    width:
                        (constraints.maxWidth - (columns - 1) * 28) / columns,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fact.$1,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SelectableText(
                          fact.$2.trim().isEmpty ? '—' : fact.$2,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Financials extends StatelessWidget {
  const _Financials({required this.c});
  final CompanyDetailSectionsCtrl c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final data = c.model().customData;
    if (data.isEmpty) {
      return const _EmptyState('Financial statements are not available yet.');
    }
    final indices = switch (c.financialTab.value) {
      2 => [2],
      3 => [3],
      _ => [0, 1],
    };
    final tables = indices
        .where((i) => i < data.length && data[i].isData)
        .map((i) => data[i])
        .toList();
    const tabs = ['Income Statement', 'Balance Sheet', 'Cash Flow'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            tabs.length,
            (index) => ChoiceChip(
              label: Text(tabs[index]),
              selected: c.financialTab.value == index + 1,
              showCheckmark: false,
              onSelected: (_) => c.financialTab(index + 1),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (tables.isEmpty)
          const _EmptyState('This statement is not available yet.'),
        for (var i = 0; i < tables.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          if (tables[i].label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                tables[i].label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          PreIPODetailTable(
            headers: tables[i].values.first
                .map((value) => value?.toString() ?? '—')
                .toList(),
            rows: tables[i].values
                .skip(1)
                .where((row) => row.any((value) => value != null))
                .map(
                  (row) =>
                      row.map((value) => value?.toString() ?? '—').toList(),
                )
                .toList(),
          ),
        ],
      ],
    );
  });
}

class _Shareholding extends StatelessWidget {
  const _Shareholding({required this.c});
  final CompanyDetailSectionsCtrl c;

  @override
  Widget build(BuildContext context) => Obx(() {
    final years = c.model().shareHolders;
    if (years.isEmpty) {
      return const _EmptyState('Shareholding data is not available yet.');
    }
    final index = c.shareHoldingTab.value.clamp(0, years.length - 1);
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            years.length,
            (i) => ChoiceChip(
              label: Text('${years[i].year}'),
              selected: index == i,
              showCheckmark: false,
              onSelected: (_) {
                c.shareHoldingTab(i);
                c.shareHoldingTab.refresh();
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (years[index].shareholders.isEmpty)
          const _EmptyState(
            'Shareholding data for this year is not available yet.',
          ),
        for (final holder in years[index].shareholders)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        holder.name.capitalFirst,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${holder.percentage}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (holder.percentage / 100).clamp(0, 1),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                  color: colors.primary,
                  backgroundColor: colors.surfaceContainerHighest,
                  semanticsLabel: holder.name,
                  semanticsValue: '${holder.percentage}%',
                ),
              ],
            ),
          ),
      ],
    );
  });
}

class _Events extends StatelessWidget {
  const _Events({required this.events});
  final List<EventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyState('No company events have been published yet.');
    }
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd').format(events[i].date),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      DateFormat('MMM').format(events[i].date).toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(events[i].title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      events[i].date.showDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (events[i].description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        events[i].description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (events[i].file.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => DownloadFile.downloadFromUrl(
                          url: events[i].file,
                          fileName: events[i].title,
                        ),
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Download document'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Management extends StatelessWidget {
  const _Management({required this.promoters});
  final List<PromoterModel> promoters;

  @override
  Widget build(BuildContext context) {
    if (promoters.isEmpty) {
      return const _EmptyState('Management profiles are not available yet.');
    }
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 650 ? 2 : 1;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final person in promoters)
              Container(
                width: (constraints.maxWidth - (columns - 1) * 16) / columns,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person.name, style: theme.textTheme.titleSmall),
                          const SizedBox(height: 4),
                          Text(
                            person.designation.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (person.experience.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                person.experience,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          if (person.url.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => Launcher.launchURL(person.url),
                              iconAlignment: IconAlignment.end,
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 14,
                              ),
                              label: const Text('LinkedIn profile'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SharePriceChart extends StatelessWidget {
  const _SharePriceChart({
    required this.prices,
    required this.brandName,
    required this.phone,
  });

  final List<SharePriceModel> prices;
  final String brandName;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    if (prices.length < 3) {
      return const _EmptyState(
        'Share price history is not available yet.',
      );
    }

    final colors = Theme.of(context).colorScheme;
    final axisStyle = TextStyle(color: colors.onSurfaceVariant, fontSize: 11);
    return SizedBox(
      height: phone ? 220 : 360,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: DateTimeAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          intervalType: DateTimeIntervalType.auto,
          dateFormat: DateFormat.yMMM(),
          labelStyle: axisStyle,
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelStyle: axisStyle,
          majorTickLines: const MajorTickLines(color: Colors.transparent),
          minimum: prices.map((e) => e.price).reduce((a, b) => a < b ? a : b),
        ),
        series: <LineSeries<SharePriceModel, DateTime>>[
          LineSeries<SharePriceModel, DateTime>(
            dataSource: prices,
            name: brandName,
            color: colors.primary,
            width: 2,
            xValueMapper: (SharePriceModel point, _) => point.date,
            yValueMapper: (SharePriceModel point, _) => point.price,
            enableTooltip: true,
          ),
        ],
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final model = data as SharePriceModel;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.yMMMd().format(model.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    model.price.toCurrency,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}
