import 'package:private_deals/src/shared/app_exports.dart';

class SecondaryTransactionPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<SecondaryTransactionListModel> list =
      <SecondaryTransactionListModel>[].obs;
  RxBool isSearching = false.obs;
  RxList<SecondaryTransactionListModel> searchList =
      <SecondaryTransactionListModel>[].obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  List<SecondaryTransactionListModel> get finalList {
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
        // logger.d("Search :$query Amount :${item.amount}");
        return item.buy.startup.brandName.toString().contains(query) ||
            // item.sell.transactions.where((e) => e.buyer.name.toLowerCase().contains(query)).toList() ||
            item.sell.startup.brandName
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
      isSearching(true);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await WSecondaryTransactionApi.secondaryTransactionList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
      logger.d("secondary TransactionList Length :${list.length}");
    } else {
      toast(res.m);
    }
  }

  Future<void> approveRequest(int transactionId, int shareReceiptId) async {
    var res = await WSecondaryTransactionApi.shareReceiptApprove(
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
    var res = await WSecondaryTransactionApi.opportunitiesStatus(
        itemId: id, status: status);
    if (res.isSuccess) {
      getData();
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
