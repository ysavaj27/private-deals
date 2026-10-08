import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/seller_profile_widget.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';

class PhonePreIPOInvestmentView extends StatelessWidget {
  final PreIPOInvestmentPageCtrl c = Get.find<PreIPOInvestmentPageCtrl>();

  PhonePreIPOInvestmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unlisted Shares Investment"),
        actions: [
          IconButton(
            onPressed: c.addInvestor,
            icon: Icon(
              Icons.add_circle_outline,
              color: context.theme.iconTheme.color,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LogoImage(
                      radius: 5,
                      url: c.model().logo,
                      height: 80,
                      width: 80,
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.model().brandName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "Distributor price",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                c.purchasePrice.fixDigit,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${c.sharePrice.toCurrency} ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: c.model().profitLossString,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.model().resultColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final offer = c.selectedOffer.value;
                  if (offer == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    child: SellerProfileWidget(
                      seller: offer.seller,
                      label: 'Selected seller',
                      showDetails: true,
                    ),
                  );
                }),
                // SizedBox(height: 5),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Text.rich(
                //     TextSpan(
                //       children: [
                //         TextSpan(
                //           text: "Distributor price ",
                //           style: TextStyle(
                //             fontSize: 14,
                //             fontWeight: FontWeight.w600,
                //             color: context.theme.colorScheme.onSurfaceVariant,
                //           ),
                //         ),
                //         TextSpan(
                //           text: '${c.purchasePrice.toCurrency} ',
                //           style: const TextStyle(
                //             fontSize: 14,
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Expanded(
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: c.phoneKey,
                    child: Obx(() {
                      if (c.investorList.isNotEmpty) {
                        return ListView.separated(
                          padding: const EdgeInsets.only(top: 27, bottom: 50),
                          itemCount: c.investorList.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            return CardView(model: c.investorList[index]);
                          },
                        );
                      } else {
                        return Center(
                          child: CustomElevatedButton(
                            width: 200,
                            height: 45,
                            backgroundColor: AppColors.preIpoButton(context),
                            onPressed: c.addInvestor,
                            child: const Text("Add Investor"),
                          ),
                        );
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        return Visibility(
          visible: c.investorList.isNotEmpty,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomElevatedButton(
              isLoading: c.investing.value,
              backgroundColor: AppColors.preIpoButton(context),
              // borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              onPressed: () {
                if (c.phoneKey.currentState?.validate() ?? false) {
                  c.onPress();
                }
              },
              text: 'Invest',
            ),
          ),
        );
      }),
    );
  }
}

class CardView extends StatelessWidget {
  final SelectInvestorModel model;

  CardView({super.key, required this.model});

  final PreIPOInvestmentPageCtrl c = Get.find<PreIPOInvestmentPageCtrl>();

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
    // model.totalPrice.refresh();
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
                Text(
                  model.investorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () => c.removeInvestor(model),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderColor(context)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
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
                    alpha: 0.06,
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
                Obx(() {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: model.isSelf
                            ? null
                            : () {
                                model.isMarket.toggle();
                                if (model.isMarket.isTrue) {
                                  model.priceCTRL?.text = c.sharePrice
                                      .toStringAsFixed(0);
                                }
                              },
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: context.isPhone ? 14 : 16,
                                ),
                                children: [
                                  const TextSpan(text: "Price  "),
                                  TextSpan(
                                    text: model.isMarket.isTrue
                                        ? "Market"
                                        : "Limit",
                                    style: TextStyle(
                                      color: context.iconColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!model.isSelf) ...[
                              const SizedBox(width: 1),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ],
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
                        readOnly: model.isMarket.isTrue || model.isSelf,
                        // enabled: model.isMarket.isFalse,
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
                  );
                }),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Total Amount :"),
                    const SizedBox(width: 10),
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
