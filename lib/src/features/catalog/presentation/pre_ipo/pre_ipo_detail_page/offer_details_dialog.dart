import 'package:flutter/material.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/extensions/num_extensions.dart';

/// Presents the quote above the partner profile, with an action footer that
/// stays accessible while long content scrolls.
class OfferDetailsDialog extends StatefulWidget {
  const OfferDetailsDialog({
    super.key,
    required this.title,
    required this.seller,
    required this.price,
    required this.minimumQty,
    required this.badges,
    required this.footerText,
    this.action,
    this.buyerWanted = false,
    this.settlement,
    this.availableQuantity,
  });

  final String title;
  final SharePriceSellerModel seller;
  final double price;
  final int minimumQty;
  final List<String> badges;
  final String footerText;
  final Widget? action;
  final bool buyerWanted;
  final String? settlement;
  final String? availableQuantity;

  @override
  State<OfferDetailsDialog> createState() => _OfferDetailsDialogState();
}

class _OfferDetailsDialogState extends State<OfferDetailsDialog> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Dialog(
      backgroundColor: colors.surface,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 600;
            final padding = compact ? 20.0 : 28.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 16, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: Scrollbar(
                    controller: _scroll,
                    child: SingleChildScrollView(
                      key: const ValueKey('offer-details-scroll'),
                      controller: _scroll,
                      padding: EdgeInsets.all(padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InvestmentSummary(
                            price: widget.price,
                            minimumQty: widget.minimumQty,
                            settlement: widget.settlement,
                            availableQuantity: widget.availableQuantity,
                            badges: widget.badges,
                            buyerWanted: widget.buyerWanted,
                          ),
                          const SizedBox(height: 28),
                          Text(
                            widget.buyerWanted
                                ? 'About the buyer'
                                : 'About the seller',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          SellerProfileWidget(
                            seller: widget.seller,
                            label: widget.buyerWanted ? 'Buyer' : 'Seller',
                            showDetails: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  key: const ValueKey('offer-details-footer'),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 16,
                  ),
                  child: _ActionFooter(
                    text: widget.footerText,
                    action: widget.action,
                    compact:
                        compact ||
                        MediaQuery.textScalerOf(context).scale(14) > 20,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InvestmentSummary extends StatelessWidget {
  const _InvestmentSummary({
    required this.price,
    required this.minimumQty,
    required this.badges,
    required this.buyerWanted,
    this.settlement,
    this.availableQuantity,
  });

  final double price;
  final int minimumQty;
  final List<String> badges;
  final bool buyerWanted;
  final String? settlement;
  final String? availableQuantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final metrics = [
      _OfferMetric('Price per share', price.toCurrency),
      _OfferMetric('Minimum quantity', '${minimumQty.toShowNum} shares'),
      if (settlement != null && settlement!.isNotEmpty)
        _OfferMetric('Settlement', settlement!),
      if (availableQuantity != null && availableQuantity!.isNotEmpty)
        _OfferMetric('Available quantity', '$availableQuantity shares'),
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Text(
                      buyerWanted ? 'Offer summary' : 'Investment details',
                      style: theme.textTheme.titleSmall,
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final badge in badges) _OfferBadge(badge),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final scale =
                        MediaQuery.textScalerOf(context).scale(14) / 14;
                    final columns = (constraints.maxWidth / (128 * scale))
                        .floor()
                        .clamp(1, metrics.length);
                    final width =
                        (constraints.maxWidth - (columns - 1) * 20) / columns;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        for (final metric in metrics)
                          SizedBox(width: width, child: metric),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            key: const ValueKey('offer-minimum-amount'),
            padding: const EdgeInsets.all(20),
            color: colors.primaryContainer.withValues(alpha: 0.5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final description = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buyerWanted
                          ? 'Minimum offer amount'
                          : 'Minimum investment amount',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${price.toCurrency} × ${minimumQty.toShowNum} shares',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
                final minimumAmount = Text(
                  (price * minimumQty).toCurrency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                  ),
                );
                if (constraints.maxWidth < 560 ||
                    MediaQuery.textScalerOf(context).scale(14) > 20) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      description,
                      const SizedBox(height: 12),
                      minimumAmount,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: description),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: minimumAmount,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferMetric extends StatelessWidget {
  const _OfferMetric(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ActionFooter extends StatelessWidget {
  const _ActionFooter({required this.text, required this.compact, this.action});
  final String text;
  final bool compact;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final description = Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
    if (action == null) return description;
    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [description, const SizedBox(height: 12), action!],
      );
    }
    return Row(
      children: [
        Expanded(child: description),
        const SizedBox(width: 24),
        SizedBox(width: 200, child: action),
      ],
    );
  }
}

class _OfferBadge extends StatelessWidget {
  const _OfferBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
