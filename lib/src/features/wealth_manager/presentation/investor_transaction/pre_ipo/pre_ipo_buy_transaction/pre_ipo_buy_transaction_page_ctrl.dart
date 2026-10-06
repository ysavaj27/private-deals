import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_order_widgets.dart';

class PreIPOBuyTransactionPageCtrl extends GetxController {
  final isLoading = false.obs;
  final list = <PreIpoOrderModel>[].obs;
  final isSearching = false.obs;
  final searchList = <PreIpoOrderModel>[].obs;
  final actionLoadingId = 0.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  List<PreIpoOrderModel> get finalList {
    if (isSearching.isFalse) return list;
    return searchList;
  }

  void search(String query) {
    if (query.isEmpty) {
      searchList.value = list;
      isSearching(false);
    } else {
      final q = query.toLowerCase();
      searchList.value = list.where((item) {
        return item.company.brandName.toLowerCase().contains(q) ||
            item.current.toLowerCase().contains(q) ||
            item.orderStep.toLowerCase().contains(q) ||
            item.investor.name.toLowerCase().contains(q);
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
    } else {
      toast(res.m);
    }
  }

  void _replaceOrder(PreIpoOrderModel order) {
    final index = list.indexWhere((e) => e.id == order.id);
    if (index >= 0) {
      list[index] = order;
      list.refresh();
    }
    final searchIndex = searchList.indexWhere((e) => e.id == order.id);
    if (searchIndex >= 0) {
      searchList[searchIndex] = order;
      searchList.refresh();
    }
  }

  Future<void> handleAction(PreIpoOrderModel order, String action) async {
    if (actionLoadingId.value != 0) return;
    switch (action) {
      case PreIpoOrderAction.cancel:
        final reason = await showPreIpoReasonDialog(
          title: 'Cancel transaction',
          hint: 'Why are you cancelling?',
          confirmLabel: 'Cancel order',
        );
        if (reason == null) return;
        await _runMutation(
          order.id,
          () => WPreIpoTransactionApi.cancel(
            transactionId: order.id,
            reason: reason,
          ),
        );
        break;
      case PreIpoOrderAction.showMandateSignLink:
      case PreIpoOrderAction.showDealSlipSignLink:
        final link = order.signLink;
        if (link == null || link.isEmpty) {
          toast('Sign link is not available', MessageEnum.alert);
          return;
        }
        await Launcher.openNewTab(link);
        await getData();
        break;
      case PreIpoOrderAction.viewPaymentDetails:
        var details = order.paymentDetails;
        if (details == null) {
          final detailRes = await WPreIpoTransactionApi.detail(
            transactionId: order.id,
          );
          if (!detailRes.isSuccess || detailRes.r == null) {
            toast(detailRes.m, MessageEnum.error);
            return;
          }
          _replaceOrder(detailRes.r!);
          details = detailRes.r!.paymentDetails;
        }
        if (details == null) {
          toast('Payment details are not available', MessageEnum.alert);
          return;
        }
        await showPreIpoPaymentDetailsDialog(details);
        break;
      case PreIpoOrderAction.uploadPaymentReceipt:
        final file = await showPreIpoReceiptUploadDialog(
          title: 'Upload payment receipt',
        );
        if (file == null) return;
        await _runMutation(
          order.id,
          () => WPreIpoTransactionApi.uploadPaymentReceipt(
            transactionId: order.id,
            file: file,
          ),
        );
        break;
      case PreIpoOrderAction.viewPaymentReceipt:
        await _openReceipt(order, shareTransfer: false);
        break;
      case PreIpoOrderAction.confirmPayment:
        await _runMutation(
          order.id,
          () => WPreIpoTransactionApi.confirmPayment(transactionId: order.id),
        );
        break;
      case PreIpoOrderAction.uploadShareTransferReceipt:
        final file = await showPreIpoReceiptUploadDialog(
          title: 'Upload share-transfer receipt',
        );
        if (file == null) return;
        await _runMutation(
          order.id,
          () => WPreIpoTransactionApi.uploadShareTransferReceipt(
            transactionId: order.id,
            file: file,
          ),
        );
        break;
      case PreIpoOrderAction.viewShareTransferReceipt:
        await _openReceipt(order, shareTransfer: true);
        break;
      case PreIpoOrderAction.confirmShareTransfer:
        await _runMutation(
          order.id,
          () => WPreIpoTransactionApi.confirmShareTransfer(
            transactionId: order.id,
          ),
        );
        break;
      default:
        toast('Unsupported action', MessageEnum.alert);
    }
  }

  Future<void> _openReceipt(
    PreIpoOrderModel order, {
    required bool shareTransfer,
  }) async {
    var current = order;
    if ((shareTransfer && current.shareTransferReceipt == null) ||
        (!shareTransfer && current.paymentReceipt == null)) {
      final detailRes = await WPreIpoTransactionApi.detail(
        transactionId: order.id,
      );
      if (!detailRes.isSuccess || detailRes.r == null) {
        toast(detailRes.m, MessageEnum.error);
        return;
      }
      current = detailRes.r!;
      _replaceOrder(current);
    }
    final url = shareTransfer
        ? current.shareTransferReceipt?.url
        : current.paymentReceipt?.url;
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

  Future<PreIpoOrderModel?> loadDetail(int transactionId) async {
    final res = await WPreIpoTransactionApi.detail(
      transactionId: transactionId,
    );
    if (res.isSuccess && res.r != null) {
      _replaceOrder(res.r!);
      return res.r;
    }
    toast(res.m, MessageEnum.error);
    return null;
  }
}
