import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/pre_ipo_sell_share_dialog_ctrl.dart';

class DesktopPreIPOSellShareDialogView extends StatelessWidget {
  final PreIPOSellShareDialogCtrl c = Get.find<PreIPOSellShareDialogCtrl>();

  DesktopPreIPOSellShareDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(40),
      child: Form(
        key: c.desktopKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sell Now",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 650,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TitleTextField(
                      name: "Share Qty",
                      controller: c.sellQuantityCTRL,
                      maxLength: c.model.shares.toInt().toString().length,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                      ],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (p0) {
                        if (p0 == null || p0.isEmpty) {
                          return 'Enter quantity';
                        }
                        var qty = int.tryParse(p0);
                        if (qty == null || qty == 0) {
                          return 'Enter valid quantity';
                        }
                        if (qty > c.model.availableShares) {
                          return "Can't enter more than ${c.model.availableShares.toInt()} shares";
                        }

                        double investedAmount = c.model.availableSharesPrices;
                        // double sellAmount = qty * c.model.currentSharePrice;
                        double minAmount = app.config.preIpoMinSellAmount;
                        double minShares =
                        (minAmount / c.model.currentSharePrice)
                            .ceilToDouble();
                        double maxSellShares = ((investedAmount - minAmount) /
                            c.model.currentSharePrice)
                            .floorToDouble();

                        if (investedAmount < minAmount) {
                          if (qty == c.model.availableShares) {
                            return null;
                          }
                          return "Invested shares are less than ${minShares.toInt()} shares. So you must sell all shares.";
                        }

                        if (qty == c.model.availableShares) {
                          return null; // Selling all shares is always allowed.
                        }

                        if (qty < minShares) {
                          return "Minimum sell quantity is ${minShares.toInt()} shares";
                        }

                        if (qty > maxSellShares && qty != c.model.availableShares) {
                          return "You can sell all shares or a quantity between ${minShares.toInt()} and ${maxSellShares.toInt()} shares";
                        }

                        return null;
                      },
                       onChanged: (v) => c.shares(int.tryParse(v)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        c.shares(c.model.availableShares.toInt());
                        c.sellQuantityCTRL.text = c.shares.toString();
                      },
                      child: Container(
                        height: 48,
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: AppColors.borderColor(context)),
                          color: context.isDarkMode
                              ? const Color(0xff242424)
                              : Colors.grey.shade400,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Max Qty",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 650,
              child: TitleTextField(
                name: "Amount",
                hintText: 'Enter sell amount',
                controller: c.sellPriceCTRL,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                ],
                // controller: c.amountCTRL,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return "Please enter amount";
                  }
                  if (double.tryParse(p0) == null) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 650,
              child: TitleTextField(
                name: 'Select CMR/CML',
                controller: c.receiptCTRL,
                hintText: 'No file Chosen',
                readOnly: true,
                onTap: () async {
                  var res = await FilePickers().pickSingleImage();
                  if (res != null) {
                    c.receiptCTRL.text = res.name;
                    c.receipt(res);
                  }
                },
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return "Upload CMR/CML";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DataText(
                          title: "Available shares",
                          subTitle: "${c.model.availableShares}"),
                      const SizedBox(height: 18),
                      _DataText(
                        title: "Current share price",
                        subTitle: c.model.currentSharePrice.toCurrency,
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DataText(
                        title: "Purchase price",
                        subTitle: c.model.purchasePrice.toCurrency,
                      ),
                      const SizedBox(height: 18),
                      _DataText(
                          title: "Last traded price",
                          subTitle: c.model.lastTradedPrice.toCurrency),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomOutlinedButton(
                  onPressed: Get.back,
                  width: 169,
                  height: 49,
                  text: "Close",
                ),
                const SizedBox(width: 50),
                Obx(() {
                  return CustomElevatedButton(
                    isLoading: c.isLoading.value,
                    onPressed: () {
                      if (c.desktopKey.currentState?.validate() ?? false) {
                        c.onPress();
                      }
                    },
                    width: 169,
                    height: 49,
                    text: "Sell now",
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DataText extends StatelessWidget {
  final String title;
  final String subTitle;

  const _DataText({required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: const TextStyle(fontSize: 16),
      TextSpan(
        children: [
          TextSpan(
            text: '$title:  ',
          ),
          TextSpan(
            text: subTitle,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
