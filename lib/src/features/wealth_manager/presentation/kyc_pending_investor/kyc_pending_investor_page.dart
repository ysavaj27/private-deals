import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/desktop_kyc_pending_investor_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/phone_kyc_pending_investor_view.dart';

class KycPendingInvestorPage extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.put(KycPendingInvestorPageCtrl());

  KycPendingInvestorPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneKycPendingInvestorView();
    } else {
      return DesktopKycPendingInvestorView();
    }
  }
}
