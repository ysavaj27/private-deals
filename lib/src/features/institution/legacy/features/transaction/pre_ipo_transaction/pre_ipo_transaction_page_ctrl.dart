import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/legacy/backend/api/pre_ipo_transaction_api.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/plugins/luncher.dart';
import 'package:private_deals/src/shared/plugins/toast.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_order_widgets.dart';

enum PreIPOTransactionFilter {
  pending('Pending'),
  processing('Processing'),
  completed('Completed'),
  cancelled('Cancelled');

  const PreIPOTransactionFilter(this.label);
  final String label;
}

class PreIPOTransactionPageCtrl extends GetxController {
  final transactions = <PreIpoOrderModel>[].obs;
  final filtered = <PreIpoOrderModel>[].obs;
  final loading = false.obs;
  final actionLoadingId = 0.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final filter = PreIPOTransactionFilter.pending.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  void selectFilter(PreIPOTransactionFilter value) {
    if (value == filter.value) return;
    filter.value = value;
    _applySearch();
  }

  void search(String value) {
    searchQuery.value = value.trim().toLowerCase();
    _applySearch();
  }

  void _applySearch() {
    final q = searchQuery.value;
    filtered.assignAll(
      transactions.where((item) {
        final inFilter = switch (filter.value) {
          PreIPOTransactionFilter.pending =>
            item.orderStep == 'share_confirmation_pending',
          PreIPOTransactionFilter.processing =>
            !item.isCompleted &&
                !item.isCancelled &&
                item.orderStep != 'share_confirmation_pending',
          PreIPOTransactionFilter.completed => item.isCompleted,
          PreIPOTransactionFilter.cancelled => item.isCancelled,
        };
        return inFilter &&
            (q.isEmpty ||
                item.company.brandName.toLowerCase().contains(q) ||
                item.investor.name.toLowerCase().contains(q) ||
                item.orderStep.toLowerCase().contains(q) ||
                item.current.toLowerCase().contains(q) ||
                item.tradeSide.contains(q));
      }),
    );
  }

  Future<void> fetch() async {
    loading.value = true;
    error.value = '';
    try {
      final res = await PreIPOTransactionApi.getTransactions();
      if (isClosed) return;
      if (!res.isSuccess) {
        error.value = res.m.isEmpty
            ? 'Unable to load transactions. Please retry.'
            : res.m;
        transactions.clear();
        filtered.clear();
        return;
      }
      transactions.assignAll(res.r ?? <PreIpoOrderModel>[]);
      _applySearch();
    } catch (_) {
      if (!isClosed) {
        error.value = 'Unable to load transactions. Please retry.';
      }
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void retry() {
    if (!loading.value) fetch();
  }

  void _replaceOrder(PreIpoOrderModel order) {
    final index = transactions.indexWhere((e) => e.id == order.id);
    if (index >= 0) {
      transactions[index] = order;
      transactions.refresh();
      _applySearch();
    }
  }

  Future<PreIpoOrderModel?> loadDetail(int transactionId) async {
    final res = await PreIPOTransactionApi.detail(transactionId: transactionId);
    if (res.isSuccess && res.r != null) {
      _replaceOrder(res.r!);
      return res.r;
    }
    toast(res.m, MessageEnum.error);
    return null;
  }

  Future<void> handleAction(PreIpoOrderModel order, String action) async {
    if (actionLoadingId.value != 0) return;
    switch (action) {
      case PreIpoOrderAction.approve:
        await _runMutation(
          order.id,
          () => PreIPOTransactionApi.approve(transactionId: order.id),
        );
        break;
      case PreIpoOrderAction.reject:
        final reason = await showPreIpoReasonDialog(
          title: 'Reject transaction',
          hint: 'Why are you rejecting?',
          confirmLabel: 'Reject',
        );
        if (reason == null) return;
        await _runMutation(
          order.id,
          () => PreIPOTransactionApi.reject(
            transactionId: order.id,
            reason: reason,
          ),
        );
        break;
      case PreIpoOrderAction.showDealSlipSignLink:
        final detail = await loadDetail(order.id);
        if (detail == null) return;
        if (!detail.hasActionNamed(action) ||
            detail.signLink == null ||
            detail.signLink!.isEmpty) {
          toast('Sign link is not available', MessageEnum.alert);
          return;
        }
        await Launcher.openNewTab(detail.signLink!);
        await fetch();
        break;
      case PreIpoOrderAction.viewPaymentDetails:
        final detail = await loadDetail(order.id);
        if (detail == null) return;
        if (detail.paymentDetails == null) {
          toast('Payment details are not available', MessageEnum.alert);
          return;
        }
        await showPreIpoPaymentDetailsDialog(detail.paymentDetails!);
        break;
      case PreIpoOrderAction.uploadPaymentReceipt:
        final file = await showPreIpoReceiptUploadDialog(
          title: 'Upload payment receipt',
        );
        if (file == null) return;
        await _runMutation(
          order.id,
          () => PreIPOTransactionApi.uploadPaymentReceipt(
            transactionId: order.id,
            file: file,
          ),
        );
        break;
      case PreIpoOrderAction.viewPaymentReceipt:
        await _openPaymentReceipt(order);
        break;
      case PreIpoOrderAction.confirmPayment:
        await _runMutation(
          order.id,
          () => PreIPOTransactionApi.confirmPayment(transactionId: order.id),
        );
        break;
      case PreIpoOrderAction.uploadShareTransferReceipt:
        final file = await showPreIpoReceiptUploadDialog(
          title: 'Upload share-transfer receipt',
        );
        if (file == null) return;
        await _runMutation(
          order.id,
          () => PreIPOTransactionApi.uploadShareTransferReceipt(
            transactionId: order.id,
            file: file,
          ),
        );
        break;
      default:
        toast('Unsupported action', MessageEnum.alert);
    }
  }

  Future<void> _openPaymentReceipt(PreIpoOrderModel order) async {
    var current = order;
    if (current.paymentReceipt == null) {
      final detail = await loadDetail(order.id);
      if (detail == null) return;
      current = detail;
    }
    final url = current.paymentReceipt?.url;
    if (url == null || url.isEmpty) {
      toast('Receipt is not available', MessageEnum.alert);
      return;
    }
    await Launcher.openNewTab(url);
  }

  Future<void> _runMutation(
    int id,
    Future<BaseModel<PreIpoOrderModel>> Function() request,
  ) async {
    actionLoadingId(id);
    final res = await request();
    actionLoadingId(0);
    if (res.isSuccess && res.r != null) {
      toast(res.m, MessageEnum.success);
      _replaceOrder(res.r!);
    } else {
      toast(res.m, MessageEnum.error);
      await loadDetail(id);
    }
  }
}
