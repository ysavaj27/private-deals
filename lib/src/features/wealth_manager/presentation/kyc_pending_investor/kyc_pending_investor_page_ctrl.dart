import 'package:private_deals/src/shared/app_exports.dart';

class KycPendingInvestorPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxList<InvestorModel> investorList = <InvestorModel>[].obs;
  Rx<PendingTaskModel> pendingTask = PendingTaskModel.fromJson({}).obs;
  Rx<PendingTaskEnum> type = PendingTaskEnum.kyc.obs;
  RxList<PrimaryTransactionModel> transactions =
      <PrimaryTransactionModel>[].obs;

  Future<void> getPendingKycInvestor(
      {PendingTaskEnum type = PendingTaskEnum.kyc}) async {
    isLoading(true);
    bool isKyc = PendingTaskEnum.kyc == type;
    var res = await WInvestorsApi.investorsList(
      isKyc: isKyc ? FilterTypeEnum.No.name : FilterTypeEnum.All.name,
      isActive: FilterTypeEnum.All.name,
      isAif: isKyc ? FilterTypeEnum.All.name : FilterTypeEnum.No.name,
    );
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investorList(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getTransactions(
      {bool pendingDocSign = false, bool pendingPayment = false}) async {
    transactions.clear();
    isLoading(true);
    var res = await WPrimaryTransactionApi.transactionList(
        pendingDocSign: pendingDocSign, pendingPayment: pendingPayment);
    isLoading(false);
    if (res.isSuccess) {
      transactions(res.r);
    }
  }

  Future<void> getData() async {
    var res = await PendingTaskApi.pendingTasks();
    if (res.isSuccess) {
      pendingTask(res.r);
    }
  }

  @override
  void onInit() {
    getData();
    getPendingKycInvestor();
    super.onInit();
  }
}
