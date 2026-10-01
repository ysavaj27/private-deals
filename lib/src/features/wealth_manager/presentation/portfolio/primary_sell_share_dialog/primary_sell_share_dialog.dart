import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/desktop_primary_sell_share_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/phone_primary_sell_share_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/primary_sell_share_dialog/primary_sell_share_dialog_ctrl.dart';

class PrimarySellShareDialog extends StatelessWidget {
  final PortfolioModel model;

  PrimarySellShareDialog(this.model, {super.key}) {
    Get.put(PrimarySellShareDialogCtrl(model));
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePrimarySellShareDialogView();
    } else {
      return DesktopPrimarySellShareDialogView();
    }
  }
}
