import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_investment_page_ctrl.dart';

class DesktopPreIPOInvestmentView extends StatelessWidget {
  final PreIPOInvestmentPageCtrl c = Get.find<PreIPOInvestmentPageCtrl>();

  DesktopPreIPOInvestmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
/*
    return Scaffold(
      appBar: AppBar(title: Text(c.model().brandName)),
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
                        return Form(
                          key: c.desktopKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Investment in ${c.model().brandName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 24),
                              ),
                              const SizedBox(height: 28),
                              const Text(
                                'How much do you want to invest?',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 517,
                                child: CustomTextField(
                                  hintText: 'Enter amount',
                                  isFilled: true,
                                  isBorder: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9+]')),
                                  ],
                                  controller: c.amountCTRL,
                                  // errorStyle:
                                  //     TextStyle(color: context.theme.disabledColor),
                                  fillColor: context.isDarkMode
                                      ? context.theme.shadowColor
                                      : context.theme.scaffoldBackgroundColor,
                                  // controller: controller,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  hintStyle: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13),
                                  onChanged: c.onChange,
                                  validator: (p0) {
                                    if (p0 == null || p0.isEmpty) {
                                      return "Please Enter amount";
                                    }
                                    if (double.tryParse(p0) == null) {
                                      return 'Enter valid amount';
                                    }
                                    if (double.parse(p0) <
                                        c
                                            .model()
                                            .startupFundRaiseModel
                                            .minTicketSize) {
                                      return 'Please Enter a value greater then or equal to ${c.model().startupFundRaiseModel.minTicketSize.toCurrency}';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "The minimum investment is ${c.model().startupFundRaiseModel.minTicketSize.toCurrency}",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: context.theme.disabledColor),
                              ),
                              const SizedBox(height: 10),
                              Obx(() {
                                return Visibility(
                                  visible: c.isMixedAmount.isTrue,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () {
                                            c.amountCTRL.text =
                                                c.minAmount.toString();
                                            c.isMixedAmount(false);
                                            c.findShares(
                                                c.minAmount().toDouble());
                                            c.investedAmount(
                                                c.minAmount().toDouble());
                                          },
                                          child: CustomCardWidget(
                                            radius: 16,
                                            padding: const EdgeInsets.all(13),
                                            child: Center(
                                              child: Text(
                                                c.minAmount.toInt().toCurrency,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 1,
                                                softWrap: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                      Text(
                                        "Or",
                                        style: TextStyle(
                                          color: context.theme.colorScheme.onSurfaceVariant,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () {
                                            c.amountCTRL.text =
                                                c.maxAmount.toString();
                                            c.isMixedAmount(false);
                                            c.findShares(
                                                c.maxAmount().toDouble());
                                            c.investedAmount(
                                                c.maxAmount().toDouble());
                                          },
                                          child: CustomCardWidget(
                                            radius: 16,
                                            padding: const EdgeInsets.all(13),
                                            child: Center(
                                              child: Text(
                                                c.maxAmount.toInt().toCurrency,
                                                maxLines: 1,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 31),
                              const Text(
                                'Investment Details',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Share Price :",
                                        style: TextStyle(
                                          color: context.theme.colorScheme.onSurfaceVariant,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 39),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.sharePrice.toCurrency,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 52),
                              const Text(
                                "Payment Type",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 27),
                              Row(
                                children: [
                                  // _TabWidget(
                                  //   text: "Mandate",
                                  //   type: app.config.enumValues
                                  //       .primaryTransactionPaymentMode.mandate,
                                  // ),
                                  // SizedBox(width: 26),
                                  _TabWidget(
                                    text: "RTGS",
                                    type: app.config.enumValues
                                        .primaryTransactionPaymentMode.rtgs,
                                  ),
                                  const SizedBox(width: 26),
                                  _TabWidget(
                                    text: "Cheque",
                                    type: app.config.enumValues
                                        .primaryTransactionPaymentMode.cheque,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 31),
                              Row(
                                children: [
                                  Obx(() {
                                    return Checkbox(
                                      fillColor:
                                          WidgetStateProperty.resolveWith(
                                              (Set states) {
                                        if (states
                                            .contains(WidgetState.selected)) {
                                          return context.theme.primaryColor;
                                        } else {
                                          return context
                                              .theme.scaffoldBackgroundColor;
                                        }
                                      }),
                                      side: BorderSide(
                                          color:
                                              context.theme.iconTheme.color!),
                                      value: c.isSelected(),
                                      onChanged: (v) => c.isSelected(v),
                                    );
                                  }),
                                  Flexible(
                                    child: Text.rich(
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.theme.disabledColor,
                                      ),
                                      TextSpan(
                                        text: 'I have read and agree to the ',
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'investment Agreement',
                                            style: const TextStyle(
                                                color: Colors.blue),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => showCustomDialog(
                                                  PdfViewerDialog(
                                                      path: AppUrl
                                                          .itDisclosures)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 31),
                              Obx(() {
                                return CustomElevatedButton(
                                  width: 190,
                                  height: 50,
                                  radius: 16,
                                  isLoading: c.investing.value,
                                  text: 'Proceed',
                                  onPressed: () {
                                    if (c.desktopKey.currentState?.validate() ??
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
                                  },
                                );
                              }),
                            ],
                          ),
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
                                    fontWeight: FontWeight.w500, fontSize: 18),
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
                                child: CacheImage(
                                  url: c.model().details.banner,
                                  // height: 241,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.model().brandName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      c.model().briefInformation,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: context.theme.disabledColor,
                                      ),
                                    ),
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
                                                  c.investedAmount().toCurrency,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
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
                                                "No. of Shares :",
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
                                                  "${c.totalShare()}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 65),
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
                                              Text(
                                                c
                                                    .model()
                                                    .lastRoundModel
                                                    .instrument,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
                                              Text(
                                                c
                                                    .model()
                                                    .lastRoundModel
                                                    .sharePrice
                                                    .toCurrency,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
*/
  }
}
