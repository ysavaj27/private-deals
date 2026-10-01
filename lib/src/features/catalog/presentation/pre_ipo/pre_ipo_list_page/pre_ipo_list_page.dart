import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/desktop_pre_ipo_list_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/phone_pre_ipo_list_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/pre_ipo_list_page_ctrl.dart';

class PreIPOListPage extends StatelessWidget {
  final PreIPOListPageCtrl c = Get.put(PreIPOListPageCtrl());

  PreIPOListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePreIPOListView();
    } else {
      return DesktopPreIPOListView();
    }
  }
}
