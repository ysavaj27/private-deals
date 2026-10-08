import 'package:private_deals/src/shared/app_exports.dart';

class PrimarySellShareDialogCtrl extends GetxController {
  final TextEditingController sellQuantityCTRL = TextEditingController();
  final TextEditingController sellPriceCTRL = TextEditingController();
  final GlobalKey<FormState> desktopKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  final PortfolioModel model;
  RxInt shares = 0.obs;

  PrimarySellShareDialogCtrl(this.model);

  Future<void> onPress() async {
    if (isLoading.value) return;
    isLoading(true);
    final kycError = await WInvestorsApi.transactionKycError([
      model.investor.id,
    ]);
    if (isClosed) return;
    if (kycError != null) {
      isLoading(false);
      toast(kycError, MessageEnum.alert);
      return;
    }
    var res = await InvestorSecondaryTransactionApi.primarySellRequest(
      portfolioId: model.id,
      price: sellPriceCTRL.text,
      shares: shares.value,
    );
    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.success);
    }
  }

  // Function to increment the sell quantity
  int incrementSellQuantity() {
    // Calculate remaining shares
    int remainingShares = model.availableShares.toInt() - shares.value;

    // Check if remaining shares are less than minQty
    if (remainingShares < (model.minimumShares * 2)) {
      // If remaining shares are less than minQty, return all available shares
      return model.availableShares.toInt();
    }

    // Increment by minQty, but don't exceed totalShares
    int newQty = shares.value.toInt() + model.minimumShares.toInt();

    // Ensure the increment doesn't exceed totalShares
    return newQty > model.availableShares
        ? model.availableShares.toInt()
        : newQty;
  }

  // Function to decrement the sell quantity
  int decrementSellQuantity() {
    // If the current sell quantity is less than or equal to the minQty, return minQty
    if (shares.value <= model.minimumShares) {
      return model.minimumShares.toInt();
    }

    // If the current sell quantity equals total available shares, decrement
    if (shares.value == model.availableShares) {
      // Find the nearest lower valid share quantity
      int nearestLowQty =
          (shares.value ~/ model.minimumShares) * model.minimumShares.toInt();

      if ((shares.value - nearestLowQty) < model.minimumShares) {
        nearestLowQty -= model.minimumShares.toInt();
      }

      // If the current quantity is already a perfect multiple of minQty, decrement by one step
      if (nearestLowQty == shares.value) {
        nearestLowQty -= model.minimumShares.toInt();
      }

      // Return the nearest lower valid quantity, but ensure the remaining shares are not less than minQty
      return nearestLowQty >= model.minimumShares
          ? nearestLowQty.toInt()
          : model.minimumShares.toInt();
    }

    // For normal decrement, reduce by minQty but don't go below minQty
    int newQty = shares.value - model.minimumShares.toInt();

    // Ensure remaining shares are not less than minQty
    return newQty < model.minimumShares ? model.minimumShares.toInt() : newQty;
  }

  @override
  void onInit() {
    shares(incrementSellQuantity());
    super.onInit();
  }

  @override
  void onClose() {
    sellQuantityCTRL.dispose();
    sellPriceCTRL.dispose();
    super.onClose();
  }
}
