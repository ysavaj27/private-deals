import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/pre_ipo_sell_transaction_page_ctrl.dart';

class DesktopPreIPOSellTransactionView extends StatelessWidget {
  final PreIPOSellTransactionPageCtrl c =
      Get.put(PreIPOSellTransactionPageCtrl());

  DesktopPreIPOSellTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarTextField(
          onChanged: (p0) => c.search(p0),
          hintText: 'Search by Company Name',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Obx(() {
            if (c.isLoading.isFalse) {
              if (c.finalList.isNotEmpty) {
                return CustomCardWidget(
                  radius: 20,
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
                              child: HeadingText("Company"),
                            ),

                            Expanded(
                              flex: 2,
                              child: Center(child: HeadingText("Amount")),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  Center(child: HeadingText("Current Status")),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(child: HeadingText("Next Step")),
                            ),
                            // Expanded(
                            //     child: Center(child: HeadingText("Action"))),
                          ],
                        ),
                      ),
                      Divider(
                        color: context.theme.dividerColor.withValues(alpha: 0.2),
                        thickness: 0.7,
                        height: 1,
                      ),
                      Expanded(
                        child: Obx(() {
                          if (c.isLoading.isFalse) {
                            if (c.list.isNotEmpty) {
                              return RefreshIndicator(
                                onRefresh: c.getData,
                                child: ListView.builder(
                                  itemCount: c.finalList.length,
                                  physics: const AlwaysScrollableScrollPhysics(
                                      parent: BouncingScrollPhysics()),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 10),
                                  itemBuilder: (context, index) {
                                    var model = c.finalList[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${index + 1}",
                                              style: const TextStyle(),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                LogoImage(
                                                  url: model.company.logo,
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.contain,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    model.company.brandName,
                                                    style: TextStyle(
                                                        color: context.theme
                                                            .dividerColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Text(
                                                model.price.toFormattedPrice,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Text(
                                                model.currentStatus,
                                                style: TextStyle(
                                                  color: context
                                                      .theme.dividerColor,
                                                  // color: model.statusReturnOfInvest,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: Text(
                                                model.nextStep,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: context
                                                        .theme.dividerColor),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return NoDataView(onPressed: c.getData);
                            }
                          } else {
                            return const Loader();
                          }
                        }),
                      ),
                    ],
                  ),
                );
              } else {
                return NoDataView(onPressed: c.getData);
              }
            } else {
              return const Loader();
            }
          }),
        ),
      ],
    );
  }
}
