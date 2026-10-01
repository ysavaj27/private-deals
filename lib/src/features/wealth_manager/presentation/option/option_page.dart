import 'package:private_deals/src/features/wealth_manager/presentation/option/desktop_option_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/option/phone_option_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/option/option_page_ctrl.dart';

class OptionPage extends StatelessWidget {
  final OptionPageCtrl c = Get.put(OptionPageCtrl());

  OptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneOptionView();
    } else {
      return DesktopOptionView();
    }
  }
}
