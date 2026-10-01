import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/enquiry_dialog_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';

class SellerSlotsWidget extends StatelessWidget {
  SellerSlotsWidget({super.key});

  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  @override
  Widget build(BuildContext context) => Obx(() {
        final deals = availablePreIPODeals(c.model());
        final slots = deals.isNotEmpty
            ? <SellerSharePriceModel>[]
            : c.model().sellerSharePrices;
        final selected = c.selectedOffer.value;
        if (deals.isEmpty && slots.isEmpty) return _enquiry(context);
        if (deals.isNotEmpty) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.local_fire_department, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text('Hot deals',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 6),
                const Text('Explore available buy and sell opportunities.'),
                const SizedBox(height: 16),
                for (final deal in deals) _dealCard(context, deal),
                _enquiry(context),
              ]);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available sellers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(slots.isEmpty
                ? 'No seller slots are available right now.'
                : 'Choose a seller to start your investment.'),
            const SizedBox(height: 16),
            for (final slot in slots)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected?.key == PreIPOOffer.fromSeller(slot).key
                        ? context.theme.primaryColor
                        : AppColors.borderColor(context),
                    width: selected?.key == PreIPOOffer.fromSeller(slot).key
                        ? 1.5
                        : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LogoImage(
                            url: slot.seller.logo,
                            height: 44,
                            width: 44,
                            fit: BoxFit.contain),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                        slot.seller.companyName.isEmpty
                            ? 'Seller'
                            : slot.seller.companyName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      )),
                      if (selected?.key == PreIPOOffer.fromSeller(slot).key)
                        Icon(Icons.check_circle,
                            color: context.theme.primaryColor, size: 22),
                    ]),
                    const SizedBox(height: 18),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _stat('Price per share',
                                  slot.sellPrice.toCurrency)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _stat(
                                  'Minimum quantity', '${slot.minQty} shares')),
                        ]),
                    const SizedBox(height: 18),
                    if (c.model().canBuy &&
                        slot.sellPrice > 0 &&
                        slot.minQty > 0 &&
                        (!slot.totalQty.isNotEmpty ||
                            slot.totalQty >= slot.minQty))
                      IgnorePointer(
                        ignoring: c.investing.value,
                        child: CustomElevatedButton(
                          height: 44,
                          radius: 10,
                          text: selected?.key ==
                                      PreIPOOffer.fromSeller(slot).key &&
                                  c.investorList.isNotEmpty
                              ? 'Add Investors'
                              : 'Buy Now',
                          onPressed: () => c.selectOffer(
                              PreIPOOffer.fromSeller(slot),
                              phone: context.isPhone),
                        ),
                      )
                    else
                      const Text('Currently unavailable'),
                  ],
                ),
              ),
            _enquiry(context),
          ],
        );
      });

  Widget _enquiry(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enquiry for bulk buying or selling?'),
          const SizedBox(height: 10),
          CustomOutlinedButton(
            color: context.theme.primaryColor,
            width: double.infinity,
            height: 44,
            text: 'Enquire',
            onPressed: () async {
              await showCustomDialog(DesktopEnquiryDialogView(c.model().slug));
              await Get.delete<EnquiryDialogCtrl>();
            },
          ),
        ]),
      );

  Widget _dealCard(BuildContext context, DealModel deal) {
    final offer = PreIPOOffer.fromDeal(deal);
    final selected = c.selectedOffer.value?.key == offer.key;
    final buyerWanted = deal.dealType == 'buy';
    final accent = buyerWanted ? Colors.blue : Colors.deepOrange;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: accent.withValues(alpha: selected ? 1 : 0.3),
            width: selected ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(buyerWanted ? Icons.sell_outlined : Icons.shopping_bag_outlined,
              color: accent),
          const SizedBox(width: 10),
          Expanded(
              child: Text(buyerWanted ? 'Buyer available' : 'Shares for sale',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600))),
          if (selected) Icon(Icons.check_circle, color: accent, size: 22),
        ]),
        const SizedBox(height: 16),
        SellerProfileWidget(
            seller: deal.seller, label: buyerWanted ? 'Buyer' : 'Seller'),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _stat('Price per share', deal.sharePrice.toCurrency)),
          const SizedBox(width: 12),
          Expanded(
              child: _stat('Minimum quantity', '${deal.minimumQty} shares')),
        ]),
        if (deal.availableQuantity.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('${deal.availableQuantity.toShowNum} shares available',
              style: const TextStyle(fontSize: 13)),
        ],
        const SizedBox(height: 18),
        if (buyerWanted)
          CustomOutlinedButton(
              color: accent,
              width: double.infinity,
              height: 44,
              text: 'Sell',
              onPressed: () {}),
        if (offer.canBuy && c.model().canBuy)
          IgnorePointer(
              ignoring: c.investing.value,
              child: CustomElevatedButton(
                  height: 44,
                  radius: 10,
                  text: selected && c.investorList.isNotEmpty
                      ? 'Add Investors'
                      : 'Buy Now',
                  onPressed: () =>
                      c.selectOffer(offer, phone: context.isPhone))),
      ]),
    );
  }

  Widget _stat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      );
}
