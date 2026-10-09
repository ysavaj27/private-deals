import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'pre_ipo_detail_page_ctrl.dart';

/// One trade panel with fixed tabs and enquiry, and a scrollable offer list.
class SellerSlotsWidget extends StatefulWidget {
  const SellerSlotsWidget({super.key});

  @override
  State<SellerSlotsWidget> createState() => _SellerSlotsWidgetState();
}

class _SellerSlotsWidgetState extends State<SellerSlotsWidget> {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();
  final ScrollController _offersScroll = ScrollController();
  bool _buy = true;

  @override
  void dispose() {
    _offersScroll.dispose();
    super.dispose();
  }

  void _selectSide(bool buy) {
    if (_buy == buy) return;
    if (_offersScroll.hasClients) _offersScroll.jumpTo(0);
    setState(() => _buy = buy);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.hasBoundedHeight
          ? constraints.maxHeight
          : (MediaQuery.sizeOf(context).height * 0.75).clamp(320.0, 760.0);
      final colors = Theme.of(context).colorScheme;
      return SizedBox(
        height: height,
        child: Container(
          key: const ValueKey('pre-ipo-trade-panel'),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Obx(() {
            final deals = availablePreIPODeals(c.model());
            final buyDeals = deals
                .where((deal) => PreIPOOffer.fromDeal(deal).isSellDeal)
                .toList();
            final sellDeals = deals
                .where((deal) => !PreIPOOffer.fromDeal(deal).isSellDeal)
                .toList();
            final activeDeals = _buy ? buyDeals : sellDeals;
            final hotDeals = activeDeals
                .where((deal) => deal.isHotDeal)
                .toList();
            final normalDeals = activeDeals
                .where((deal) => !deal.isHotDeal)
                .toList();
            final slots = _buy
                ? c.model().sellerSharePrices
                : <SellerSharePriceModel>[];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TradeHeader(
                  buy: _buy,
                  buyCount:
                      buyDeals.length + c.model().sellerSharePrices.length,
                  sellCount: sellDeals.length,
                  onChanged: _selectSide,
                ),
                const Divider(height: 1),
                Expanded(
                  child: Scrollbar(
                    controller: _offersScroll,
                    child: SingleChildScrollView(
                      key: const ValueKey('pre-ipo-offers-scroll'),
                      controller: _offersScroll,
                      primary: false,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hotDeals.isNotEmpty) ...[
                            _offerGroup(
                              context,
                              key: const ValueKey('hot-deals-section'),
                              title: 'Deal of the day',
                              featured: true,
                              rows: [
                                for (final deal in hotDeals)
                                  _dealRow(context, deal),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          _offerGroup(
                            context,
                            key: const ValueKey('available-offers-section'),
                            title: 'Available offers',
                            rows: [
                              for (final deal in normalDeals)
                                _dealRow(context, deal),
                              for (final slot in slots)
                                _OfferRow(
                                  seller: slot.seller,
                                  price: slot.sellPrice,
                                  minimumQty: slot.minQty,
                                  label: 'Seller',
                                  onTap: () => _showSeller(context, slot),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  key: const ValueKey('pre-ipo-enquiry-footer'),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Buying or selling in bulk?',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _enquire,
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 17,
                        ),
                        label: const Text('Enquire'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      );
    },
  );

  Widget _dealRow(BuildContext context, DealModel deal) {
    final offer = PreIPOOffer.fromDeal(deal);
    final sell = !offer.isSellDeal;
    return Obx(
      () => _OfferRow(
        seller: deal.seller,
        price: deal.sharePrice,
        minimumQty: deal.minimumQty,
        settlementLabel: deal.settlementLabel,
        label: sell ? 'Buyer' : 'Seller',
        selected: c.selectedOffer.value?.key == offer.key,
        onTap: () => _showDeal(context, deal),
        actionLabel: sell ? 'Sell' : 'Buy',
        showAction: sell || (offer.canBuy && c.model().canBuy),
        onAction: c.investing.value
            ? null
            : () {
                // Sell is intentionally a placeholder until its flow is ready.
                if (!sell) c.selectOffer(offer, phone: context.isPhone);
              },
      ),
    );
  }

  Widget _offerGroup(
    BuildContext context, {
    required Key key,
    required String title,
    required List<Widget> rows,
    bool featured = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              if (featured) ...[
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 18,
                  color: colors.secondary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: featured ? colors.secondary : colors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${rows.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Text(
              _buy
                  ? 'No regular buy offers at the moment.'
                  : 'No regular sell offers at the moment.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        for (var index = 0; index < rows.length; index++) ...[
          if (index > 0) const Divider(height: 1, indent: 20, endIndent: 20),
          if (featured)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.3),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: rows[index],
            )
          else
            rows[index],
        ],
      ],
    );
  }

  Future<void> _enquire() async {
    final created = await showCustomDialog(
      DesktopEnquiryDialogView(c.model().slug),
    );
    if (created == true && !c.isClosed) {
      Get.offAllNamed(Routes.enquiriesPath());
    }
  }

  Future<void> _showDeal(BuildContext context, DealModel deal) async {
    final phone = context.isPhone;
    final offer = PreIPOOffer.fromDeal(deal);
    final buyerWanted = !offer.isSellDeal;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _OfferDialog(
        title: buyerWanted ? 'Buyer details' : 'Offer details',
        child: Obx(() {
          final selected = c.selectedOffer.value?.key == offer.key;
          final colors = Theme.of(dialogContext).colorScheme;
          final profile = SellerProfileWidget(
            seller: deal.seller,
            label: buyerWanted ? 'Buyer' : 'Seller',
            showDetails: true,
          );
          final offerInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _OfferBadge(
                    buyerWanted ? 'Buyer available' : 'Shares for sale',
                  ),
                  if (deal.isHotDeal) const _OfferBadge('Hot deal'),
                  if (selected) const _OfferBadge('Selected'),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Price per share',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                deal.sharePrice.toCurrency,
                style: Theme.of(dialogContext).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _OfferDetail(
                'Minimum quantity',
                '${deal.minimumQty.toShowNum} shares',
              ),
              if (deal.settlementLabel != null &&
                  deal.settlementLabel!.isNotEmpty)
                _OfferDetail('Settlement', deal.settlementLabel!),
              if (deal.availableQuantity.isNotEmpty)
                _OfferDetail(
                  'Available quantity',
                  '${deal.availableQuantity.toShowNum} shares',
                ),
              const SizedBox(height: 20),
              if (buyerWanted)
                CustomOutlinedButton(
                  color: colors.primary,
                  width: double.infinity,
                  height: 48,
                  text: 'Sell',
                  onPressed: () {},
                ),
              if (offer.canBuy && c.model().canBuy)
                IgnorePointer(
                  ignoring: c.investing.value,
                  child: CustomElevatedButton(
                    height: 48,
                    radius: 10,
                    backgroundColor: AppColors.preIpoButton(dialogContext),
                    text: selected && c.investorList.isNotEmpty
                        ? 'Add Investors'
                        : 'Buy Now',
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              if (!buyerWanted && !(offer.canBuy && c.model().canBuy))
                Text(
                  offer.buyBlockedReason ??
                      'Buying is not available for this deal.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          );
          return _OfferSplitPane(profile: profile, offer: offerInfo);
        }),
      ),
    );
    // Close the information dialog before opening the existing investment flow.
    if (proceed == true) await c.selectOffer(offer, phone: phone);
  }

  Future<void> _showSeller(
    BuildContext context,
    SellerSharePriceModel slot,
  ) async {
    final enquire = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _OfferDialog(
        title: 'Seller details',
        child: _OfferSplitPane(
          profile: SellerProfileWidget(seller: slot.seller, showDetails: true),
          offer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _OfferDetail('Price per share', slot.sellPrice.toCurrency),
              _OfferDetail(
                'Minimum quantity',
                '${slot.minQty.toShowNum} shares',
              ),
              if (slot.totalQty > 0)
                _OfferDetail(
                  'Available quantity',
                  '${slot.totalQty.toShowNum} shares',
                ),
              const SizedBox(height: 16),
              Text(
                'Contact us to buy from this seller.',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Enquire'),
              ),
            ],
          ),
        ),
      ),
    );
    if (enquire == true) await _enquire();
  }
}

class _TradeHeader extends StatelessWidget {
  const _TradeHeader({
    required this.buy,
    required this.buyCount,
    required this.sellCount,
    required this.onChanged,
  });
  final bool buy;
  final int buyCount;
  final int sellCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: const ValueKey('pre-ipo-trade-header'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Trade unlisted shares', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Compare offers. Prices per share.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _tab(context, true, buyCount)),
              const SizedBox(width: 8),
              Expanded(child: _tab(context, false, sellCount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, bool isBuy, int count) {
    final colors = Theme.of(context).colorScheme;
    final selected = buy == isBuy;
    return Semantics(
      selected: selected,
      child: TextButton(
        key: ValueKey(isBuy ? 'buy-deals-tab' : 'sell-deals-tab'),
        onPressed: () => onChanged(isBuy),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          backgroundColor: selected
              ? colors.primaryContainer
              : colors.surfaceContainer,
          foregroundColor: selected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text(isBuy ? 'Buy' : 'Sell'),
            Text('$count', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.seller,
    required this.price,
    required this.minimumQty,
    required this.label,
    required this.onTap,
    this.settlementLabel,
    this.selected = false,
    this.showAction = false,
    this.actionLabel = 'Buy',
    this.onAction,
  });
  final SharePriceSellerModel seller;
  final double price;
  final int minimumQty;
  final String? settlementLabel;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool showAction;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SellerProfileWidget(seller: seller, label: label),
                  ),
                  const SizedBox(width: 12),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: colors.primary,
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price.toCurrency,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          settlementLabel == null || settlementLabel!.isEmpty
                              ? 'Min. ${minimumQty.toShowNum} shares'
                              : 'Min. ${minimumQty.toShowNum} shares · $settlementLabel',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showAction) ...[
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(68, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferSplitPane extends StatelessWidget {
  const _OfferSplitPane({required this.profile, required this.offer});

  final Widget profile;
  final Widget offer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 560;
        if (!sideBySide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              profile,
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              offer,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: profile),
              const SizedBox(width: 20),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: offer),
            ],
          ),
        );
      },
    );
  }
}

class _OfferDialog extends StatelessWidget {
  const _OfferDialog({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    ),
  );
}

class _OfferDetail extends StatelessWidget {
  const _OfferDetail(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    ),
  );
}

class _OfferBadge extends StatelessWidget {
  const _OfferBadge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer),
    ),
  );
}
