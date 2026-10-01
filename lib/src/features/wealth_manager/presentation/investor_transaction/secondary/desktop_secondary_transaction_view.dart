import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/secondary_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/widgets/lp_secondary_list.dart';

class DesktopSecondaryTransactionView extends StatelessWidget {
  final SecondaryTransactionPageCtrl c =
      Get.put(SecondaryTransactionPageCtrl());

  DesktopSecondaryTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: SearchBarTextField(
            hintText: 'Search company',
            onChanged: c.search,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LpSecondaryTransactionList(ctrl: c, isPhone: false),
        ),
      ],
    );
  }
}
