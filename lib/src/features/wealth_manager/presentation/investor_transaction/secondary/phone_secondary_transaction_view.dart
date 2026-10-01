import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/secondary_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/widgets/lp_secondary_list.dart';

class PhoneSecondaryTransactionView extends StatelessWidget {
  final SecondaryTransactionPageCtrl c =
      Get.put(SecondaryTransactionPageCtrl());

  PhoneSecondaryTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          SearchBarTextField(
            hintText: 'Search company',
            onChanged: c.search,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: LpSecondaryTransactionList(ctrl: c, isPhone: true),
          ),
        ],
      ),
    );
  }
}
