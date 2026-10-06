import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_transaction_detail_dialog.dart';

Future<void> showPreIpoOrderDetailDialog({
  required PreIpoOrderModel order,
  required Future<void> Function(String action) onAction,
  required Future<PreIpoOrderModel?> Function() loadDetail,
}) async {
  await showDialog<void>(
    context: Get.context!,
    builder: (_) => PreIpoTransactionDetailDialog(
      initial: order,
      onAction: onAction,
      loadDetail: loadDetail,
    ),
  );
}
