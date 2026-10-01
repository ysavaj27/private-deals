import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';

class StartupDialog extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  StartupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      constraints: BoxConstraints(
        maxHeight: context.height * 0.8,
        minHeight: 400,
        maxWidth: context.width * 0.8,
      ),
      radius: 55,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 55),
            ...List.generate(
              c.model().investors.length,
              (index) {
                var model = c.model().investors[index];
                return CustomCardWidget(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  padding: EdgeInsets.symmetric(vertical: 35, horizontal: 44),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          model.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "${model.totalStartups}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "${model.amountInvested.toFormattedPrice}",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
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
