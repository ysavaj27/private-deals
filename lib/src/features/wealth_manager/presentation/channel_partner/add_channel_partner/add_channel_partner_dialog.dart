import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/desktop_add_channel_partner_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/phone_add_channel_partner_view.dart';

class AddChannelPartnerDialog extends StatelessWidget {
   final PartnerUser? model;
 late   final AddChannelPartnerDialogCtrl c ;

  AddChannelPartnerDialog({super.key,this.model}){
    Get.put(AddChannelPartnerDialogCtrl(this.model));
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneAddChannelPartnerView();
    } else {
      return DesktopAddChannelPartnerView();
    }
  }
}
