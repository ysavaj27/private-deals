import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy_kyc/desktop_kyc_view.dart';
import 'package:private_deals/src/features/investors/presentation/legacy_kyc/kyc_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy_kyc/phone_kyc_view.dart';

class KYCPage extends StatelessWidget {
  final KYCPageCtrl c = Get.put(KYCPageCtrl());

  KYCPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneKycView();
    } else {
      return DesktopKycView();
    }
  }
}
