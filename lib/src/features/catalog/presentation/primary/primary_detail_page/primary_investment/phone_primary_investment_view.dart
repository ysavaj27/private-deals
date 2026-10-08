import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';
import 'package:flutter/gestures.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_investment/primary_investment_page_ctrl.dart';

class PhonePrimaryInvestmentView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  PhonePrimaryInvestmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Primary Transaction")),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CacheImage(
                    url: c.model().cms.logo,
                    height: 80,
                    width: 80,
                  ),
                ),
                const SizedBox(width: 17),
                Expanded(
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
                      const SizedBox(height: 8),
                      Text(
                        c.model().cms.oneLiner,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 21),
            Text.rich(
              style: TextStyle(
                fontSize: 12,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              TextSpan(
                text: "In Captable, invest directly in the startup and have your name reflected on its cap table while in AIF, pool your investment with others via a SEBI-registered fund and get units into your demat account.",
                children: <TextSpan>[
                  TextSpan(
                    text: 'Learn More',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showCustomDialog(const MoreInfoDialog());
                      },
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 16),
            // Obx(() {
            //   return AbsorbPointer(
            //     absorbing: c.alreadyInvested.isTrue,
            //     child: Row(
            //       children: [
            //         Expanded(child: _TabView(PrimaryInvestmentType.Captable)),
            //         const SizedBox(width: 20),
            //         Expanded(child: _TabView(PrimaryInvestmentType.AIF)),
            //       ],
            //     ),
            //   );
            // }),
            const SizedBox(height: 16),
            MainView(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Obx(() {
        return Visibility(
          visible:
              c.alreadyInvested.isFalse && c.investor().isPreIpoKycComplete,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomElevatedButton(
              backgroundColor: AppColors.green(context),
              isLoading: c.investing.value,
              onPressed: () {
                // if (c.type() == PrimaryInvestmentType.Captable) {
                if (c.captablePhoneKey.currentState?.validate() ?? false) {
                  if (c.isSelected.isFalse) {
                    toast('Please approve teams & condition');
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
                //   if (c.aifPhoneKey.currentState?.validate() ?? false) {
                //     if (c.isSelected.isFalse) {
                //       toast('Please approve teams & condition');
                //       return;
                //     }
                //     if (c.paymentMode.value != null &&
                //         c.paymentMode()!.isNotEmpty) {
                //       c.investedAmount(c.enterPrice().aifFinalPrice);
                //       c.gst = c.enterPrice().aifGST;
                //       c.fees = c.enterPrice().aifManagementFees;
                //       c.totalShare.value =
                //           (c.investedAmount() / 1000).formatUnit();
                //       showModalBottomSheet<void>(
                //           context: context,
                //           backgroundColor:
                //               context.theme.scaffoldBackgroundColor,
                //           sheetAnimationStyle: c.animationStyle,
                //           builder: (c) => SummaryWidget());
                //     } else {
                //       toast('Please select payment type');
                //     }
                //   }
                // }
              },
              text: 'Invest',
            ),
          ),
        );
      }),
    );
  }
}

class SummaryWidget extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  SummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(33)),
      height: 320,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.bookmark_outline, size: 23),
                      SizedBox(width: 10),
                      Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Investment amount:',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        c.enterPrice().toCurrency,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Management fees',
                        // 2%
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        c.enterPrice().aifManagementFees.toCurrency,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'GST',
                        // 18 of 2%%
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        c.enterPrice().aifGST.toCurrency,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'No of units',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        "${(c.investedAmount() / 1000).formatUnit()}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        c.investedAmount().toCurrency,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            return CustomElevatedButton(
              backgroundColor: AppColors.green(context),
              isLoading: c.investing.value,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              onPressed: () {
                Get.back();
                c.onPress();
              },
              text: "Proceed",
            );
          }),
        ],
      ),
    );
  }
}

