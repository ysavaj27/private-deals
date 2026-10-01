import 'package:private_deals/src/shared/app_exports.dart';

class SecondaryTransactionDialogCtrl extends GetxController {
  final DealModel model;

  // final InvestorModel investor;

  // final TextEditingController qtyCTRL = TextEditingController();
  RxInt shares = 0.obs;

  SecondaryTransactionDialogCtrl(this.model);

  RxBool isLoading = false.obs;

  // Function to increment the sell quantity
  int incrementSellQuantity() {
    // Increment by minQty, but don't exceed totalShares
    int newQty = shares.value + model.minimumQty.toInt();

    // Ensure the increment doesn't exceed totalShares
    return newQty > model.availableQuantity
        ? model.availableQuantity.toInt()
        : newQty;
  }

  double get investmentAmount => shares.value * model.sharePrice;

  double get processingFees =>
      investmentAmount * (model.processingFeePercentage / 100);

  double get payableAmount => investmentAmount + processingFees;

// Function to decrement the sell quantity
  int decrementSellQuantity() {
    // If the current sell quantity is less than or equal to the minQty, return minQty
    if (shares.value <= model.minimumQty) {
      return model.minimumQty.toInt();
    }

    // If the current sell quantity equals total available shares, decrement
    if (shares.value == model.availableQuantity) {
      // Find the nearest lower valid share quantity
      int nearestLowQty =
          (shares.value ~/ model.minimumQty) * model.minimumQty.toInt();

      if ((shares.value - nearestLowQty) < model.minimumQty) {
        nearestLowQty -= model.minimumQty.toInt();
      }

      // If the current quantity is already a perfect multiple of minQty, decrement by one step
      if (nearestLowQty == shares.value) {
        nearestLowQty -= model.minimumQty.toInt();
      }

      // Return the nearest lower valid quantity, but ensure the remaining shares are not less than minQty
      return nearestLowQty >= model.minimumQty
          ? nearestLowQty
          : model.minimumQty.toInt();
    }

    // For normal decrement, reduce by minQty but don't go below minQty
    int newQty = shares.value - model.minimumQty.toInt();

    // Ensure remaining shares are not less than minQty
    return newQty < model.minimumQty ? model.minimumQty.toInt() : newQty;
  }

  Future<void> onPress() async {
    isLoading(true);
    logger.d(model.toJson());
    var res = await WPreIpoTransactionApi.inquiry(
      type: InvestmentTypeEnum.buy,
      companySlug: model.companySlug,
      dealUUID: model.uuid,
      quantity: shares.value,
      offerPrice: model.sharePrice,
      offerValidTill: DateTime.now().add(const Duration(days: 30)),
    );
    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onInit() {
    shares(incrementSellQuantity());
    super.onInit();
  }
}
