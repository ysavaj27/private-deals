import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/desktop_pre_ipo_sell_share_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/phone_pre_ipo_sell_share_dialog_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/pre_ipo_sell_share_dialog/pre_ipo_sell_share_dialog_ctrl.dart';

class PreIPOSellShareDialog extends StatelessWidget {
  final PreIPOPortfolioModel model;

  PreIPOSellShareDialog(this.model, {super.key}) {
    Get.put(PreIPOSellShareDialogCtrl(model));
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePreIPOSellShareDialogView();
    } else {
      return DesktopPreIPOSellShareDialogView();
    }
  }
}
