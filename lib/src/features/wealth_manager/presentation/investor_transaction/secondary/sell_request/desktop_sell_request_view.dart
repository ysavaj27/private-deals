import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/sell_request/sell_request_page_ctrl.dart';

class DesktopSellRequestView extends StatelessWidget {
  final SellRequestPageCtrl c = Get.find<SellRequestPageCtrl>();
  DesktopSellRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("My Sell Requests"),
            const SizedBox(height: 18),
            Expanded(
              child: CustomCardWidget(
                radius: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(40, 0, 40, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: HeadingText("No"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Starup"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Shares"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Sell Price"),
                            ),
                            Expanded(
                                flex: 2,
                                child: Center(child: HeadingText("Status"))),
                          ],
                        ),
                      ),
                      Divider(
                        color: context.theme.disabledColor.withValues(alpha: 0.2),
                        thickness: 0.7,
                        height: 1,
                      ),
                      Expanded(
                        child: Obx(() {
                          if (c.isLoading.isFalse) {
                            if (c.list.isNotEmpty) {
                              return ListView.builder(
                                itemCount: c.list.length,
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                itemBuilder: (context, index) {
                                  var model = c.list[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${index + 1}",
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              LogoImage(
                                                url: model.startup.cms.logo,
                                                height: 45,
                                                width: 45,
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                model.startup.brandName,
                                                style: TextStyle(
                                                    color: context
                                                        .theme.dividerColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${model.shares}",
                                            style: const TextStyle(),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${model.currentPrice.toCurrency}",
                                            style: const TextStyle(),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: Text(
                                              "${model.currentStatus}",
                                              style: const TextStyle(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              return NoDataView();
                            }
                          } else {
                            return const Loader();
                          }
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
