import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/dashboard_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/dashboard/dashboard_model.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';
import 'package:private_deals/src/features/institution/legacy/utils/functions/dialog.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';

const _purple = Color(0xFF2B5996);
const _green = Color(0xFF26A88A);
const _amber = Color(0xFFC19767);

/// Compact phone dashboard — key metrics first, details behind dialogs.
class PhoneDashboardView extends StatefulWidget {
  const PhoneDashboardView({
    super.key,
    this.loader = DashboardApi.getDashboard,
  });

  final Future<DashboardModel> Function() loader;

  @override
  State<PhoneDashboardView> createState() => _PhoneDashboardViewState();
}

class _PhoneDashboardViewState extends State<PhoneDashboardView> {
  DashboardModel? data;
  bool loading = true;
  bool failed = false;

  bool get dark => Theme.of(context).brightness == Brightness.dark;

  Color get muted => dark ? const Color(0xFFB1BAC4) : const Color(0xFF5A6578);

  Color get ink => dark ? const Color(0xFFF0F6FC) : const Color(0xFF1A2233);

  Color get surface => dark ? const Color(0xFF161B22) : Colors.white;

  Color get border => dark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1);

  final money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  final count = NumberFormat.decimalPattern('en_IN');

  @override
  void initState() {
    super.initState();
    _load();
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
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void go(WTabBarEnum tab) => Get.find<SellerHomePageCtrl>().onTap(tab);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Center(
        child: loading
            ? const CircularProgressIndicator(color: _purple)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 40, color: muted),
                    const SizedBox(height: 12),
                    Text(
                      'Couldn’t load dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
      );
    }

    final d = data!;
    final companies = d.summary('companies', 'total_companies');
    final deals = d.summary('deals', 'available');
    final processing = d.summary('transactions', 'processing');
    final completed = d.summary('transactions', 'completed');
    final pending = d.summary('transactions', 'pending');
    final uploaded = d.summary('companies', 'price_uploaded_today');
    final remaining = d.summary('companies', 'price_not_uploaded_today');
    final priceProgress = companies == 0
        ? 0.0
        : (uploaded / companies).clamp(0.0, 1.0);

    final volumePoints = d.volume(false);
    final volumeTotal = volumePoints.fold<num>(
      0,
      (sum, e) => sum + DashboardModel.number(e['amount']),
    );

    final recentTx = d.recent('transactions').take(3).toList();
    final recentDeals = d.recent('deals').take(3).toList();
    final statuses = d.chart('transaction_status');

    return ColoredBox(
      color: dark ? const Color(0xFF010409) : const Color(0xFFE4E9F1),
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          children: [
            if (failed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Refresh failed. Showing last data.',
                  style: TextStyle(fontSize: 12, color: _amber),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Companies',
                    value: count.format(companies),
                    color: _purple,
                    onTap: () => go(WTabBarEnum.preIPOList),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: 'Deals',
                    value: count.format(deals),
                    color: _green,
                    onTap: () => go(WTabBarEnum.companyDeals),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'In progress',
                    value: count.format(processing),
                    color: _amber,
                    onTap: () => go(WTabBarEnum.preIPOTransactions),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricTile(
                    label: 'Completed',
                    value: count.format(completed),
                    color: const Color(0xFF6694DF),
                    onTap: () => go(WTabBarEnum.preIPOTransactions),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionCard(
              surface: surface,
              border: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Activity',
                    trailing: TextButton(
                      onPressed: () => _showVolumeDialog(d),
                      child: const Text('Details'),
                    ),
                  ),
                  Text(
                    money.format(volumeTotal),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  Text(
                    'Monthly volume · ${count.format(pending)} pending',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                  if (statuses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in statuses)
                          _StatusChip(
                            label: '${e['label'] ?? e['key']}',
                            value: count.format(
                              DashboardModel.number(e['count']),
                            ),
                            color: e['key'] == 'completed'
                                ? _green
                                : e['key'] == 'processing'
                                ? _purple
                                : _amber,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              surface: surface,
              border: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('Price updates'),
                  Row(
                    children: [
                      Text(
                        '${(priceProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'updated today',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const Spacer(),
                      Text(
                        remaining > 0
                            ? '${count.format(remaining)} left'
                            : 'All done',
                        style: TextStyle(
                          fontSize: 12,
                          color: remaining > 0 ? _amber : _green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: priceProgress,
                      minHeight: 7,
                      color: _green,
                      backgroundColor: _green.withValues(alpha: .12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => go(WTabBarEnum.priceUpdate),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Update prices'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              surface: surface,
              border: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Recent transactions',
                    trailing: TextButton(
                      onPressed: () => go(WTabBarEnum.preIPOTransactions),
                      child: const Text('All'),
                    ),
                  ),
                  if (recentTx.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No recent transactions',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    )
                  else
                    for (final e in recentTx)
                      _ActivityRow(
                        company: DashboardModel.map(e['company']),
                        subtitle: money.format(
                          DashboardModel.number(e['investment_amount']),
                        ),
                        trailing: Text(
                          '${e['status'] ?? ''}',
                          style: TextStyle(fontSize: 11, color: muted),
                        ),
                        ink: ink,
                        muted: muted,
                        onTap: () => _showMapDialog('Transaction', e),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              surface: surface,
              border: border,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(
                    'Recent deals',
                    trailing: TextButton(
                      onPressed: () => go(WTabBarEnum.companyDeals),
                      child: const Text('All'),
                    ),
                  ),
                  if (recentDeals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No recent deals',
                        style: TextStyle(fontSize: 13, color: muted),
                      ),
                    )
                  else
                    for (final e in recentDeals)
                      _ActivityRow(
                        company: DashboardModel.map(e['company']),
                        subtitle:
                            '${count.format(DashboardModel.number(e['available_quantity']))} shares',
                        trailing: Text(
                          money.format(DashboardModel.number(e['share_price'])),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ink,
                          ),
                        ),
                        ink: ink,
                        muted: muted,
                        onTap: () => _showMapDialog('Deal', e),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Future<void> _showVolumeDialog(DashboardModel d) async {
    final points = d.volume(false);
    final maxValue = points.fold<num>(
      0,
      (v, e) => math.max(v, DashboardModel.number(e['amount'])),
    );

    await showCustomDialog(
      CustomCardWidget(
        width: double.infinity,
        color: surface,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monthly volume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (points.isEmpty)
              Text('No volume data', style: TextStyle(color: muted))
            else
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final e in points)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    heightFactor: maxValue == 0
                                        ? 0.02
                                        : (DashboardModel.number(e['amount']) /
                                                  maxValue)
                                              .clamp(0.02, 1.0),
                                    widthFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: _purple,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${e['month'] ?? ''}'.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 9, color: muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMapDialog(String title, Map<String, dynamic> data) async {
    final company = DashboardModel.map(data['company']);
    await showCustomDialog(
      CustomCardWidget(
        width: double.infinity,
        color: surface,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              '${company['brand_name'] ?? 'Company'}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in data.entries)
              if (entry.key != 'company' &&
                  entry.value != null &&
                  '${entry.value}'.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(
                          entry.key.replaceAll('_', ' '),
                          style: TextStyle(fontSize: 12, color: muted),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.value}',
                          style: TextStyle(fontSize: 13, color: ink),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? const Color(0xFF161B22) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: dark ? const Color(0xFF30363D) : const Color(0xFFB8C2D1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: dark
                      ? const Color(0xFFB1BAC4)
                      : const Color(0xFF5A6578),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    required this.surface,
    required this.border,
  });

  final Widget child;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label · $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.company,
    required this.subtitle,
    required this.trailing,
    required this.ink,
    required this.muted,
    required this.onTap,
  });

  final Map<String, dynamic> company;
  final String subtitle;
  final Widget trailing;
  final Color ink;
  final Color muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = '${company['brand_name'] ?? 'Company'}';
    final logo = '${company['logo'] ?? ''}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: logo.isEmpty
                  ? Center(
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: const TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Image.network(
                      logo.startsWith('https://')
                          ? logo
                          : '${AppUrl.imageURL}$logo',
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stack) => Center(
                        child: Text(
                          name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                            color: _purple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: muted),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
