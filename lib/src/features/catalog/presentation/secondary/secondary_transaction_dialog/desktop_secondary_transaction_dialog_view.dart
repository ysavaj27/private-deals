import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog_ctrl.dart';

class DesktopSecondaryTransactionDialogView extends StatelessWidget {
  final SecondaryTransactionDialogCtrl c =
      Get.find<SecondaryTransactionDialogCtrl>();

  DesktopSecondaryTransactionDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 600,
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Buy",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
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
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  c.shares(c.model.availableQuantity.toInt());
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
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _DataText(
                    title: "Min Shares",
                    subTitle: c.model.minimumQty.toShowNum),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: _DataText(
                    title: "Available Shares",
                    subTitle: c.model.availableQuantity.toShowNum),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.borderColor(context)),
          const SizedBox(height: 10),

          // --- Calculation summary ---
          Obx(() {
            // reading shares.value here ensures this whole block rebuilds
            // whenever quantity changes
            final _ = c.shares.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DataText(
                          title: "Shares price",
                          subTitle: c.model.sharePrice.toCurrency),
                    ),
                    Expanded(
                      child: _DataText(
                          title: "Shares", subTitle: c.shares.value.toShowNum),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DataText(
                        title: "Investment amount",
                        subTitle: c.investmentAmount.toCurrency,
                      ),
                    ),
                    Expanded(
                      child: _DataText(
                        title:
                            "Processing fees (${c.model.processingFeePercentage}%)",
                        subTitle: c.processingFees.toCurrency,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: AppColors.borderColor(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _DataText(
                      title: "Payable amount",
                      subTitle: c.payableAmount.toCurrency,
                      emphasize: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }),

          const SizedBox(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
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
                  onPressed: c.onPress,
                  isLoading: c.isLoading.value,
                  width: 169,
                  height: 49,
                  text: "Buy",
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataText extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool emphasize;

  const _DataText({
    required this.title,
    required this.subTitle,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: TextStyle(fontSize: emphasize ? 18 : 16),
      TextSpan(
        children: [
          TextSpan(
            text: '$title:  ',
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          TextSpan(
            text: subTitle,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: emphasize ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
