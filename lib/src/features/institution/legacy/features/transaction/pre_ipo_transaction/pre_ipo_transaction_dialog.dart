import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';
import 'package:private_deals/src/shared/widgets/pre_ipo_order/pre_ipo_transaction_detail_dialog.dart';

class PreIPOTransactionDialog extends StatelessWidget {
  const PreIPOTransactionDialog({
    super.key,
    required this.transactionId,
    required this.initial,
    required this.onAction,
    required this.loadDetail,
  });

  final int transactionId;
  final PreIpoOrderModel initial;
  final Future<void> Function(String action) onAction;
  final Future<PreIpoOrderModel?> Function() loadDetail;

  @override
  Widget build(BuildContext context) => PreIpoTransactionDetailDialog(
    initial: initial,
    onAction: onAction,
    loadDetail: loadDetail,
  );
}
