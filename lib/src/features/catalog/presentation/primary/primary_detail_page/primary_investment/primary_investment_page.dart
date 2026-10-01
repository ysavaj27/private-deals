import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/desktop_primary_investment_view.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/primary_investment_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/phone_primary_investment_view.dart';

class PrimaryInvestmentPage extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.put(PrimaryInvestmentPageCtrl());

  PrimaryInvestmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhonePrimaryInvestmentView();
    } else {
      return DesktopPrimaryInvestmentView();
    }
  }
}
