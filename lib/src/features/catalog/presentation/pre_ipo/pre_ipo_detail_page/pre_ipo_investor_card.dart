import 'package:private_deals/src/shared/app_exports.dart';
import 'pre_ipo_detail_page_ctrl.dart';

class PreIPOInvestorCard extends StatelessWidget {
  final SelectInvestorModel model;

  PreIPOInvestorCard({super.key, required this.model});

  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  void onQtyChange(String? p0) {
    final shares = int.tryParse(p0 ?? "");
    if (shares == null) return;
    model.quantity(shares);
    model.totalPrice((model.quantity * model.price()).toDouble());
  }

  void onAmountChange(String? p0) {
    if (p0 == null || double.tryParse(p0) == null) return;
    var price = double.parse(p0);
    model.price(price);
    model.totalPrice((model.quantity * model.price()).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 12,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    model.investorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove investor',
                  onPressed: () => c.investorList.remove(model),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: context.theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor(context)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TitleTextField(
                  borderColor: context.theme.disabledColor.withValues(
                    alpha: 0.2,
                  ),
                  fillColor: context.theme.disabledColor.withValues(
                    alpha: 0.08,
                  ),
                  name: "Quantity",
                  textInputAction: TextInputAction.next,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  isDense: true,
                  controller: model.quantityCTRL,
                  keyboardType: TextInputType.number,
                  onChanged: onQtyChange,
                  validator: (p0) {
                    if (c.selectedOffer.value != null) {
                      return c.selectedOffer.value!.validateQuantity(p0);
                    }
                    if (p0 == null || p0.isEmpty) {
                      return "Enter quantity";
                    } else if (int.tryParse(p0) == null || int.parse(p0) <= 0) {
                      return 'Enter a whole number of shares';
                    } else if (c.isQty.isTrue &&
                        double.parse(p0) < c.minTicketSize) {
                      return 'Min quantity is ${c.minTicketSize} shares';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price per share',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 9),
                    CustomTextField(
                      autofocus: !model.isSelf,
                      isFilled: true,
                      borderColor: context.theme.disabledColor.withValues(
                        alpha: 0.2,
                      ),
                      fillColor: context.theme.disabledColor.withValues(
                        alpha: 0.06,
                      ),
                      readOnly: model.isSelf,
                      controller: model.priceCTRL,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      isDense: true,
                      onChanged: onAmountChange,
                      validator: (p0) {
                        if (c.selectedOffer.value != null) {
                          return c.selectedOffer.value!.validatePrice(p0);
                        }
                        if (p0 == null || p0.isEmpty) {
                          return "Please enter amount";
                        } else if (double.tryParse(p0) == null) {
                          return 'Enter valid amount';
                        } else if (double.parse(p0) < c.purchasePrice) {
                          return 'Min price ${c.purchasePrice}';
                        } else if (c.isQty.isFalse &&
                            model.totalPrice() < c.minTicketSize) {
                          return 'Min ticket size is ${c.minTicketSize.toCurrency}';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    const Text("Total Amount :"),
                    Obx(() {
                      return Text(
                        model.totalPrice().toCurrency,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
