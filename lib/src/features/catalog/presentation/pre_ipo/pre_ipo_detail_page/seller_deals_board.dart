import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'offer_details_dialog.dart';
import 'pre_ipo_detail_page_ctrl.dart';

/// Seller view of a company's market: deals listed below the company header.
/// Sellers can buy against sell deals and raise sell enquiries against buyer
/// interest using the same enquiry dialog as wealth managers.
class SellerDealsBoard extends StatefulWidget {
  const SellerDealsBoard({super.key});

  @override
  State<SellerDealsBoard> createState() => _SellerDealsBoardState();
}

class _SellerDealsBoardState extends State<SellerDealsBoard> {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();
  bool _buy = true;

  @override
  Widget build(BuildContext context) => Obx(() {
    final company = c.model();
    final deals = availablePreIPODeals(company);
    final buyDeals = deals
        .where((deal) => PreIPOOffer.fromDeal(deal).isSellDeal)
        .toList();
    final sellDeals = deals
        .where((deal) => !PreIPOOffer.fromDeal(deal).isSellDeal)
        .toList();
    final active = _buy ? buyDeals : sellDeals;
    final hot = active.where((deal) => deal.isHotDeal).toList();
    final normal = active.where((deal) => !deal.isHotDeal).toList();
    final slots = _buy
        ? company.sellerSharePrices
        : <SellerSharePriceModel>[];
    return Column(
      key: const ValueKey('seller-deals-board'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BoardHeader(
          buy: _buy,
          buyCount: buyDeals.length + company.sellerSharePrices.length,
          sellCount: sellDeals.length,
          onChanged: (buy) => setState(() => _buy = buy),
        ),
        const SizedBox(height: AppSpace.xl),
        if (hot.isNotEmpty) ...[
          _DealGroup(
            key: const ValueKey('seller-hot-deals'),
            title: 'Deal of the day',
            partyLabel: _buy ? 'Seller' : 'Buyer',
            featured: true,
            rows: [
              for (final deal in hot)
                (wide) => _dealRow(context, deal, wide: wide),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
        ],
        _DealGroup(
          key: const ValueKey('seller-available-offers'),
          title: 'Available offers',
          partyLabel: _buy ? 'Seller' : 'Buyer',
          rows: [
            for (final deal in normal)
              (wide) => _dealRow(context, deal, wide: wide),
            for (final slot in slots)
              (wide) => _slotRow(context, slot, wide: wide),
          ],
          emptyText: _buy
              ? 'No buy offers at the moment.'
              : 'No sell offers at the moment.',
        ),
      ],
    );
  });

  Widget _dealRow(BuildContext context, DealModel deal, {required bool wide}) {
    final offer = PreIPOOffer.fromDeal(deal);
    final buyerWanted = !offer.isSellDeal;
    final own = offer.isOwnDeal;
    return Obx(() {
      final canBuy = !buyerWanted && offer.canBuy && c.model().canBuy;
      return SellerDealRow(
        key: ValueKey('seller-deal-${offer.key}'),
        wide: wide,
        seller: deal.seller,
        label: buyerWanted ? 'Buyer' : 'Seller',
        price: deal.sharePrice,
        minimumQty: deal.minimumQty,
        settlementLabel: deal.settlementLabel,
        availableQuantity: deal.availableQuantity.isNotEmpty
            ? deal.availableQuantity.toShowNum
            : null,
        hot: deal.isHotDeal,
        own: own,
        selected: c.selectedOffer.value?.key == offer.key,
        hint: _dealHint(offer, buyerWanted: buyerWanted, own: own),
        actionLabel: buyerWanted ? 'Sell' : 'Buy',
        showAction: canBuy || (buyerWanted && !own),
        onAction: c.investing.value
            ? null
            : buyerWanted
            ? () => _enquire(sellOffer: deal)
            : canBuy
            ? () => c.selectOffer(offer, phone: context.isPhone)
            : null,
        onTap: () => _showDeal(context, deal),
      );
    });
  }

  Future<void> _enquire({DealModel? sellOffer}) async {
    final created = await showCustomDialog(
      DesktopEnquiryDialogView(
        c.model().slug,
        initialType: sellOffer != null || !_buy
            ? InvestmentTypeEnum.sell
            : InvestmentTypeEnum.buy,
        initialQuantity: sellOffer?.minimumQty,
        initialOfferPrice: sellOffer?.sharePrice,
        initialSettlementDays: sellOffer?.settlementDays,
        explanation: sellOffer == null
            ? null
            : 'Create an open sell enquiry using these terms. A counterparty '
                  'must accept the enquiry before a transaction is created.',
      ),
    );
    if (created == true && !c.isClosed) {
      Get.offAllNamed(Routes.enquiriesPath());
    }
  }

  Widget _slotRow(
    BuildContext context,
    SellerSharePriceModel slot, {
    required bool wide,
  }) => SellerDealRow(
    wide: wide,
    seller: slot.seller,
    label: 'Seller',
    price: slot.sellPrice,
    minimumQty: slot.minQty,
    availableQuantity: slot.totalQty > 0 ? slot.totalQty.toShowNum : null,
    hint: 'Listed by seller',
    onTap: () => _showSeller(context, slot),
  );

  String _dealHint(
    PreIPOOffer offer, {
    required bool buyerWanted,
    required bool own,
  }) {
    if (own) return 'Your deal';
    if (buyerWanted) return 'Buyer looking at this price';
    if (!c.model().canBuy) return 'Buying is not available for this company';
    return offer.buyBlockedReason ?? 'Ready to buy';
  }

  Future<void> _showDeal(BuildContext context, DealModel deal) async {
    final phone = context.isPhone;
    final offer = PreIPOOffer.fromDeal(deal);
    final buyerWanted = !offer.isSellDeal;
    final own = offer.isOwnDeal;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Obx(() {
        final selected = c.selectedOffer.value?.key == offer.key;
        final canBuy = !buyerWanted && offer.canBuy && c.model().canBuy;
        return OfferDetailsDialog(
          title: buyerWanted ? 'Buyer details' : 'Offer details',
          seller: deal.seller,
          buyerWanted: buyerWanted,
          price: deal.sharePrice,
          minimumQty: deal.minimumQty,
          settlement: deal.settlementLabel,
          availableQuantity: deal.availableQuantity.isNotEmpty
              ? deal.availableQuantity.toShowNum
              : null,
          badges: [
            if (own) 'Your deal',
            buyerWanted ? 'Buyer available' : 'Shares for sale',
            if (deal.isHotDeal) 'Hot deal',
            if (selected) 'Selected',
          ],
          footerText: own
              ? 'This is your own deal. Other partners can trade against it.'
              : buyerWanted
              ? 'Use this price and minimum quantity to raise a sell enquiry.'
              : canBuy
              ? 'Enter the quantity for your own account in the next step.'
              : _dealHint(offer, buyerWanted: buyerWanted, own: own),
          action: canBuy
              ? FilledButton(
                  onPressed: c.investing.value
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Buy Now'),
                )
              : buyerWanted && !own
              ? FilledButton(
                  onPressed: c.investing.value
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Sell Now'),
                )
              : null,
        );
      }),
    );
    if (proceed == true && mounted && !c.isClosed) {
      if (buyerWanted) {
        await _enquire(sellOffer: deal);
      } else {
        await c.selectOffer(offer, phone: phone);
      }
    }
  }

  Future<void> _showSeller(BuildContext context, SellerSharePriceModel slot) =>
      showDialog<void>(
        context: context,
        builder: (_) => OfferDetailsDialog(
          title: 'Seller details',
          seller: slot.seller,
          price: slot.sellPrice,
          minimumQty: slot.minQty,
          availableQuantity: slot.totalQty > 0
              ? slot.totalQty.toShowNum
              : null,
          badges: const ['Shares for sale'],
          footerText: 'Shares listed for sale at this price.',
        ),
      );
}

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({
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
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Market prices', style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Live offers for this company. Prices per share.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
    final toggle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideTab(
          key: const ValueKey('seller-buy-tab'),
          label: 'Buy',
          count: buyCount,
          selected: buy,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: AppSpace.sm),
        _SideTab(
          key: const ValueKey('seller-sell-tab'),
          label: 'Sell',
          count: sellCount,
          selected: !buy,
          onTap: () => onChanged(false),
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: AppSpace.lg), toggle],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: AppSpace.lg),
            toggle,
          ],
        );
      },
    );
  }
}

