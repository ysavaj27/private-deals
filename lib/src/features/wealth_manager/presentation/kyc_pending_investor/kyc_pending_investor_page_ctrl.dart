import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_order_detail_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class KycPendingInvestorPageCtrl extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final pendingTask = PendingTaskModel().obs;
  final type = PendingTaskEnum.kyc.obs;
  int _request = 0;

  List<InvestorModel> get investors => pendingTask().pendingKyc.investors;

  List<PendingDocumentItem> get documents =>
      pendingTask().pendingDocuments.documents;

  List<PendingFundTransferItem> get fundTransfers =>
      pendingTask().pendingFundTransfer.transactions;

  Future<void> selectType(PendingTaskEnum selected) async {
    if (type() == selected) return;
    type(selected);
  }

  Future<void> getData() async {
    final request = ++_request;
    isLoading(true);
    error('');
    try {
      final res = await PendingTaskApi.pendingTasks();
      if (request != _request || isClosed) return;
      if (res.isSuccess && res.r != null) {
        pendingTask(res.r);
      } else {
        error('Unable to load pending tasks. Please try again.');
      }
    } catch (_) {
      if (request == _request && !isClosed) {
        error('Unable to load pending tasks. Please try again.');
      }
    } finally {
      if (request == _request && !isClosed) isLoading(false);
    }
  }

  Future<void> refreshData() => getData();

  Future<void> openDocumentDetail(PendingDocumentItem document) {
    final id = document.transactionId;
    if (id <= 0) {
      toast('Transaction details are not available', MessageEnum.alert);
      return Future.value();
    }
    return openTransactionDetail(
      transactionId: id,
      seed: _documentSeed(document),
    );
  }

  /// Same source as the dialog "Sign mandate" action: order `sign_link`.
  Future<void> openDocumentSignLink(PendingDocumentItem document) async {
    final id = document.transactionId;
    if (id <= 0) {
      toast('Sign link is not available', MessageEnum.alert);
      return;
    }
    final actions = _PendingPreIpoOrderActions();
    final detail = await actions.loadDetail(id);
    final link = detail?.signLink?.trim() ?? '';
    if (link.isEmpty) {
      toast('Sign link is not available', MessageEnum.alert);
      return;
    }
    await Launcher.openNewTab(link);
    if (!isClosed) await refreshData();
  }

  PreIpoOrderModel _documentSeed(PendingDocumentItem document) =>
      PreIpoOrderModel(
        id: document.transactionId,
        transactionInvoiceNo: document.transactionInvoiceNo,
        orderStep: '',
        investor: PreIpoOrderInvestor(
          id: document.investor.id,
          name: document.investor.name,
        ),
        company: PreIpoOrderCompany(
          id: document.company.id,
          brandName: document.company.brandName,
          logo: document.company.logoUrl,
        ),
      );

  Future<void> openFundTransferDetail(PendingFundTransferItem transfer) {
    final id = transfer.id;
    if (id <= 0) {
      toast('Transaction details are not available', MessageEnum.alert);
      return Future.value();
    }
    return openTransactionDetail(
      transactionId: id,
      seed: PreIpoOrderModel(
        id: id,
        transactionInvoiceNo: transfer.transactionInvoiceNo,
        orderStep: transfer.orderStep,
        shares: transfer.shares.round(),
        sharePrice: transfer.sharePrice,
        payableAmount: transfer.payableAmount,
        investmentAmount: transfer.investmentAmount,
        instrument: transfer.instrument,
        settlementDate: transfer.settlementDate,
        investor: PreIpoOrderInvestor(
          id: transfer.investor.id,
          name: transfer.investor.name,
        ),
        company: PreIpoOrderCompany(
          id: transfer.company.id,
          brandName: transfer.company.brandName,
          logo: transfer.company.logoUrl,
        ),
      ),
    );
  }

  Future<void> openTransactionDetail({
    required int transactionId,
    required PreIpoOrderModel seed,
  }) async {
    var current = seed;
    final actions = _PendingPreIpoOrderActions();
    await showPreIpoOrderDetailDialog(
      order: seed,
      loadDetail: () async {
        final detail = await actions.loadDetail(transactionId);
        if (detail != null) current = detail;
        return detail;
      },
      onAction: (action) => actions.handleAction(current, action),
    );
    if (!isClosed) await refreshData();
  }

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }
}

/// Reuses unlisted transaction actions without fetching the full order list.
class _PendingPreIpoOrderActions extends PreIPOBuyTransactionPageCtrl {
  @override
  Future<void> getData() async {
    // Skip list load — this helper only powers the detail dialog.
  }
}
