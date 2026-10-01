import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/desktop_transaction_slip_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/phone_transaction_slip_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/transaction_slip_dialog_ctrl.dart';

class TransactionSlipDialog extends StatelessWidget {
  final SecondaryTransactionModel model;

  TransactionSlipDialog(this.model, {super.key}) {
    Get.put(TransactionSlipDialogCtrl(this.model));
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneTransactionSlipDialogView();
    } else {
      return DesktopTransactionSlipDialogView();
    }
  }
}
