import 'package:private_deals/src/shared/app_exports.dart';

/// The offer selected before choosing investors, shared by desktop and mobile.
/// New Pre-IPO buy identifies the deal by numeric [dealId] and/or [dealUuid].
class PreIPOOffer {
  final int dealId;
  final String dealUuid;
  final int sellerId;
  final SharePriceSellerModel seller;
  final String key;
  final String name;
  final double price;
  final int minimumQty;
  final bool isDeal;
  final String dealType;

  PreIPOOffer.fromSeller(SellerSharePriceModel slot)
      : dealId = 0,
        dealUuid = '',
        seller = slot.seller,
        sellerId = slot.seller.id,
        key = 'seller:${slot.seller.id}:${slot.date}:${slot.sellPrice}',
        name = slot.seller.companyName,
        price = slot.sellPrice,
        minimumQty = slot.minQty,
        isDeal = false,
        dealType = 'sell';

  PreIPOOffer.fromDeal(DealModel deal)
      : dealId = deal.id,
        dealUuid = deal.uuid,
        seller = deal.seller,
        sellerId = deal.seller.id,
        key = 'deal:${deal.uuid.isNotEmpty ? deal.uuid : deal.id}',
        name = deal.seller.companyName.isNotEmpty
            ? deal.seller.companyName
            : 'Hot deal',
        price = deal.sharePrice,
        minimumQty = deal.minimumQty,
        isDeal = true,
        dealType = deal.dealType;

  /// Sell-side Institution deals only. Treat anything other than buy as sell.
  bool get isSellDeal => dealType.toLowerCase() != 'buy';

  bool get hasDealRef => dealId > 0 || dealUuid.isNotEmpty;

  bool get canBuy => isDeal && isSellDeal && hasDealRef;

  String? get buyBlockedReason {
    if (!isDeal) {
      return 'Buy orders require an Institution sell deal. Use Enquire instead.';
    }
    if (!isSellDeal) {
      return 'This is a buy deal. Selling from here is not available.';
    }
    if (!hasDealRef) {
      return 'This deal is missing an id and cannot be purchased yet.';
    }
    return null;
  }

  String? validateQuantity(String? value) {
    final quantity = int.tryParse(value ?? '');
    if (quantity == null || quantity <= 0) {
      return 'Enter a whole number of shares';
    }
    if (quantity < minimumQty) return 'Min quantity is $minimumQty shares';
    return null;
  }

  String? validatePrice(String? value) {
    final amount = double.tryParse(value ?? '');
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter valid amount';
    }
    if (amount < price) return 'Min price ${price.toCurrency}';
    return null;
  }
}

List<DealModel> availablePreIPODeals(CompanyModel company) => company.deals
    .where((deal) => deal.status.toLowerCase() == 'available')
    .toList();

class PreIPOInvestmentSelection {
  final CompanyModel company;
  final PreIPOOffer offer;
  PreIPOInvestmentSelection(this.company, this.offer);
}
