import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/dashboard_api.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/dashboard/dashboard_model.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/dashboard/phone_dashboard_view.dart';

const _purple = Color(0xFF2B5996);
const _green = Color(0xFF26A88A);
const _amber = Color(0xFFC19767);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.loader = DashboardApi.getDashboard});
  final Future<DashboardModel> Function() loader;
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardModel? data;
  bool loading = true, failed = false, quarterly = false, amount = true;
  DateTime? updated;
  bool get dark => Theme.of(context).brightness == Brightness.dark;
  Color get muted => dark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);
  Color get ink => dark ? const Color(0xFFF0F6FC) : const Color(0xFF1A2233);
  final money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  final count = NumberFormat.decimalPattern('en_IN');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || context.isPhone) return;
      _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      final result = await widget.loader();
      if (mounted) {
        setState(() {
          data = result;
          updated = DateTime.now();
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void go(WTabBarEnum tab) => Get.find<SellerHomePageCtrl>().onTap(tab);
  Widget text(
    String value, {
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => Text(
    value,
    style: TextStyle(
      fontSize: size,
      color: color ?? ink,
      fontWeight: weight,
      height: 1.4,
    ),
  );
  Widget pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: text(label, size: 11, color: color, weight: FontWeight.w600),
  );
  Widget card(Widget child) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF161B22) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: dark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .025),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
  Widget heading(String title, String subtitle, {Widget? action}) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(title, size: 16, weight: FontWeight.w700),
              const SizedBox(height: 4),
              text(subtitle, size: 12, color: muted),
            ],
          ),
        ),
        ?action,
      ],
    ),
  );
  Widget empty(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28),
    child: Center(
      child: Column(
        children: [
          Icon(Icons.insights_outlined, size: 30, color: muted),
          const SizedBox(height: 10),
          text(message, size: 13, color: muted),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneDashboardView(loader: widget.loader);
    }

    if (data == null) {
      return Center(
        child: loading
            ? const Loader()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 44,
                    color: _purple,
                  ),
                  const SizedBox(height: 16),
                  text(
                    'Your dashboard couldn’t be loaded',
                    size: 18,
                    weight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  text(
                    'Please check your connection and try again.',
                    color: muted,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Try again'),
                  ),
                ],
              ),
      );
    }
    final d = data!;
    return ColoredBox(
      color: dark ? const Color(0xFF010409) : const Color(0xFFE4E9F1),
      child: RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 30),
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text(
                          'YOUR SELLER WORKSPACE',
                          size: 10,
                          color: _purple,
                          weight: FontWeight.w700,
                        ),
                        const SizedBox(height: 6),
                        text('Overview', size: 30, weight: FontWeight.w700),
                        text(
                          'A clear view of your business, all in one place.',
                          color: muted,
                          size: 13,
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: loading ? null : _load,
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: Text(
                        loading ? 'Refreshing…' : 'Refresh dashboard',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _banner(d),
                const SizedBox(height: 22),
                if (failed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: text(
                      'Refresh failed. Showing the last successful update.',
                      color: _amber,
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, c) {
                    final columns = c.maxWidth >= 1100
                        ? 4
                        : c.maxWidth >= 550
                        ? 2
                        : 1;
                    final tiles = [
                      _metric(
                        'Total companies',
                        d.summary('companies', 'total_companies'),
                        'Companies in your workspace',
                        Icons.apartment_rounded,
                        _purple,
                      ),
                      _metric(
                        'Available deals',
                        d.summary('deals', 'available'),
                        '${count.format(d.summary('deals', 'expired'))} expired deals',
                        Icons.local_offer_outlined,
                        _green,
                      ),
                      _metric(
                        'In progress',
                        d.summary('transactions', 'processing'),
                        '${count.format(d.summary('transactions', 'pending'))} transactions pending',
                        Icons.swap_horiz_rounded,
                        _amber,
                      ),
                      _metric(
                        'Completed',
                        d.summary('transactions', 'completed'),
                        'Completed transactions',
                        Icons.task_alt_rounded,
                        const Color(0xFF6694DF),
                      ),
                    ];
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: tiles
                          .map(
                            (e) => SizedBox(
                              width:
                                  (c.maxWidth - (columns - 1) * 16) / columns,
                              child: e,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 22),
                _split(_volume(d), _statuses(d), wide),
                const SizedBox(height: 22),
                _split(_recentTransactions(d), _prices(d), wide),
                const SizedBox(height: 22),
                _split(_deals(d), _submissions(d), wide),
                const SizedBox(height: 22),
                text(
                  updated == null
                      ? ''
                      : 'Last updated ${DateFormat('d MMM yyyy, h:mm a').format(updated!)}',
                  size: 11,
                  color: muted,
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _split(Widget left, Widget right, bool wide) => wide
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 8, child: left),
            const SizedBox(width: 22),
            Expanded(flex: 5, child: right),
          ],
        )
      : Column(children: [left, const SizedBox(height: 22), right]);

  Widget _banner(DashboardModel d) => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF1A2E48), Color(0xFF243E61), Color(0xFF2B5996)],
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                'Your next opportunity starts here.',
                size: 23,
                color: Colors.white,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              text(
                'Track activity, manage deals and keep your company prices up to date.',
                size: 13,
                color: const Color(0xFFD5E2F2),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in {
                    'primary': 'Private equity',
                    'secondary': 'LP secondary',
                    'preipo': 'Unlisted shares',
                  }.entries)
                    if (d.access(entry.key))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: text(
                          '✓  ${entry.value}',
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _metric(
    String label,
    num value,
    String detail,
    IconData icon,
    Color color,
  ) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: text(label, size: 13, color: muted)),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 14),
        text(count.format(value), size: 32, weight: FontWeight.w700),
        const SizedBox(height: 7),
        text(detail, size: 11, color: muted),
      ],
    ),
  );

  Widget _volume(DashboardModel d) {
    final points = d.volume(quarterly);
    final key = amount ? 'amount' : 'count';
    final total = points.fold<num>(
      0,
      (sum, e) => sum + DashboardModel.number(e[key]),
    );
    final maxValue = points.fold<num>(
      0,
      (v, e) => math.max(v, DashboardModel.number(e[key])),
    );
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Transaction volume', 'Activity across the reported periods'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Monthly')),
                  ButtonSegment(value: true, label: Text('Quarterly')),
                ],
                selected: {quarterly},
                onSelectionChanged: (v) => setState(() => quarterly = v.first),
                showSelectedIcon: false,
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Amount')),
                  ButtonSegment(value: false, label: Text('Count')),
                ],
                selected: {amount},
                onSelectionChanged: (v) => setState(() => amount = v.first),
                showSelectedIcon: false,
              ),
            ],
          ),
          const SizedBox(height: 22),
          text(
            amount ? money.format(total) : count.format(total),
            size: 28,
            weight: FontWeight.w700,
          ),
          text('Total for displayed periods', color: muted, size: 11),
          const SizedBox(height: 18),
          if (points.isEmpty)
            empty('No volume data available')
          else
            SizedBox(
              height: 190,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: points.map((e) {
                  final value = DashboardModel.number(e[key]);
                  final label =
                      '${e['month'] ?? e['quarter'] ?? e['quater'] ?? ''}';
                  return Expanded(
                    child: Tooltip(
                      message:
                          '$label: ${amount ? money.format(value) : count.format(value)}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, c) => Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: _purple.withValues(alpha: .035),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      width: double.infinity,
                                      height: value == 0
                                          ? 2
                                          : math.max(
                                              4,
                                              c.maxHeight *
                                                  value /
                                                  math.max(1, maxValue),
                                            ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Color(0xFF2B5996),
                                            Color(0xFF8BAAD4),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              quarterly
                                  ? label
                                  : label
                                        .split(' ')
                                        .first
                                        .substring(
                                          0,
                                          math.min(
                                            3,
                                            label.split(' ').first.length,
                                          ),
                                        ),
                              maxLines: 1,
                              style: TextStyle(fontSize: 10, color: muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (maxValue == 0 && points.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: text(
                'No transaction volume in these periods yet.',
                size: 12,
                color: muted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _statuses(DashboardModel d) {
    final items = d.chart('transaction_status');
    final values = items
        .map((e) => DashboardModel.number(e['count']).toDouble())
        .toList();
    final total = values.fold<double>(0, (a, b) => a + b);
    final colors = items
        .map(
          (e) => e['key'] == 'completed'
              ? _green
              : e['key'] == 'processing'
              ? _purple
              : _amber,
        )
        .toList();
    return card(
      Column(
        children: [
          heading('Transaction status', 'Where your transactions stand'),
          SizedBox(
            height: 190,
            child: Center(
              child: SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Semantics(
                      label:
                          'Transaction status: ${items.map((e) => '${e['label'] ?? e['key']}: ${e['count']}').join(', ')}',
                      child: CustomPaint(
                        size: const Size(170, 170),
                        painter: _RingPainter(
                          values,
                          colors,
                          muted.withValues(alpha: .12),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        text(
                          count.format(total),
                          size: 32,
                          weight: FontWeight.w700,
                        ),
                        text('transactions', size: 11, color: muted),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: text(
                      '${items[i]['label'] ?? items[i]['key']}',
                      size: 13,
                      color: muted,
                    ),
                  ),
                  text(count.format(values[i]), weight: FontWeight.w600),
                ],
              ),
            ),
          if (items.isEmpty)
            text('No status data available', color: muted, size: 12),
        ],
      ),
    );
  }

  Widget _prices(DashboardModel d) {
    final total = d.summary('companies', 'total_companies');
    final uploaded = d.summary('companies', 'price_uploaded_today');
    final remaining = d.summary('companies', 'price_not_uploaded_today');
    final progress = total == 0 ? 0.0 : (uploaded / total).clamp(0.0, 1.0);
    return card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Price update health', 'Keep your listings current'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              text(
                '${(progress * 100).toStringAsFixed(1)}%',
                size: 34,
                weight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: text('updated today', size: 12, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: _green,
              backgroundColor: _green.withValues(alpha: .12),
            ),
          ),
          const SizedBox(height: 18),
          text(
            '${count.format(uploaded)} updated  ·  ${count.format(remaining)} remaining',
            size: 12,
            color: muted,
          ),
          const SizedBox(height: 22),
          pill(
            remaining > 0 ? 'Needs your attention' : 'All caught up',
            remaining > 0 ? _amber : _green,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => go(WTabBarEnum.priceUpdate),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Update share prices'),
            ),
          ),
        ],
      ),
    );
  }

  Widget avatar(Map<String, dynamic> company) {
    final name = '${company['brand_name'] ?? 'Company'}';
    final logo = '${company['logo'] ?? ''}';
    final fallback = Center(
      child: text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        color: _purple,
        weight: FontWeight.w700,
      ),
    );
    return Container(
      width: 42,
      height: 42,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: logo.isEmpty
          ? fallback
          : Image.network(
              logo.startsWith('https://') ? logo : '${AppUrl.imageURL}$logo',
              fit: BoxFit.contain,
              errorBuilder: (_, error, stack) => fallback,
            ),
    );
  }

  Widget _activity(
    Map<String, dynamic> company,
    String subtitle,
    Widget trailing,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        avatar(company),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(
                '${company['brand_name'] ?? 'Company'}',
                size: 13,
                weight: FontWeight.w600,
              ),
              const SizedBox(height: 4),
              text(subtitle, size: 11, color: muted),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    ),
  );
  Widget _recentTransactions(DashboardModel d) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Recent transactions',
          'Your latest investment activity',
          action: d.access('preipo')
              ? TextButton(
                  onPressed: () => go(WTabBarEnum.preIPOTransactions),
                  child: const Text('View all'),
                )
              : null,
        ),
        if (d.recent('transactions').isEmpty)
          empty('Your transactions will appear here.'),
        for (final e in d.recent('transactions'))
          _activity(
            DashboardModel.map(e['company']),
            '#${e['id']}  ·  ${_date(e['created_at'])}',
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                text(
                  money.format(DashboardModel.number(e['investment_amount'])),
                  size: 13,
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 5),
                text(
                  e['status'] == 2 ? 'Processing' : 'Transaction',
                  size: 11,
                  color: muted,
                ),
              ],
            ),
          ),
      ],
    ),
  );
  String _date(dynamic raw) {
    final date = DateTime.tryParse('$raw');
    return date == null
        ? 'Date unavailable'
        : DateFormat('d MMM yyyy').format(date);
  }

  Widget _deals(DashboardModel d) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'Recent deals',
          'A snapshot of your latest listings',
          action: TextButton(
            onPressed: () => go(WTabBarEnum.companyDeals),
            child: const Text('View all'),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in d.chart('deals_by_status'))
              pill(
                '${count.format(DashboardModel.number(e['count']))} ${e['key']}',
                e['key'] == 'available' ? _green : _amber,
              ),
          ],
        ),
        if (d.recent('deals').isEmpty) empty('Your deals will appear here.'),
        for (final e in d.recent('deals'))
          _activity(
            DashboardModel.map(e['company']),
            '${count.format(DashboardModel.number(e['available_quantity']))} shares · ${e['deal_type'] ?? 'Deal'}',
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                text(
                  money.format(DashboardModel.number(e['share_price'])),
                  size: 13,
                  weight: FontWeight.w600,
                ),
                const SizedBox(height: 5),
                pill(
                  e['is_hot_deal'] == true
                      ? 'Hot deal'
                      : '${e['status'] ?? 'Unknown'}',
                  e['is_hot_deal'] == true ? _amber : _green,
                ),
              ],
            ),
          ),
      ],
    ),
  );
  Widget _submissions(DashboardModel d) => card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading(
          'My submissions',
          '${count.format(d.summary('companies', 'pending_approval'))} awaiting approval',
        ),
        if (d.recent('my_submissions').isEmpty)
          empty('No company submissions yet.'),
        for (final e in d.recent('my_submissions'))
          _activity(
            e,
            '${e['type'] ?? 'Company'}',
            pill(
              '${e['approval_status'] ?? 'Unknown'}',
              e['approval_status'] == 'pending' ? _amber : _green,
            ),
          ),
        const Divider(height: 32),
        heading('Top companies', 'Ranked by completed amount'),
        if (d.chart('top_companies_by_completed_amount').isEmpty)
          empty('Rankings appear after completed transactions.')
        else
          for (final e in d.chart('top_companies_by_completed_amount'))
            _activity(
              DashboardModel.map(e['company'] ?? e),
              'Completed amount',
              text(
                money.format(
                  DashboardModel.number(e['completed_amount'] ?? e['amount']),
                ),
                size: 13,
                weight: FontWeight.w600,
              ),
            ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color track;
  _RingPainter(this.values, this.colors, this.track);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17;
    canvas.drawArc(
      rect.deflate(12),
      0,
      math.pi * 2,
      false,
      paint..color = track,
    );
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;
    double start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      if (sweep > 0) {
        canvas.drawArc(
          rect.deflate(12),
          start,
          sweep,
          false,
          paint..color = colors[i],
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => true;
}
