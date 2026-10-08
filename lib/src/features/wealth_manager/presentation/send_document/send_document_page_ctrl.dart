import 'package:private_deals/src/shared/app_exports.dart';

class SendDocumentPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSearching = false.obs;
  RxList<PrimaryTransactionModel> list = <PrimaryTransactionModel>[].obs;
  RxList<PrimaryTransactionModel> searchList = <PrimaryTransactionModel>[].obs;
  TextEditingController controller = TextEditingController();

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    isLoading(true);
    var res = await WPrimaryTransactionApi.transactionList();
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      list.value = res.r!;
    } else {
      toast(res.m);
    }
  }

  Future<void> sendDocument(int transactionId, String docType) async {
    var res = await DocumentApi.sendDocument(transactionId, docType);
    toast(res.m);
  }

  List<PrimaryTransactionModel> get finalList {
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
        return item.startup.brandName.toLowerCase().toString().contains(
              query.toLowerCase(),
            ) ||
            item.investor.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      isSearching(true);
    }
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
