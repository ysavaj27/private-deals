import 'package:private_deals/src/shared/app_exports.dart';

class PreIPOBuyTransactionPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PreIPOTransactionModel> list =
      <PreIPOTransactionModel>[].obs;
  RxBool isSearching = false.obs;
  RxList<PreIPOTransactionModel> searchList =
      <PreIPOTransactionModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  List<PreIPOTransactionModel> get finalList {
    if (isSearching.isFalse) {
      return list;
    } else {
      return searchList;
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      searchList.value = list;
      isSearching(false);
    } else {
      searchList.value = list.where((item) {
        return item.company.brandName
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item.currentStatus.toLowerCase().contains(query.toLowerCase()) ||
            item.investor.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      isSearching(true);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await WPreIpoTransactionApi.transactionList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      // logger.d("secondary TransactionList Length :${list.length}");
    } else {
      toast(res.m);
    }
  }

  Future<void> approveRequest(int transactionId, int shareReceiptId) async {
    var res = await InvestorSecondaryTransactionApi.shareReceiptApprove(
      transactionId: transactionId,
      shareReceiptId: transactionId,
    );
    if (res.isSuccess) {
      await getData();
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> updateStatus({required int id, required int status}) async {
    var res = await InvestorSecondaryTransactionApi.opportunitiesStatus(
        itemId: id, status: status);
    if (res.isSuccess) {
      getData();
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
