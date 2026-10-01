import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog_ctrl.dart';

class PhonePrimarySellShareDialogView extends StatelessWidget {
  final PrimarySellShareDialogCtrl c = Get.find<PrimarySellShareDialogCtrl>();

  PhonePrimarySellShareDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: context.width,
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
      child: Form(
        key: c.phoneKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sell Now",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Obx(() {
                    return SpinnerField<int>(
                      name: "Qty",
                      value: c.shares.value,
                      onChanged: (v) => c.shares(v),
                      autofocus: false,
                      fromString: (String stringValue) =>
                          int.tryParse(stringValue) ?? c.shares.value,
                      increment: (int i) => c.incrementSellQuantity(),
                      decrement: (int i) => c.decrementSellQuantity(),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    c.shares(c.model.availableShares.toInt());
                  },
                  child: Container(
                    height: 48,
                    width: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderColor(context)),
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
              ],
            ),
            const SizedBox(height: 18),
            TitleTextField(
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DataText(
                          title: "Available shares",
                          subTitle:
                              "${c.model.availableShares.formattedDecimal}"),
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
            const SizedBox(height: 20),
            Center(
              child: Obx(() {
                return CustomElevatedButton(
                  isLoading: c.isLoading.value,
                  onPressed: () {
                    if (c.phoneKey.currentState?.validate() ?? false) {
                      c.onPress();
                    }
                  },
                  width: 112,
                  height: 40,
                  text: "Sell now",
                );
              }),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 3),
        Text(
          subTitle,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }
}
