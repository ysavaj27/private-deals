import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/sell_request_page_ctrl.dart';

class PhoneSellRequestView extends StatelessWidget {
  final SellRequestPageCtrl c = Get.find<SellRequestPageCtrl>();

  PhoneSellRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (c.isLoading.isFalse) {
          if (c.list.isNotEmpty) {
            return ListView.separated(
              itemCount: c.list.length,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              itemBuilder: (context, index) {
                var model = c.list[index];
                return CustomCardWidget(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 13),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LogoImage(
                              url: model.startup.cms.logo,
                              height: 53,
                              width: 53,
                              radius: 4,
                            ),
                            const SizedBox(width: 7),
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                model.startup.brandName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xff58C800)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: AppColors.green(context))),
                              child: Text(model.currentStatus),
                            ),
                          ],
                        ),
                        const SizedBox(height: 17),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Shares",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              "${model.shares}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sell price",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              "${model.price.toCurrency}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 25),
            );
          } else {
            return const NoDataView();
          }
        } else {
          return const Loader();
        }
      }),
    );
  }
}
