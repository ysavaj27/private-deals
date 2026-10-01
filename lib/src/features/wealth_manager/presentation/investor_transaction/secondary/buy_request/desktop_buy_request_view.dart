import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/buy_request/buy_request_page_ctrl.dart';

class DesktopBuyRequestView extends StatelessWidget {
  final BuyRequestPageCtrl c = Get.find<BuyRequestPageCtrl>();

  DesktopBuyRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("Secondary opportunities"),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isFalse) {
                  if (c.list.isNotEmpty) {
                    return SingleChildScrollView(
                      child: Wrap(
                        // crossAxisAlignment: WrapCrossAlignment.end,
                        // alignment: WrapAlignment.end,
                        // direction: Axis.horizontal,
                        // runAlignment: WrapAlignment.end,
                        runSpacing: 20,
                        spacing: 20,
                        children: c.list.map((model) {
                          logger.d(model.toJson());
                          return CustomCardWidget(
                            width: 350,
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 25),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          LogoImage(
                                            url: model.startup.cms.logo,
                                            height: 53,
                                            width: 53,
                                            radius: 4,
                                          ),
                                          const SizedBox(width: 7),
                                          Column(
                                            children: [
                                              Text(
                                                model.startup.brandName,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              const SizedBox(height: 3),
                                              // Text(
                                              //   model.startupName,
                                              //   style: TextStyle(
                                              //       fontWeight: FontWeight.bold,
                                              //       color: context.theme.colorScheme.onSurfaceVariant,
                                              //       fontSize: 14),
                                              // ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Visibility(
                                            visible: !model.isRejected,
                                            child: SizedBox(
                                              height: 58,
                                              width: 58,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  SizedBox.square(
                                                    dimension: 112,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: model.expiredAt
                                                          .progress(),
                                                      color: context
                                                          .theme.primaryColor,
                                                      strokeCap:
                                                          StrokeCap.round,
                                                      strokeWidth: 4,
                                                      backgroundColor:
                                                          const Color(
                                                              0xff141414),
                                                    ),
                                                  ),
                                                  Text.rich(
                                                    textAlign: TextAlign.center,
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${model.expiredAt.timeRemainingValue}\n',
                                                          style: GoogleFonts
                                                              .fraunces(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: model.expiredAt
                                                              .timeRemainingUnit,
                                                          style: TextStyle(
                                                            fontSize: 9,
                                                            color: context.theme
                                                                .disabledColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.trending_up_rounded,
                                            color:
                                                context.theme.iconTheme.color,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Shares",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: context.theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${model.shares}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.currency_rupee_rounded,
                                            color:
                                                context.theme.iconTheme.color,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Sell price",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: context.theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            "${model.price.toCurrency}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                        ],
                                      ),
                                      Visibility(
                                        visible: model.isPending &&
                                            model.expiredAt.isActive,
                                        child: const SizedBox(height: 23),
                                      ),
                                      Visibility(
                                        visible: model.isPending &&
                                            model.expiredAt.isActive,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Obx(() {
                                              RxBool isLoading = false.obs;
                                              return CustomElevatedButton(
                                                width: 112,
                                                height: 45,
                                                isLoading: isLoading.value,
                                                backgroundColor:
                                                    const Color(0xff6A0E0D),
                                                text: 'Decline',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                onPressed: () async {
                                                  isLoading(true);
                                                  await c.updateStatus(
                                                      id: model.id,
                                                      status: app
                                                          .config
                                                          .enumValues
                                                          .status
                                                          .rejected);
                                                  isLoading(false);
                                                },
                                              );
                                            }),
                                            Obx(() {
                                              RxBool isLoading = false.obs;
                                              return CustomElevatedButton(
                                                width: 112,
                                                backgroundColor:
                                                    const Color(0xff336006),
                                                height: 45,
                                                text: 'Approve',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                isLoading: isLoading.value,
                                                onPressed: () async {
                                                  isLoading(true);
                                                  await c.updateStatus(
                                                      id: model.id,
                                                      status: app
                                                          .config
                                                          .enumValues
                                                          .status
                                                          .approved);
                                                  isLoading(false);
                                                },
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCardWidget(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8)),
                                  border: Border(
                                    top: BorderSide(
                                        color: AppColors.borderColor(context)),
                                  ),
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    child: Text(
                                      model.message,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context
                                            .theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return const NoDataView();
                  }
                } else {
                  return const Loader();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
