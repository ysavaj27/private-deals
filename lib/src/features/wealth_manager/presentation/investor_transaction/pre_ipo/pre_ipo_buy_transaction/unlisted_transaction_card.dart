import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_order_widgets.dart';

class UnlistedTransactionCard extends StatelessWidget {
  const UnlistedTransactionCard({
    super.key,
    required this.order,
    required this.onDetails,
    required this.onAction,
    this.isActionLoading = false,
  });

  final PreIpoOrderModel order;
  final VoidCallback onDetails;
  final Future<void> Function(String) onAction;
  final bool isActionLoading;

  String _money(double value) => value == 0 ? '₹ 0' : value.toCurrency;
  String _date(DateTime value) =>
      DateFormat('dd MMM yyyy').format(value.toLocal());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final terminal = order.isCompleted || order.isCancelled;
    final status = order.orderStep.trim().isEmpty
        ? (order.currentStatus ?? 'Status unavailable')
        : order.orderStep.replaceAll('_', ' ');
    final statusLabel = status.isEmpty
        ? 'Status unavailable'
        : '${status[0].toUpperCase()}${status.substring(1)}';
    final statusColor = order.isCancelled
        ? colors.error
        : order.isCompleted
        ? (theme.brightness == Brightness.dark
              ? const Color(0xFF6EE7B7)
              : const Color(0xFF087A55))
        : colors.primary;
    final current = order.current.trim().isNotEmpty
        ? order.current.trim()
        : order.currentStatus?.trim();
    final next = order.next?.trim();
    final reason = order.cancellationReason?.trim();
    final invoice = order.transactionInvoiceNo?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, box) {
              final identity = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.company.logo.isEmpty)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        color: colors.onPrimaryContainer,
                      ),
                    )
                  else
                    LogoImage(
                      url: order.company.logo,
                      width: 44,
                      height: 44,
                      radius: 12,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.company.brandName.isEmpty
                              ? 'Unlisted company'
                              : order.company.brandName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (order.tradeSide.isNotEmpty)
                          Text(
                            order.tradeSide == 'sell' ? 'Sell' : 'Buy',
                            style: theme.textTheme.labelMedium,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          order.investor.displayName,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final badge = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.isCancelled
                          ? Icons.cancel_outlined
                          : order.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.schedule_rounded,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (box.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [identity, const SizedBox(height: 12), badge],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: identity),
                  const SizedBox(width: 16),
                  Flexible(child: badge),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (invoice != null && invoice.isNotEmpty)
                Text(
                  '#$invoice',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              if (order.createdAt != null)
                Text(
                  'Placed ${_date(order.createdAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth < 500
                  ? 2
                  : order.settlementDate != null
                  ? 4
                  : 3;
              final metrics = [
                ('Shares', NumberFormat('#,##,##0').format(order.shares)),
                ('Price per share', _money(order.sharePrice)),
                ('Total payable', _money(order.payableAmount)),
                if (order.settlementLabel != null &&
                    order.settlementLabel!.isNotEmpty)
                  ('Settlement', order.settlementLabel!),
                if (order.settlementDate != null)
                  ('Settlement date', _date(order.settlementDate!)),
              ];
              return Wrap(
                spacing: 16,
                runSpacing: 18,
                children: [
                  for (final metric in metrics)
                    SizedBox(
                      width: (box.maxWidth - (columns - 1) * 16) / columns,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metric.$1,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            metric.$2,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: metric.$1 == 'Total payable' ? 18 : 14,
                              color: metric.$1 == 'Total payable'
                                  ? colors.primary
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
          if ((current != null && current.isNotEmpty) ||
              (!terminal && next != null && next.isNotEmpty && next != 'N/A') ||
              (reason != null && reason.isNotEmpty)) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (current != null && current.isNotEmpty)
                    Text(
                      current,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (!terminal &&
                      next != null &&
                      next.isNotEmpty &&
                      next != 'N/A' &&
                      next != current) ...[
                    if (current != null && current.isNotEmpty)
                      const SizedBox(height: 6),
                    Text(
                      'Next: $next',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ],
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Reason: $reason',
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, box) {
              final details = OutlinedButton.icon(
                onPressed: isActionLoading ? null : onDetails,
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('View details'),
              );
              final actions = isActionLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : PreIpoOrderActionBar(
                      order: order,
                      compact: true,
                      onAction: onAction,
                    );
              if (box.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.hasAction || isActionLoading) ...[
                      actions,
                      const SizedBox(height: 8),
                    ],
                    details,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: actions),
                  const SizedBox(width: 16),
                  details,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
