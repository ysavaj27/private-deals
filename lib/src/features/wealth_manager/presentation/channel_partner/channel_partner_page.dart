import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/channel_partner_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/desktop_channel_partner_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/phone_channel_partner_view.dart';

class ChannelPartnerPage extends StatelessWidget {
  final ChannelPartnerPageCtrl c = Get.put(ChannelPartnerPageCtrl());

  ChannelPartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneChannelPartnerView();
    } else {
      return DesktopChannelPartnerView();
    }
  }
}
