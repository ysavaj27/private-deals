import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/desktop_secondary_transaction_dialog_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/phone_secondary_transaction_dialog_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog_ctrl.dart';

class SecondaryTransactionDialog extends StatelessWidget {
  final DealModel model;

  SecondaryTransactionDialog(this.model, {super.key}) {
    Get.put(SecondaryTransactionDialogCtrl(model));
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneSecondaryTransactionDialogView();
    } else {
      return DesktopSecondaryTransactionDialogView();
    }
  }
}
