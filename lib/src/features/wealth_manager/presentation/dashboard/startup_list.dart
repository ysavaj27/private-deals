import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_appbar.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';

class StartupList extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  StartupList({super.key});

  @override
  Widget build(BuildContext context) {
    // logger.d("Length :${c.model().misList.length}");
    return Scaffold(
      appBar: const PhoneAppBar(title: "Dashboard"),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 17),
        physics: const BouncingScrollPhysics(),
        itemCount: c.model().investors.length,
        itemBuilder: (context, index) {
          var model = c.model().investors[index];
          return InvestmentGridItem(investment: model);
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
      ),
    );
  }
}

class InvestmentGridItem extends StatelessWidget {
  final WInvestorModel investment;

  const InvestmentGridItem({super.key, required this.investment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              investment.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "${investment.totalStartups}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            investment.amountInvested.toFormattedPrice,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