class _SideTab extends StatelessWidget {
  const _SideTab({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(96, 44),
          backgroundColor: selected
              ? colors.primaryContainer
              : colors.surfaceContainer,
          foregroundColor: selected
              ? colors.onPrimaryContainer
              : colors.onSurfaceVariant,
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.sm,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: AppSpace.sm),
            Text('$count', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

/// Column widths shared by the list header and every [SellerDealRow].
abstract final class _Cols {
  static const party = 4;
  static const price = 2;
  static const minQty = 2;
  static const settlement = 2;
  static const available = 2;
  static const double action = 120;
}

/// Width at which rows switch from stacked (phone) to table columns.
const double _wideBreakpoint = 760;

class _DealGroup extends StatelessWidget {
  const _DealGroup({
    super.key,
    required this.title,
    required this.partyLabel,
    required this.rows,
    this.featured = false,
    this.emptyText,
  });
  final String title;
  final String partyLabel;
  final List<Widget Function(bool wide)> rows;
  final bool featured;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (featured) ...[
              Icon(
                Icons.local_fire_department_outlined,
                size: 18,
                color: colors.secondary,
              ),
              const SizedBox(width: AppSpace.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: featured ? colors.secondary : colors.onSurface,
                ),
              ),
            ),
            Text(
              '${rows.length}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        if (rows.isEmpty)
          _EmptyDeals(text: emptyText ?? 'No offers at the moment.')
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= _wideBreakpoint;
              return Container(
                decoration: BoxDecoration(
                  color: featured
                      ? colors.secondaryContainer.withValues(alpha: 0.18)
                      : colors.surface,
                  borderRadius: AppRadii.lgAll,
                  border: Border.all(
                    color: featured
                        ? colors.secondary.withValues(alpha: 0.4)
                        : colors.outlineVariant,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide) ...[
                      _ListHeader(partyLabel: partyLabel),
                      Divider(height: 1, color: colors.outlineVariant),
                    ],
                    for (var i = 0; i < rows.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          indent: AppSpace.lg,
                          endIndent: AppSpace.lg,
                          color: colors.outlineVariant,
                        ),
                      rows[i](wide),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.partyLabel});
  final String partyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    Widget cell(String text, int flex) =>
        Expanded(flex: flex, child: Text(text, style: style));
    return Container(
      key: const ValueKey('seller-deals-list-header'),
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          cell(partyLabel, _Cols.party),
          cell('Price / share', _Cols.price),
          cell('Min. quantity', _Cols.minQty),
          cell('Settlement', _Cols.settlement),
          cell('Available', _Cols.available),
          SizedBox(
            width: _Cols.action,
            child: Text('Action', style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _EmptyDeals extends StatelessWidget {
  const _EmptyDeals({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('seller-deals-empty'),
      padding: AppSpace.paddingXl,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 22,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SellerDealRow extends StatelessWidget {
  const SellerDealRow({
    super.key,
    required this.wide,
    required this.seller,
    required this.label,
    required this.price,
    required this.minimumQty,
    required this.hint,
    required this.onTap,
    this.settlementLabel,
    this.availableQuantity,
    this.hot = false,
    this.own = false,
    this.selected = false,
    this.showAction = false,
    this.actionLabel = 'Buy',
    this.onAction,
  });

  /// Table columns on wide layouts; stacked summary on phone.
  final bool wide;
  final SharePriceSellerModel seller;
  final String label;
  final double price;
  final int minimumQty;
  final String? settlementLabel;
  final String? availableQuantity;
  final bool hot;
  final bool own;
  final bool selected;

  /// Shown in place of the action button when the row has no action.
  final String hint;
  final bool showAction;
  final String actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onTap;

  bool get _hasSettlement =>
      settlementLabel != null && settlementLabel!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.lg,
            vertical: AppSpace.md,
          ),
          child: wide ? _wide(context) : _compact(context),
        ),
      ),
    );
  }

  Widget _party() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(child: SellerProfileWidget(seller: seller, label: label)),
      if (own) ...[
        const SizedBox(width: AppSpace.sm),
        const _RowBadge(key: ValueKey('own-deal-tag'), label: 'Your deal'),
      ] else if (hot) ...[
        const SizedBox(width: AppSpace.sm),
        const _RowBadge(label: 'Hot deal', accent: true),
      ],
    ],
  );

  Widget _action(BuildContext context) {
    final theme = Theme.of(context);
    if (showAction) {
      return FilledButton(
        onPressed: onAction,
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        ),
        child: Text(actionLabel),
      );
    }
    return Text(
      hint,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: wide ? TextAlign.end : TextAlign.start,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _wide(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final value = theme.textTheme.bodyMedium;
    Widget cell(String text, int flex, {TextStyle? style}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: AppSpace.sm),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: style ?? value,
        ),
      ),
    );
    return Row(
      children: [
        Expanded(
          flex: _Cols.party,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpace.lg),
            child: _party(),
          ),
        ),
        cell(
          price.toCurrency,
          _Cols.price,
          style: theme.textTheme.titleSmall?.copyWith(color: colors.primary),
        ),
        cell('${minimumQty.toShowNum} shares', _Cols.minQty),
        cell(_hasSettlement ? settlementLabel! : '—', _Cols.settlement),
        cell(availableQuantity ?? '—', _Cols.available),
        SizedBox(
          width: _Cols.action,
          child: Align(
            alignment: Alignment.centerRight,
            child: _action(context),
          ),
        ),
      ],
    );
  }

  Widget _compact(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final details = [
      'Min. ${minimumQty.toShowNum} shares',
      if (_hasSettlement) settlementLabel!,
      if (availableQuantity != null) '$availableQuantity available',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _party(),
        const SizedBox(height: AppSpace.md),
        Row(
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
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    details,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.md),
            if (showAction)
              _action(context)
            else
              Flexible(child: _action(context)),
          ],
        ),
      ],
    );
  }
}

class _RowBadge extends StatelessWidget {
  const _RowBadge({super.key, required this.label, this.accent = false});
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: accent
            ? colors.secondaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: AppRadii.smAll,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accent ? colors.onSecondaryContainer : colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
