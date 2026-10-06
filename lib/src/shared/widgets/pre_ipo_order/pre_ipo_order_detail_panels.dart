import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/app_exports.dart' show Launcher;
import 'pre_ipo_order_widgets.dart';

String _date(DateTime value) =>
    DateFormat('dd MMM yyyy').format(value.toLocal());

/// Extra detail data is hidden until supplied by the backend.
class PreIpoOrderOverview extends StatelessWidget {
  final PreIpoOrderModel order;

  const PreIpoOrderOverview({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final fields = <String, String?>{
      'Invoice number': order.transactionInvoiceNo,
      'Created on': order.createdAt == null ? null : _date(order.createdAt!),
      'Payment mode': order.paymentMode,
      'Instrument': order.instrument,
      'Settlement': order.settlementLabel,
      'Settlement date': order.settlementDate == null
          ? null
          : _date(order.settlementDate!),
    }..removeWhere((_, value) => value == null || value.trim().isEmpty);
    if (fields.isEmpty) return const SizedBox.shrink();
    return _DetailSection(
      title: 'Transaction overview',
      children: [
        for (final field in fields.entries)
          _DetailField(label: field.key, value: field.value!),
      ],
    );
  }
}

/// Inserted into the existing price breakdown; absent amounts are not zero fees.
class PreIpoOrderAmountDetails extends StatelessWidget {
  final PreIpoOrderModel order;

  const PreIpoOrderAmountDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    final fields = <String, double?>{
      'Investment amount': order.investmentAmount,
      'Processing fee': order.processingFee,
      'Coupon discount': order.couponDiscountAmount,
    }..removeWhere((_, value) => value == null);
    return Column(
      children: [
        for (final field in fields.entries)
          _DetailField(label: field.key, value: money.format(field.value)),
      ],
    );
  }
}

class PreIpoOrderProgress extends StatelessWidget {
  final PreIpoOrderModel order;
  final bool showOrderHeader;

  const PreIpoOrderProgress({
    super.key,
    required this.order,
    this.showOrderHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final percentage = order.percentage;
    final progress = percentage != null && percentage.isFinite
        ? percentage.clamp(0, 100).toDouble()
        : null;
    final status = order.currentStatus?.trim() ?? '';
    final next = order.nextStep?.trim() ?? '';
    // Current/next already appear in the existing order header.
    final showStatus = status.isNotEmpty && status != order.current;
    final showNext = next.isNotEmpty && next != 'N/A' && next != order.next;
    final activeIndex = order.statusList.indexWhere((step) => step.isActive);
    if (progress == null &&
        order.statusList.isEmpty &&
        !showStatus &&
        !showNext &&
        !showOrderHeader) {
      return const SizedBox.shrink();
    }
    return _DetailSection(
      title: 'Transaction progress',
      children: [
        if (showOrderHeader) ...[
          PreIpoOrderStepHeader(order: order),
          const SizedBox(height: 16),
        ],
        if (showStatus)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(status, style: TextStyle(color: colors.primary)),
          ),
        if (progress != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
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
                Text('${progress.round()}%'),
              ],
            ),
          ),
        if (showNext)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('Next step: $next'),
          ),
        for (var i = 0; i < order.statusList.length; i++)
          _TimelineStep(
            step: order.statusList[i],
            // Historical steps may have neither a timestamp nor a completion
            // flag. Their position before the active step still marks them done.
            completed:
                !order.statusList[i].isActive &&
                (order.isCompleted ||
                    i < activeIndex ||
                    order.statusList[i].completed),
            last: i == order.statusList.length - 1,
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final PreIpoOrderStatus step;
  final bool last;
  final bool completed;

  const _TimelineStep({
    required this.step,
    required this.last,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final done = completed;
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
                  color: done || step.isActive
                      ? colors.primary
                      : colors.outline,
                  size: 22,
                  semanticLabel: done
                      ? 'Completed'
                      : step.isActive
                      ? 'Current step'
                      : 'Pending',
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
                  if (step.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      step.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (step.document != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: step.document!.url.isEmpty
                            ? null
                            : () => Launcher.openNewTab(step.document!.url),
                        icon: const Icon(Icons.description_outlined, size: 18),
                        label: Text(step.document!.displayName),
                      ),
                    ),
                  ],
                  if (step.date != null) ...[
                    const SizedBox(height: 6),
                    Text(_date(step.date!), style: theme.textTheme.labelSmall),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;

  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.right)),
      ],
    ),
  );
}
