import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/plugins/cache_image.dart';
import 'pre_ipo_order_detail_panels.dart';
import 'pre_ipo_order_widgets.dart';

/// Seller-style details shared by the partner and institution entry points.
class PreIpoTransactionDetailDialog extends StatefulWidget {
  final PreIpoOrderModel initial;
  final Future<void> Function(String action) onAction;
  final Future<PreIpoOrderModel?> Function() loadDetail;

  const PreIpoTransactionDetailDialog({
    super.key,
    required this.initial,
    required this.onAction,
    required this.loadDetail,
  });

  @override
  State<PreIpoTransactionDetailDialog> createState() =>
      _PreIpoTransactionDetailDialogState();
}

class _PreIpoTransactionDetailDialogState
    extends State<PreIpoTransactionDetailDialog> {
  late PreIpoOrderModel order;
  bool loading = true;
  bool actionLoading = false;

  @override
  void initState() {
    super.initState();
    order = widget.initial;
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final detail = await widget.loadDetail();
      if (mounted && detail != null) setState(() => order = detail);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _onAction(String action) async {
    if (actionLoading) return;
    setState(() => actionLoading = true);
    try {
      await widget.onAction(action);
      if (mounted) {
        setState(() => loading = true);
        await _refresh();
      }
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  final _money = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  String _label(String value) => value.isEmpty ? '—' : value;
  String _date(DateTime? value) =>
      value == null ? '—' : DateFormat('dd MMM yyyy').format(value.toLocal());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 700;
    final row = order;
    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: EdgeInsets.all(compact ? 12 : 32),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1080,
          maxHeight: size.height * (compact ? .94 : .88),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(compact ? 20 : 28, 20, 16, 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _label(row.transactionInvoiceNo ?? ''),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(
              child: loading
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(compact ? 20 : 28),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final overview = _overview(context);
                          final timeline = PreIpoOrderProgress(
                            order: order,
                            showOrderHeader: true,
                          );
                          if (constraints.maxWidth < 760) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                overview,
                                const SizedBox(height: 20),
                                timeline,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: overview),
                              const SizedBox(width: 24),
                              Expanded(flex: 5, child: timeline),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview(BuildContext context) {
    final row = order;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            LogoImage(url: row.company.logo, radius: 14, width: 56, height: 56),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label(row.company.brandName),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlisted shares',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payable amount',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _money.format(row.payableAmount),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${NumberFormat.decimalPattern('en_IN').format(row.shares)} shares × ${_money.format(row.sharePrice)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _section(context, 'Transaction overview', [
          if (row.tradeSide.isNotEmpty)
            _field(
              context,
              'Trade side',
              row.tradeSide == 'sell' ? 'Sell' : 'Buy',
            ),
          if (row.orderSource.isNotEmpty)
            _field(
              context,
              'Source',
              row.orderSource == 'enquiry' ? 'Enquiry' : 'Direct order',
            ),
          _field(context, 'Investor', _label(row.investor.displayName)),
          if (row.createdAt != null)
            _field(context, 'Created on', _date(row.createdAt)),
          if (row.paymentMode != null)
            _field(context, 'Payment mode', row.paymentMode!),
          if (row.instrument != null)
            _field(context, 'Instrument', row.instrument!),
          if (row.settlementLabel != null && row.settlementLabel!.isNotEmpty)
            _field(context, 'Settlement', row.settlementLabel!),
          if (row.settlementDate != null)
            _field(context, 'Settlement date', _date(row.settlementDate)),
        ]),
        const SizedBox(height: 24),
        _section(context, 'Amount breakdown', [
          _field(context, 'Investor price', _money.format(row.sharePrice)),
          _field(context, 'Deal price', _money.format(row.distributerPrice)),
          PreIpoOrderAmountDetails(order: row),
          const Divider(height: 24),
          _field(
            context,
            'Payable amount',
            _money.format(row.payableAmount),
            emphasis: true,
          ),
        ]),
        if (order.paymentDetails != null) ...[
          const SizedBox(height: 24),
          PreIpoPaymentDetailsPanel(details: order.paymentDetails!),
        ],
        if (order.hasDocuments) ...[
          const SizedBox(height: 24),
          PreIpoOrderDocumentsPanel(documents: order.documents),
        ],
        if (order.hasAction) ...[
          const SizedBox(height: 24),
          AbsorbPointer(
            absorbing: actionLoading,
            child: PreIpoOrderActionBar(order: order, onAction: _onAction),
          ),
        ],
      ],
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      );

  Widget _field(
    BuildContext context,
    String title,
    String value, {
    bool emphasis = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
