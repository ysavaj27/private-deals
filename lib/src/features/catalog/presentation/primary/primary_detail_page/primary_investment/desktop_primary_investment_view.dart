import 'package:flutter/gestures.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/primary_investment_page_ctrl.dart';

class DesktopPrimaryInvestmentView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  DesktopPrimaryInvestmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(title: Obx(() {
          return Text(c.model().brandName);
        })),
        body: CustomCardWidget(
          margin: const EdgeInsets.symmetric(vertical: 37, horizontal: 57),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 46),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Obx(
                    () {
                      if (c.isLoading.isFalse) {
                        if (c.alreadyInvested.isFalse) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Investment in ${c.model().brandName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 24),
                              ),
                              const SizedBox(height: 15),
                              Text.rich(
                                style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                TextSpan(
                                  text:
                                      "In Captable, invest directly in the startup and have your name reflected on its cap table while in AIF, pool your investment with others via a SEBI-registered fund and get units into your demat account.",
                                  children: <TextSpan>[
                                    // TextSpan(
                                    //   text: 'Learn More',
                                    //   style:
                                    //       const TextStyle(color: Colors.blue),
                                    //   recognizer: TapGestureRecognizer()
                                    //     ..onTap = () {
                                    //       showCustomDialog(
                                    //           const MoreInfoDialog());
                                    //     },
                                    // ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 16),
                              // Obx(() {
                              //   return AbsorbPointer(
                              //     absorbing: c.alreadyInvested.isTrue,
                              //     child: Row(
                              //       children: [
                              //         Expanded(
                              //             child: _TabView(
                              //                 PrimaryInvestmentType.Captable)),
                              //         const SizedBox(width: 20),
                              //         Expanded(
                              //             child: _TabView(
                              //                 PrimaryInvestmentType.AIF)),
                              //       ],
                              //     ),
                              //   );
                              // }),
                              const SizedBox(height: 16),
                              MainView(),
                              const SizedBox(height: 30),
                              Visibility(
                                visible: c.alreadyInvested.isFalse,
                                child: CustomElevatedButton(
                                  backgroundColor: AppColors.green(context),
                                  isLoading: c.investing.value,
                                  onPressed: () {
                                    // if (c.type() ==
                                    //     PrimaryInvestmentType.Captable) {
                                    if (c.captableDesktopKey.currentState
                                            ?.validate() ??
                                        false) {
                                      if (c.isSelected.isFalse) {
                                        toast(
                                            'Please approve teams & condition');
                                        return;
                                      }
                                      if (c.paymentMode.value != null &&
                                          c.paymentMode()!.isNotEmpty) {
                                        c.onPress();
                                      } else {
                                        toast('Please select payment type');
                                      }
                                    }
                                    // } else {
                                    //   if (c.aifDesktopKey.currentState
                                    //           ?.validate() ??
                                    //       false) {
                                    //     if (c.isSelected.isFalse) {
                                    //       toast(
                                    //           'Please approve teams & condition');
                                    //       return;
                                    //     }
                                    //     if (c.paymentMode.value != null &&
                                    //         c.paymentMode()!.isNotEmpty) {
                                    //       c.investedAmount(
                                    //           c.enterPrice().aifFinalPrice);
                                    //       c.gst = c.enterPrice().aifGST;
                                    //       c.fees =
                                    //           c.enterPrice().aifManagementFees;
                                    //       c.totalShare.value =
                                    //           (c.investedAmount() / 1000)
                                    //               .formatUnit();
                                    //       c.onPress();
                                    //     } else {
                                    //       toast('Please select payment type');
                                    //     }
                                    //   }
                                    // }
                                  },
                                  text: 'Invest',
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Investing in ${c.model().brandName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 24),
                              ),
                              const SizedBox(height: 28),
                              Obx(() {
                                return Text(
                                  c.transaction().nextStep,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                );
                              }),
                              const SizedBox(height: 43),
                              const Center(
                                  child: LottieImage(
                                path: AppAssets.sign,
                              )),
                            ],
                          );
                        }
                      } else {
                        return const Loader();
                      }
                    },
                  ),
                ),
                SizedBox(width: context.isTablet ? 30 : 40),
                Expanded(
                  child: Column(
                    children: [
                      CustomCardWidget(
                        // margin: EdgeInsets.symmetric(vertical: 32, horizontal: 46),
                        padding: context.width > 900
                            ? const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 40)
                            : null,
                        radius: 20,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: CustomCardWidget(
                            radius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Obx(() {
                                    return CacheImage(
                                      url: c.model().cms.banner,
                                      width: context.width,
                                      height: 250,
                                      fit: BoxFit.fitWidth,
                                      // height: 241,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 35),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(() {
                                        return Text(
                                          c.model().brandName,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 16),
                                      Obx(() {
                                        return Text(
                                          c.model().cms.oneLiner,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: context.theme.disabledColor,
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 26),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Investment amount :",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: context
                                                        .theme.disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Obx(() {
                                                  return Text(
                                                    // c.isCaptable
                                                    //     ?
                                                    c
                                                        .investedAmount()
                                                        .toCurrency,
                                                    // : c
                                                    //     .enterPrice()
                                                    //     .toCurrency,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Obx(() {
                                                //   return
                                                Text(
                                                  // c.isCaptable
                                                  //     ?
                                                  "No. of Shares :",
                                                  // : "No. of Units",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: context
                                                        .theme.disabledColor,
                                                  ),
                                                ),
                                                // ;
                                                //   }),
                                                const SizedBox(height: 20),
                                                Obx(() {
                                                  return Text(
                                                    // c.isCaptable
                                                    //     ?
                                                    c
                                                        .totalShare()
                                                        .formattedDecimal,
                                                    // :
                                                    // (c.investedAmount() /
                                                    //           1000)
                                                    //       .formatUnit()
                                                    //       .formattedDecimal,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Share type :",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: context
                                                        .theme.disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Obx(() {
                                                  return Text(
                                                    c
                                                        .model()
                                                        .raisingRound
                                                        .instrument
                                                        .instrumentName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Share Price",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: context
                                                        .theme.disabledColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Obx(() {
                                                  return Text(
                                                    // c.isCaptable
                                                    //     ?
                                                    c
                                                        .model()
                                                        .raisingRound
                                                        .sharePrice
                                                        .toCurrency,
                                                    // : "1000",
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 48),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Obx(() {
                      //   return Visibility(
                      //     visible: !c.isCaptable,
                      //     child: CustomCardWidget(
                      //       child: Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             horizontal: 20, vertical: 24),
                      //         child: Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             const Row(
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 Icon(
                      //                   Icons.bookmark_outline,
                      //                   size: 23,
                      //                 ),
                      //                 SizedBox(width: 10),
                      //                 Text(
                      //                   'Summary',
                      //                   style: TextStyle(
                      //                     fontSize: 20,
                      //                     fontWeight: FontWeight.bold,
                      //                     color: Colors.white,
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 20),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 const Text(
                      //                   'Investment amount:',
                      //                   style: TextStyle(color: Colors.white),
                      //                 ),
                      //                 Obx(() {
                      //                   return Text(
                      //                     c.enterPrice().toCurrency,
                      //                     style: const TextStyle(
                      //                         color: Colors.white),
                      //                   );
                      //                 }),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 10),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 const Text(
                      //                   'Management fees',
                      //                   // 2%
                      //                   style: TextStyle(color: Colors.white),
                      //                 ),
                      //                 Obx(() {
                      //                   return Text(
                      //                     c
                      //                         .enterPrice()
                      //                         .aifManagementFees
                      //                         .toCurrency,
                      //                     style: const TextStyle(
                      //                         color: Colors.white),
                      //                   );
                      //                 }),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 10),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 const Text(
                      //                   'GST',
                      //                   // 18 of 2%%
                      //                   style: TextStyle(color: Colors.white),
                      //                 ),
                      //                 Obx(() {
                      //                   return Text(
                      //                     c.enterPrice().aifGST.toCurrency,
                      //                     style: const TextStyle(
                      //                         color: Colors.white),
                      //                   );
                      //                 }),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 10),
                      //             const Divider(color: Colors.white),
                      //             const SizedBox(height: 10),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 const Text(
                      //                   'No of units',
                      //                   style: TextStyle(color: Colors.white),
                      //                 ),
                      //                 Obx(() {
                      //                   return Text(
                      //                     "${(c.investedAmount() / 1000).formatUnit()}",
                      //                     style: const TextStyle(
                      //                         color: Colors.white),
                      //                   );
                      //                 }),
                      //               ],
                      //             ),
                      //             const SizedBox(height: 10),
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 const Text(
                      //                   'Final Amount',
                      //                   style: TextStyle(
                      //                     fontWeight: FontWeight.bold,
                      //                     fontSize: 18,
                      //                     color: Colors.white,
                      //                   ),
                      //                 ),
                      //                 Obx(() {
                      //                   return Text(
                      //                     c.investedAmount().toCurrency,
                      //                     style: const TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 18,
                      //                       color: Colors.white,
                      //                     ),
                      //                   );
                      //                 }),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabWidget extends StatelessWidget {
  final String text;
  final String type;

  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  _TabWidget({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(16),
        onTap: () => c.paymentMode(type),
        child: Obx(() {
          bool isSelected = c.paymentMode() == type;
          return CustomCardWidget(
            borderWidth: isSelected ? 2 : 1,
            radius: 16,
            padding: const EdgeInsets.symmetric(vertical: 13),
            borderColor: isSelected ? context.theme.iconTheme.color : null,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// class _TabView extends StatelessWidget {
//   final InvestmentPageCtrl c = Get.find<InvestmentPageCtrl>();
//   final PrimaryInvestmentType type;
//
//   _TabView(this.type);
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       bool isSelected = c.type() == type;
//       return InkWell(
//         mouseCursor: SystemMouseCursors.click,
//         onTap: () {
//           c.type(type);
//           c.clearData();
//         },
//         borderRadius: BorderRadius.circular(8),
//         child: CustomCardWidget(
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           radius: 8,
//           borderColor: context.iconColor,
//           color: isSelected ? context.iconColor : Colors.transparent,
//           alignment: Alignment.center,
//           child: Text(
//             type.name,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isSelected
//                   ? context.theme.scaffoldBackgroundColor
//                   : context.iconColor,
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }

class MainView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (c.alreadyInvested.isFalse) {
          //   switch (c.type()) {
          //     case PrimaryInvestmentType.Captable:
          return CaptableView();
          // case PrimaryInvestmentType.AIF:
          //   return AIFView();
          // }
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Investing in ${c.model().brandName}',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
              ),
              const SizedBox(height: 28),
              Obx(() {
                return Text(
                  c.transaction().nextStep,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 18),
                );
              }),
              const SizedBox(height: 40),
              const Center(child: LottieImage(path: AppAssets.sign)),
            ],
          );
        }
      },
    );
  }
}

class CaptableView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  CaptableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "How much do you want to invest?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Form(
              key: c.captableDesktopKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: CustomTextField(
                autofocus: false,
                borderColor: context.theme.dividerColor.withValues(alpha: 0.8),
                hintText: 'Enter amount',
                isFilled: true,
                isBorder: true,
                controller: c.amountCTRL,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                ],
                // errorStyle:
                //     TextStyle(color: context.theme.disabledColor),
                fillColor: context.isDarkMode
                    ? context.theme.shadowColor
                    : context.theme.scaffoldBackgroundColor,
                // controller: controller,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                hintStyle:
                    const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
                onChanged: c.onChangeForCapTable,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return "Please Enter amount";
                  }
                  if (double.tryParse(p0) == null) {
                    return 'Enter valid amount';
                  }
                  if (double.parse(p0) <
                      c.model().raisingRound.minimumInvestment) {
                    return 'Min ticket size is ${c.model().raisingRound.minimumInvestment.toCurrency}';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Visibility(
                visible: c.isMixedAmount.isTrue,
                child: Text(
                  "To own a whole number of shares you must enter and amount that is a multiple of ${c.model().raisingRound.sharePrice.toCurrency} such as:",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
            Obx(() {
              return Visibility(
                visible: c.isMixedAmount.isTrue,
                child: const SizedBox(height: 12),
              );
            }),
            Obx(() {
              return Visibility(
                visible: c.isMixedAmount.isTrue,
                child: Row(
                  children: [
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        c.amountCTRL.text = c.minAmount.toString();
                        c.isMixedAmount(false);
                        c.findShares(c.minAmount().toDouble());
                        c.investedAmount(c.minAmount().toDouble());
                      },
                      child: CustomCardWidget(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38, vertical: 10),
                        child: Text(
                          c.minAmount().toCurrency,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Or",
                          style: TextStyle(
                            color: context.theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        c.amountCTRL.text = c.maxAmount.toString();
                        c.isMixedAmount(false);
                        c.findShares(c.maxAmount().toDouble());
                        c.investedAmount(c.maxAmount().toDouble());
                      },
                      child: CustomCardWidget(
                        radius: 12,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38, vertical: 10),
                        child: Text(
                          c.maxAmount().toCurrency,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Obx(() {
              return Visibility(
                visible: c.isMixedAmount.isTrue,
                child: const SizedBox(height: 16),
              );
            }),
            const SizedBox(height: 16),
            const Text(
              "Investment Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            CustomCardWidget(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Obx(() {
                    return _DetailWidget(
                      title: "Investment amount:",
                      data: c.investedAmount().toCurrency,
                    );
                  }),
                  const SizedBox(height: 18),
                  Obx(() {
                    return _DetailWidget(
                      title:
                          // c.isCaptable ?
                          "No. of Shares :",
                      // : "No. of Units",
                      data:
                          // c.isCaptable ?
                          c.totalShare().formattedDecimal,
                      // : (c.investedAmount() / 1000)
                      //     .formatUnit()
                      //     .formattedDecimal,
                    );
                  }),
                  const SizedBox(height: 18),
                  _DetailWidget(
                    title: "Share type:",
                    data: c.model().raisingRound.instrument.instrumentName,
                  ),
                  const SizedBox(height: 18),
                  _DetailWidget(
                    title: "Share Price:",
                    data: c.model().raisingRound.sharePrice.toCurrency,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Mode Of Payment ",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                // _TabWidget(
                //   text: "Mandate",
                //   type: app
                //       .config.enumValues.primaryTransactionPaymentMode.mandate,
                // ),
                // SizedBox(width: 5),
                _TabWidget(
                  text: "RTGS",
                  type:
                      app.config.enumValues.primaryTransactionPaymentMode.rtgs,
                ),
                const SizedBox(width: 20),
                _TabWidget(
                  text: "Cheque",
                  type: app
                      .config.enumValues.primaryTransactionPaymentMode.cheque,
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Obx(() {
                  return Checkbox(
                    fillColor: WidgetStateProperty.resolveWith((Set states) {
                      if (states.contains(WidgetState.selected)) {
                        return context.theme.primaryColor;
                      } else {
                        return context.theme.scaffoldBackgroundColor;
                      }
                    }),
                    side: BorderSide(
                        color: context.theme.iconTheme.color ?? Colors.white),
                    value: c.isSelected(),
                    onChanged: (v) => c.isSelected(v),
                  );
                }),
                // SizedBox(width: 3),
                Flexible(
                  child: Text.rich(
                    style: TextStyle(
                      fontSize: 12,
                      color: context.theme.disabledColor,
                    ),
                    TextSpan(
                      text:
                          'I have read and agree to the Disclaimer, privacy policy, terms of use, risk disclosure.',
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Investment Agreement',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                Launcher.openNewTab(AppUrl.itDisclosures);

                                // );
                              }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// class AIFView extends StatelessWidget {
//   final InvestmentPageCtrl c = Get.find<InvestmentPageCtrl>();
//
//   AIFView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Obx(() {
//         //   return Visibility(
//         //     visible: !c.investor().aifStatus,
//         //     child: CustomCardWidget(
//         //       borderColor: context.theme.disabledColor,
//         //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         //       child: Column(
//         //         children: [
//         //           const Row(
//         //             mainAxisAlignment: MainAxisAlignment.center,
//         //             children: [
//         //               Icon(
//         //                 Icons.warning_amber_rounded,
//         //               ),
//         //               SizedBox(width: 10),
//         //               Text(
//         //                 "Complete your kyc",
//         //                 style: TextStyle(fontSize: 16),
//         //               ),
//         //             ],
//         //           ),
//         //           const SizedBox(height: 10),
//         //           Text(
//         //             "Please complete your KYC for onboarding as an investor on AIF",
//         //             textAlign: TextAlign.center,
//         //             style: TextStyle(
//         //                 fontSize: 12, color: context.theme.colorScheme.onSurfaceVariant),
//         //           ),
//         //           const SizedBox(height: 10),
//         //           CustomElevatedButton(
//         //             text: 'KYC',
//         //             width: 150,
//         //             height: 40,
//         //             backgroundColor: context.iconColor,
//         //             color: context.theme.scaffoldBackgroundColor,
//         //             onPressed: () async {
//         //               await Get.to(() => AifOnboardingPage(),
//         //                   arguments: c.investor());
//         //             },
//         //           ),
//         //         ],
//         //       ),
//         //     ),
//         //   );
//         // }),
//         Visibility(
//           visible: !app.iUser.aifStatus,
//           child: const SizedBox(height: 18),
//         ),
//         const Text(
//           "How much do you want to invest?",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 12),
//         Form(
//           key: c.aifDesktopKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: CustomTextField(
//             autofocus: false,
//             borderColor: context.theme.dividerColor.withValues(alpha: 0.8),
//             hintText: 'Enter amount',
//             isFilled: true,
//             isBorder: true,
//             controller: c.aifAmountCTRL,
//             onChanged: c.onChangeForAIF,
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
//             ],
//             // errorStyle:
//             //     TextStyle(color: context.theme.disabledColor),
//             fillColor: context.isDarkMode
//                 ? context.theme.shadowColor
//                 : context.theme.scaffoldBackgroundColor,
//             // controller: controller,
//             keyboardType: TextInputType.number,
//             textInputAction: TextInputAction.done,
//             hintStyle:
//                 const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
//             validator: (p0) {
//               if (p0 == null || p0.isEmpty) {
//                 return "Please Enter amount";
//               }
//               if (double.tryParse(p0) == null) {
//                 return 'Enter valid amount';
//               }
//               if (double.parse(p0) <
//                   c.model().raisingRound.minimumInvestmentAif) {
//                 return 'Min ticket size is ${c.model().raisingRound.minimumInvestmentAif.toCurrency}';
//               }
//               return null;
//             },
//           ),
//         ),
//         const SizedBox(height: 12),
//         const Text(
//           "Investment Details",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 12),
//         CustomCardWidget(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             children: [
//               const SizedBox(height: 12),
//               Obx(() {
//                 return _DetailWidget(
//                   title: "Investment amount:",
//                   data: c.enterPrice().toCurrency,
//                 );
//               }),
//               const SizedBox(height: 18),
//               Obx(() {
//                 return _DetailWidget(
//                   title: "No. of units:",
//                   data:
//                       (c.investedAmount() / 1000).formatUnit().formattedDecimal,
//                 );
//               }),
//               const SizedBox(height: 18),
//               _DetailWidget(
//                 title: "Share type:",
//                 data: c.model().raisingRound.instrument.instrumentName,
//               ),
//               const SizedBox(height: 18),
//               const _DetailWidget(
//                 title: "Unit Price:",
//                 data: "1000",
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           "Mode Of Payment ",
//           style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//         ),
//         const SizedBox(height: 23),
//         Row(
//           children: [
//             // _TabWidget(
//             //   text: "Mandate",
//             //   type: app
//             //       .config.enumValues.primaryTransactionPaymentMode.mandate,
//             // ),
//             // SizedBox(width: 5),
//             _TabWidget(
//               text: "RTGS",
//               type: app.config.enumValues.primaryTransactionPaymentMode.rtgs,
//             ),
//             const SizedBox(width: 20),
//             _TabWidget(
//               text: "Cheque",
//               type: app.config.enumValues.primaryTransactionPaymentMode.cheque,
//             ),
//           ],
//         ),
//         const SizedBox(height: 13),
//         Row(
//           children: [
//             Obx(() {
//               return Checkbox(
//                 fillColor: WidgetStateProperty.resolveWith((Set states) {
//                   if (states.contains(WidgetState.selected)) {
//                     return context.theme.primaryColor;
//                   } else {
//                     return context.theme.scaffoldBackgroundColor;
//                   }
//                 }),
//                 side: BorderSide(
//                     color: context.theme.iconTheme.color ?? Colors.white),
//                 value: c.isSelected(),
//                 onChanged: (v) => c.isSelected(v),
//               );
//             }),
//             // SizedBox(width: 3),
//             Flexible(
//               child: Text.rich(
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: context.theme.disabledColor,
//                 ),
//                 TextSpan(
//                   text:
//                       'I have read and agree to the Disclaimer, privacy policy, terms of use, risk disclosure.',
//                   children: <TextSpan>[
//                     TextSpan(
//                       text: 'Investment Agreement',
//                       style: const TextStyle(color: Colors.blue),
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () => Get.to(
//                               () => PdfViewerPage(
//                                 path: AppUrl.itDisclosures,
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class _DetailWidget extends StatelessWidget {
  final String title;
  final String data;

  const _DetailWidget({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            data,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