class MainView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!c.investor().isPreIpoKycComplete && c.alreadyInvested.isFalse) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Complete investor KYC before making a transaction.'),
            CompleteInvestorKycButton(
              investor: c.investor(),
              onSaved: () => c.getInvestor(Get.parameters['id'] ?? ''),
            ),
          ],
        );
      }
      if (c.alreadyInvested.isFalse) {
        // switch (c.type()) {
        //   case PrimaryInvestmentType.Captable:
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
            ),
            const SizedBox(height: 28),
            Obx(() {
              return Text(
                c.transaction().nextStep,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              );
            }),
            const SizedBox(height: 40),
            const Center(child: LottieImage(path: AppAssets.sign)),
          ],
        );
      }
    });
  }
}

class CaptableView extends StatelessWidget {
  final PrimaryInvestmentPageCtrl c = Get.find<PrimaryInvestmentPageCtrl>();

  CaptableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            key: c.captablePhoneKey,
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
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
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
                        horizontal: 38,
                        vertical: 10,
                      ),
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
                        horizontal: 38,
                        vertical: 10,
                      ),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 25),
          Obx(() {
            return _DetailWidget(
              title: "Investment amount:",
              data: c.investedAmount().toCurrency,
            );
          }),
          const SizedBox(height: 18),
          Obx(() {
            return _DetailWidget(
              title: "No.  of shares:",
              data: c.totalShare().formattedDecimal,
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
          const SizedBox(height: 32),
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
                type: app.config.enumValues.primaryTransactionPaymentMode.rtgs,
              ),
              const SizedBox(width: 20),
              _TabWidget(
                text: "Cheque",
                type:
                    app.config.enumValues.primaryTransactionPaymentMode.cheque,
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
                    color: context.theme.iconTheme.color ?? Colors.white,
                  ),
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
                    text: 'I have read and agree to the Disclaimer, privacy policy, terms of use, risk disclosure.',
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Investment Agreement',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.to(
                            () => PdfViewerPage(path: AppUrl.itDisclosures),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      );
    });
  }
}

class MoreInfoDialog extends StatelessWidget {
  const MoreInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      height: context.height * 0.7,
      width: context.isPhone ? context.width : 550,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  "AIF vs Captable",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: Get.back,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  // height: 15,
                  // width: 15,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.theme.disabledColor,
                  ),
                  child: const Icon(Icons.close, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Option 1: Direct Cap Table Investment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _DotContainer(),
                      Text(
                        "Description:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Invest directly in the startup and have your name reflected in its cap table.",
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _DotContainer(),
                      Text(
                        "Particulars:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "Full ownership visibility.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "Direct legal rights as a shareholder.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "No additional intermediary fees.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "Involves direct compliance responsibilities like signing NOCs, SHAs, EGM Notices, etc.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Option 2: Investment through AIF",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _DotContainer(),
                      Text(
                        "Description:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Pool your investment with others via an Alternative Investment Fund managed by professionals.",
                    style: TextStyle(
                      color: context.theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _DotContainer(),
                      Text(
                        "Benefits:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "Simplified compliance handled by the AIF.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "No need to directly engage in operational tasks like signing Shareholder Agreements (SHAs), Non-Objection Certificates (NOCs), or responding to Extraordinary General Meeting (EGM) notices.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "Indirect ownership (no direct mention on the startup’s cap table).",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _DotContainer(),
                            Expanded(
                              child: Text(
                                "2% + GST management fees and 2% carry may apply.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context
                                      .theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotContainer extends StatelessWidget {
  const _DotContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.theme.dividerColor,
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
        borderRadius: BorderRadius.circular(12),
        onTap: () => c.paymentMode(type),
        child: Obx(() {
          bool isSelected = c.paymentMode() == type;
          return CustomCardWidget(
            radius: 12,
            padding: const EdgeInsets.symmetric(vertical: 7),
            borderColor: isSelected ? context.theme.iconTheme.color : null,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
