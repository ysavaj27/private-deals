import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog_ctrl.dart';

class PhoneSecondaryTransactionDialogView extends StatelessWidget {
  final SecondaryTransactionDialogCtrl c =
      Get.find<SecondaryTransactionDialogCtrl>();

  PhoneSecondaryTransactionDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Secondary transaction",
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
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DataText(
                        title: "Min Shares",
                        subTitle: c.model.minimumQty.formattedDecimal),
                    const SizedBox(height: 18),
                    _DataText(
                        title: "Currant shares price",
                        subTitle: c.model.sharePrice.toCurrency),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                // child: SizedBox(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DataText(
                        title: "Available Shares",
                        subTitle: c.model.availableQuantity.toCurrency),
                    const SizedBox(height: 18),
                    // _DataText(
                    //     title: "Last traded price",
                    //     subTitle: c.model.lastTradedPrice.toCurrency),
                    // const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomOutlinedButton(
                onPressed: Get.back,
                width: 112,
                height: 40,
                text: "Close",
              ),
              const SizedBox(width: 20),
              Obx(() {
                return CustomElevatedButton(
                  onPressed: c.onPress,
                  isLoading: c.isLoading.value,
                  width: 112,
                  height: 40,
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
