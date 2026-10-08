import 'package:private_deals/src/shared/app_exports.dart';

class PrimaryTransactionPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  RxList<PrimaryTransactionModel> list = <PrimaryTransactionModel>[].obs;
  RxBool isSearching = false.obs;
  RxList<PrimaryTransactionModel> searchList = <PrimaryTransactionModel>[].obs;
  Rx<MediaModel> receipt = MediaModel().obs;
  TextEditingController receiptCTRL = TextEditingController();

  Future<void> getData() async {
    isLoading(true);
    var res = await WPrimaryTransactionApi.transactionList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      // logger.d("transactionList Length :${list.length}");
    } else {
      toast(res.m);
    }
  }

  Future<void> uploadSlip(int transactionId) async {
    isUploading(true);
    var res = await InvestorPrimaryTransactionApi.paymentReceipt(
      transactionId: transactionId,
      receipt: receipt(),
    );
    isUploading(false);
    if (res.isSuccess) {
      Get.back();
      toast(res.m, MessageEnum.success);
      getData();
    } else {
      toast(res.m);
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      searchList.value = list;
      isSearching(false);
    } else {
      searchList.value = list.where((item) {
        // logger.d("Search :$query Amount :${item.amount}");
        return item.investor.name.toString().contains(query) ||
            item.investor.partnerDetails.partnerName.toLowerCase().contains(
              query,
            ) ||
            item.startup.brandName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      isSearching(true);
    }
  }

  void clearData() {
    receipt(MediaModel());
    receiptCTRL.clear();
  }

  List<PrimaryTransactionModel> get finalList {
    if (isSearching.isFalse) {
      return list;
    } else {
      return searchList;
    }
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  @override
  void onClose() {
    receiptCTRL.dispose();
    super.onClose();
  }
}
