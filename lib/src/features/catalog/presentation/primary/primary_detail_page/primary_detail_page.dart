import 'package:private_deals/src/shared/app_exports.dart';

import 'desktop_primary_detail_view.dart';
import 'phone_primary_detail_view.dart';
import 'primary_detail_page_ctrl.dart';

class PrimaryDetailPage extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.put(PrimaryDetailPageCtrl());

  PrimaryDetailPage({super.key});

  @override
  Widget build(BuildContext context) => AppWindow.compact(context)
      ? const PhonePrimaryDetailView()
      : const DesktopPrimaryDetailView();
}
