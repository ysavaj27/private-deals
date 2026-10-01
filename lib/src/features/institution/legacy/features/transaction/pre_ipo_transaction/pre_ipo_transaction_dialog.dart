import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/transaction/pre_ipo_transaction_model.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';

class PreIPOTransactionDialog extends StatelessWidget {
  PreIPOTransactionDialog({super.key, required this.transaction});

  final PreIPOTransactionModel transaction;
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
    final row = transaction;
    return Dialog(
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
                          _label(row.transactionInvoiceNo),
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 20 : 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final overview = _overview(context);
                    final timeline = _timeline(context);
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
    final row = transaction;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            LogoImage(
              url: row.company.logo.startsWith('http')
                  ? row.company.logo
                  : Parse.parseUrl(row.company.logo),
              radius: 14,
            ),
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
          _field(context, 'Investor', _label(row.investor.name)),
          _field(context, 'Created on', _date(row.createdAt)),
          _field(context, 'Payment mode', _label(row.paymentMode)),
          _field(context, 'Instrument', _label(row.instrument)),
          _field(context, 'Settlement date', _date(row.settlementDate)),
        ]),
        const SizedBox(height: 24),
        _section(context, 'Amount breakdown', [
          _field(
            context,
            'Investment amount',
            _money.format(row.investmentAmount),
          ),
          _field(context, 'Processing fee', _money.format(row.processingFee)),
          _field(
            context,
            'Coupon discount',
            _money.format(row.couponDiscountAmount),
          ),
          const Divider(height: 24),
          _field(
            context,
            'Payable amount',
            _money.format(row.payableAmount),
            emphasis: true,
          ),
        ]),
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

  Widget _timeline(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final row = transaction;
    final progress = row.percentage.isFinite
        ? row.percentage.clamp(0, 100).toDouble()
        : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transaction progress',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _label(row.currentStatus),
            style: theme.textTheme.titleSmall?.copyWith(color: colors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(6),
                  semanticsLabel: 'Transaction progress',
                  semanticsValue: '${progress.round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Text('${progress.round()}%', style: theme.textTheme.labelLarge),
            ],
          ),
          if (row.nextStep.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Next step', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              row.nextStep,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (row.statusList.isNotEmpty) ...[
            const Divider(height: 32),
            for (var i = 0; i < row.statusList.length; i++)
              _step(context, row.statusList[i], i == row.statusList.length - 1),
          ],
        ],
      ),
    );
  }

  Widget _step(BuildContext context, TransactionStatusModel step, bool last) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final done = step.date != null;
    final color = done || step.isActive ? colors.primary : colors.outline;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : step.isActive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: color,
                  size: 22,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isActive ? colors.primary : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  if (step.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _date(step.date),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
