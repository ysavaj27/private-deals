import 'package:private_deals/src/shared/app_exports.dart';

class PreIPOSellShareDialogCtrl extends GetxController {
  final TextEditingController sellQuantityCTRL = TextEditingController();
  final TextEditingController sellPriceCTRL = TextEditingController();
  final GlobalKey<FormState> desktopKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  final PreIPOPortfolioModel model;
  RxInt shares = 0.obs;
  TextEditingController receiptCTRL = TextEditingController();
  Rx<MediaModel> receipt = MediaModel().obs;

  PreIPOSellShareDialogCtrl(this.model);

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
    var res = await WPreIpoTransactionApi.preIPOSellRequest(
      portfolioId: model.id,
      price: sellPriceCTRL.text,
      shares: shares.value,
      doc: receipt.value,
    );
    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.success);
    }
  }

  void clearData() {
    receipt(MediaModel());
    receiptCTRL.clear();
  }

  @override
  void onClose() {
    sellQuantityCTRL.dispose();
    sellPriceCTRL.dispose();
    receiptCTRL.dispose();
    super.onClose();
  }
}
