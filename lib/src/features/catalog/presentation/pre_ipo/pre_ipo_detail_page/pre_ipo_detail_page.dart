import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/desktop_pre_ipo_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/phone_pre_ipo_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';

class PreIPODetailPage extends StatelessWidget {
  final PreIPODetailPageCtrl c = Get.put(PreIPODetailPageCtrl());

  PreIPODetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePreIPODetailView();
    } else {
      return DesktopPreIPODetailView();
    }
  }
}
