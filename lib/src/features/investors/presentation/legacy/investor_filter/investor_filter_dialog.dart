import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/desktop_investor_filter_view.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/phone_investor_filter_view.dart';

class InvestorFilterDialog extends StatelessWidget {
  const InvestorFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneInvestorFilterView();
    } else {
      return DesktopInvestorFilterView();
    }
  }
}
