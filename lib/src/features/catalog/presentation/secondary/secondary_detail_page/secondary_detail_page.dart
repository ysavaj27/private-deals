import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_detail_page/desktop_secondary_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_detail_page/phone_secondary_detail_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_detail_page/secondary_detail_page_ctrl.dart';

class SecondaryDetailPage extends StatelessWidget {
  final SecondaryDetailPageCtrl c = Get.put(SecondaryDetailPageCtrl());

  SecondaryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return const PhoneSecondaryDetailView();
    } else {
      return const DesktopSecondaryDetailViews();
    }
  }
}
