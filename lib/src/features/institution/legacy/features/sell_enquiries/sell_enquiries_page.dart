import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';

import 'package:private_deals/src/features/institution/legacy/backend/api/sell_enquiry_api.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/deal/sell_enquiry_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';

class SellEnquiriesPage extends StatefulWidget {
  const SellEnquiriesPage({super.key});

  @override
  State<SellEnquiriesPage> createState() => _SellEnquiriesPageState();
}

class _SellEnquiriesPageState extends State<SellEnquiriesPage> {
  List<SellEnquiryModel> _items = [];
  bool _loading = true;
  String _error = '';
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = DateTime.now();
      if (_items.any(
        (item) => item.isExpiredAt(_now) != item.isExpiredAt(next),
      )) {
        setState(() => _now = next);
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final response = await SellEnquiryApi.getList();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _now = DateTime.now();
      if (response.isSuccess) {
        _items = response.r ?? [];
      } else {
        _error = 'Unable to load sell enquiries. Please try again.';
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            constraints.maxWidth < 900 ||
            MediaQuery.textScalerOf(context).scale(16) > 24;
        return ListView(
          padding: EdgeInsets.all(mobile ? 16 : 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sell Enquiries',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  onPressed: _loading ? null : _load,
                  tooltip: 'Refresh enquiries',
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              clipBehavior: Clip.antiAlias,
              child: _loading
                  ? const Padding(padding: EdgeInsets.all(48), child: Loader())
                  : _error.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(_error),
                          TextButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No sell enquiries found')),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('${_items.length} enquiries'),
                        ),
                        if (mobile)
                          ..._items.map(_mobileItem)
                        else
                          LayoutBuilder(
                            builder: (context, tableConstraints) =>
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: tableConstraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      headingRowColor: WidgetStatePropertyAll(
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerLow,
                                      ),
                                      dataRowMinHeight: 80,
                                      dataRowMaxHeight: 100,
                                      columns: const [
                                        DataColumn(label: Text('Company')),
                                        DataColumn(label: Text('Partner')),
                                        DataColumn(
                                          label: Text('Quantity'),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text('Offer price'),
                                          numeric: true,
                                        ),
                                        DataColumn(
                                          label: Text('Valid till (IST)'),
                                        ),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(
                                          label: Text('Actions'),
                                          headingRowAlignment:
                                              MainAxisAlignment.end,
                                        ),
                                      ],
                                      rows: _items
                                          .map(
                                            (item) => DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: 180,
                                                    child: _company(item),
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    item.partnerName.isEmpty
                                                        ? '—'
                                                        : item.partnerName,
                                                  ),
                                                ),
                                                DataCell(
                                                  Text(
                                                    NumberFormat.decimalPattern(
                                                      'en_IN',
                                                    ).format(item.quantity),
                                                  ),
                                                ),
                                                DataCell(Text(_price(item))),
                                                DataCell(Text(_date(item))),
                                                DataCell(_status(item)),
                                                DataCell(
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: _actions(item),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
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

  String _price(SellEnquiryModel item) => NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  ).format(item.offerPrice);
  String _date(SellEnquiryModel item) => item.offerValidTill == null
      ? '—'
      : DateFormat('dd MMM yyyy').format(item.offerValidTill!);

  Widget _company(SellEnquiryModel item) => Row(
    children: [
      LogoImage(url: item.company.logo, radius: 12),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.company.brandName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              item.company.type,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ],
  );

  Widget _status(SellEnquiryModel item) => Text(
    item.isExpiredAt(_now) ? 'Expired' : item.status,
    style: TextStyle(
      color: item.isExpiredAt(_now)
          ? Theme.of(context).colorScheme.onSurfaceVariant
          : Theme.of(context).colorScheme.primary,
    ),
  );

  Widget _actions(SellEnquiryModel item) {
    if (!item.canShowActions(_now)) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton(onPressed: () {}, child: const Text('Approve')),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Reject'),
        ),
        OutlinedButton(onPressed: () {}, child: const Text('Modify')),
      ],
    );
  }

  Widget _mobileItem(SellEnquiryModel item) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _company(item),
        const SizedBox(height: 12),
        _status(item),
        const SizedBox(height: 12),
        Text('Partner: ${item.partnerName.isEmpty ? '—' : item.partnerName}'),
        Text(
          'Quantity: ${NumberFormat.decimalPattern('en_IN').format(item.quantity)}',
        ),
        Text('Offer price: ${_price(item)}'),
        Text('Valid till (IST): ${_date(item)}'),
        if (item.createdAt.isNotEmpty) Text('Created: ${item.createdAt}'),
        if (item.notes.isNotEmpty) Text('Notes: ${item.notes}'),
        if (item.canShowActions(_now)) ...[
          const SizedBox(height: 16),
          _actions(item),
        ],
      ],
    ),
  );
}
