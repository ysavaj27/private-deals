import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'pre_ipo_detail_page_ctrl.dart';

/// Offers stay compact on the page; their terms and actions live in a dialog.
class SellerSlotsWidget extends StatelessWidget {
  SellerSlotsWidget({super.key});

  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  @override
  Widget build(BuildContext context) => Obx(() {
    final deals = availablePreIPODeals(c.model());
    final hotDeals = deals.where((deal) => deal.isHotDeal).toList();
    final regularDeals = deals.where((deal) => !deal.isHotDeal).toList();
    final slots = c.model().sellerSharePrices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hotDeals.isNotEmpty) ...[
          _offerGroup(
            context,
            key: const ValueKey('hot-deals-section'),
            title: 'Deal of the day',
            featured: true,
            rows: [for (final deal in hotDeals) _dealRow(context, deal)],
          ),
          const SizedBox(height: 20),
        ],
        _offerGroup(
          context,
          key: const ValueKey('available-offers-section'),
          title: 'Available offers',
          rows: [
            for (final deal in regularDeals) _dealRow(context, deal),
            for (final slot in slots)
              _OfferRow(
                seller: slot.seller,
                price: slot.sellPrice,
                minimumQty: slot.minQty,
                label: 'Seller',
                onTap: () => _showSeller(context, slot),
              ),
          ],
          showEnquiry: true,
        ),
      ],
    );
  });

  Widget _dealRow(BuildContext context, DealModel deal) {
    final offer = PreIPOOffer.fromDeal(deal);
    return Obx(
      () => _OfferRow(
        seller: deal.seller,
        price: deal.sharePrice,
        minimumQty: deal.minimumQty,
        settlementLabel: deal.settlementLabel,
        label: deal.dealType == 'buy' ? 'Buyer available' : 'Shares for sale',
        selected: c.selectedOffer.value?.key == offer.key,
        onTap: () => _showDeal(context, deal),
        canBuy: offer.canBuy && c.model().canBuy,
        onBuy: c.investing.value
            ? null
            : () => c.selectOffer(offer, phone: context.isPhone),
      ),
    );
  }

  Widget _offerGroup(
    BuildContext context, {
    required Key key,
    required String title,
    required List<Widget> rows,
    bool featured = false,
    bool showEnquiry = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: key,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: featured
              ? colors.secondary.withValues(alpha: 0.5)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (featured) ...[
                      Icon(
                        Icons.local_fire_department_outlined,
                        size: 20,
                        color: colors.secondary,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: featured
                            ? colors.secondaryContainer
                            : colors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${rows.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: featured
                              ? colors.onSecondaryContainer
                              : colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rows.isEmpty
                      ? 'Contact us to explore availability.'
                      : featured
                      ? 'Featured hot deals. Prices per share.'
                      : 'Prices per share. Select an offer for details.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (rows.isNotEmpty) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 20, endIndent: 20),
              itemBuilder: (_, index) => rows[index],
            ),
          ],
          if (showEnquiry) ...[
            if (rows.isNotEmpty) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Buying or selling in bulk?',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Get in touch for your requirements.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
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
        ],
      ),
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
    final buyerWanted = deal.dealType == 'buy';
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
          profile: SellerProfileWidget(
            seller: slot.seller,
            showDetails: true,
          ),
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

class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.seller,
    required this.price,
    required this.minimumQty,
    required this.label,
    required this.onTap,
    this.settlementLabel,
    this.selected = false,
    this.canBuy = false,
    this.onBuy,
  });
  final SharePriceSellerModel seller;
  final double price;
  final int minimumQty;
  final String? settlementLabel;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool canBuy;
  final VoidCallback? onBuy;

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
                  if (canBuy) ...[
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onBuy,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(68, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Buy'),
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
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    ),
  );
}
