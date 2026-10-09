import 'package:private_deals/src/shared/app_exports.dart';

import 'dashboard_page_ctrl.dart';
import 'dashboard_view.dart';

class DashboardPage extends StatelessWidget {
  final DashboardPageCtrl c = Get.put(DashboardPageCtrl());
  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => const WealthDashboardView();
}
