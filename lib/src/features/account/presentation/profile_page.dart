import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/account/presentation/desktop_profile_view.dart';
import 'package:private_deals/src/features/account/presentation/phone_profile_view.dart';
import 'package:private_deals/src/features/account/presentation/profile_page_ctrl.dart';

class ProfilePage extends StatelessWidget {
  final ProfilePageCtrl c = Get.put(ProfilePageCtrl());

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneProfileView();
    } else {
      return DesktopProfileView();
    }
  }
}
