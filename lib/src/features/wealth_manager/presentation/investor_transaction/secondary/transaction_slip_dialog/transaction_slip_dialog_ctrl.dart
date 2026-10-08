import 'package:private_deals/src/shared/app_exports.dart';

class TransactionSlipDialogCtrl extends GetxController {
  Rx<MediaModel> receipt = MediaModel().obs;
  final SecondaryTransactionModel model;
  TextEditingController receiptCTRL = TextEditingController();
  RxBool isUploading = false.obs;

  TransactionSlipDialogCtrl(this.model);

  Future<void> uploadSlip() async {
    isUploading(true);
    var res = await WSecondaryTransactionApi.receiptUpload(
      transactionId: model.id,
      receipt: receipt(),
      status: model.status,
    );
    isUploading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m);
    }
  }

  @override
  void onClose() {
    receiptCTRL.dispose();
    super.onClose();
  }
}
