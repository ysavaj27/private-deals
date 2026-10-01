import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';

class InvestorDialog extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  InvestorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      constraints: BoxConstraints(
        maxHeight: context.height * 0.8,
        minHeight: 250,
        maxWidth: context.width * 0.8,
        minWidth: context.width * 0.4,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
      radius: 55,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Investors",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),
            ...List.generate(
              c.model().investors.length,
              (index) {
                var model = c.model().investors[index];
                return CustomCardWidget(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        flex:2,
                        child: Text(
                          model.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${model.totalStartups}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${model.amountInvested.toFormattedPrice}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
