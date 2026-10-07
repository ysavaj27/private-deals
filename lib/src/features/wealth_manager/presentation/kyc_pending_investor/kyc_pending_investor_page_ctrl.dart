import 'package:private_deals/src/shared/app_exports.dart';

class KycPendingInvestorPageCtrl extends GetxController {
  final isLoading = false.obs;
  final countsLoading = false.obs;
  final error = ''.obs;
  final countsError = ''.obs;
  final investorList = <InvestorModel>[].obs;
  final pendingTask = PendingTaskModel.fromJson({}).obs;
  final type = PendingTaskEnum.kyc.obs;
  final transactions = <PrimaryTransactionModel>[].obs;
  int _request = 0;

  Future<void> selectType(PendingTaskEnum selected) async {
    if (type() == selected) return;
    type(selected);
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final request = ++_request;
    final selected = type();
    isLoading(true);
    error('');
    try {
      if (selected == PendingTaskEnum.kyc || selected == PendingTaskEnum.aif) {
        final isKyc = selected == PendingTaskEnum.kyc;
        final res = await WInvestorsApi.investorsList(
          isKyc: isKyc ? FilterTypeEnum.No.name : FilterTypeEnum.All.name,
          isActive: FilterTypeEnum.All.name,
          isAif: isKyc ? FilterTypeEnum.All.name : FilterTypeEnum.No.name,
        );
        if (request != _request || isClosed) return;
        if (res.isSuccess) {
          investorList.assignAll(res.r ?? []);
        } else {
          error('Unable to load pending investors. Please try again.');
        }
      } else {
        final res = await WPrimaryTransactionApi.transactionList(
          pendingDocSign: selected == PendingTaskEnum.document,
          pendingPayment: selected == PendingTaskEnum.fundTransfer,
        );
        if (request != _request || isClosed) return;
        if (res.isSuccess) {
          transactions.assignAll(res.r ?? []);
        } else {
          error('Unable to load pending transactions. Please try again.');
        }
      }
    } catch (_) {
      if (request == _request && !isClosed) {
        error('Unable to load pending tasks. Please try again.');
      }
    } finally {
      if (request == _request && !isClosed) isLoading(false);
    }
  }

  Future<void> getData() async {
    if (countsLoading()) return;
    countsLoading(true);
    countsError('');
    try {
      final res = await PendingTaskApi.pendingTasks();
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        pendingTask(res.r);
      } else {
        countsError('Unable to load task totals.');
      }
    } catch (_) {
      if (!isClosed) countsError('Unable to load task totals.');
    } finally {
      if (!isClosed) countsLoading(false);
    }
  }

  Future<void> refreshData() => Future.wait([getData(), _loadTasks()]);

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }
}
