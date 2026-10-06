import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';

class DesktopKycPendingInvestorView extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.find<KycPendingInvestorPageCtrl>();

  DesktopKycPendingInvestorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("Pending Tasks"),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CustomTabBar(
                  title: "KYC pending",
                  data: "${c.pendingTask().pendingKyc}",
                  type: PendingTaskEnum.kyc,
                ),
                const SizedBox(width: 20),
                // _CustomTabBar(
                //   title: "AIF pending",
                //   data: "${c.pendingTask().pendingAif}",
                //   type: PendingTaskEnum.aif,
                // ),
                const SizedBox(width: 20),
                _CustomTabBar(
                  title: "Document sign",
                  data: "${c.pendingTask().documentSign}",
                  type: PendingTaskEnum.document,
                ),
                const SizedBox(width: 20),
                _CustomTabBar(
                  title: "Fund Transfer",
                  data: "${c.pendingTask().pendingPayment}",
                  type: PendingTaskEnum.fundTransfer,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isFalse) {
                  if (c.type.value == PendingTaskEnum.kyc ||
                      c.type() == PendingTaskEnum.aif) {
                    return PendingKycInvestorWidget();
                  } else {
                    return TransactionListWidget();
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

class TransactionListWidget extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.find<KycPendingInvestorPageCtrl>();

  TransactionListWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: HeadingText("Sr. No."),
                ),
                Expanded(
                  flex: 2,
                  child: HeadingText("Startup"),
                ),
                Expanded(
                  flex: 2,
                  child: HeadingText("Investor"),
                ),
                Expanded(
                  flex: 2,
                  child: HeadingText("Amount"),
                ),
                Expanded(
                  flex: 3,
                  child: HeadingText("Current Status"),
                ),
                Expanded(
                  flex: 3,
                  child: HeadingText("Next Step"),
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
              if (c.transactions.isNotEmpty) {
                return ListView.builder(
                  itemCount: c.transactions.length,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  itemBuilder: (context, index) {
                    var model = c.transactions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
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
                            child: Text(
                              model.startup.brandName,
                              style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              model.investor.name,
                              style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              model.investmentAmount.toFormattedPrice,
                              style: const TextStyle(),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              model.currentStatus,
                              style: TextStyle(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                                // color: model.statusReturnOfInvest,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              model.nextStep,
                              style: TextStyle(
                                  color: context
                                      .theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const NoDataView();
              }
            }),
          ),
        ],
      ),
    );
  }
}

class PendingKycInvestorWidget extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.find<KycPendingInvestorPageCtrl>();

  PendingKycInvestorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (c.investorList.isNotEmpty) {
      return ListView.builder(
        itemCount: c.investorList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          var model = c.investorList[index];
          return CustomCardWidget(
            margin: const EdgeInsets.only(bottom: 20),
            radius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoImage(
                      height: 100,
                      width: 100,
                      radius: 8,
                      url: model.profile,
                      placeHolderImage: model.placeholderImage,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 20),
                    const Spacer(),
                    Visibility(
                      visible: c.type() == PendingTaskEnum.kyc,
                      child: CustomElevatedButton(
                        padding: EdgeInsets.zero,
                        text: 'Complete KYC',
                        width: 161,
                        height: 48,
                        radius: 9,
                        onPressed: () async {
                          var res = await Get.toNamed(
                              Routes.kycPath(Get.currentRoute, model.uuid));
                          if (res == true) {
                            c.getPendingKycInvestor();
                          }
                        },
                      ),
                    ),
                    // Visibility(
                    //   visible: c.type() == PendingTaskEnum.aif,
                    //   child: CustomElevatedButton(
                    //     padding: EdgeInsets.zero,
                    //     text: 'Complete AIF',
                    //     width: 161,
                    //     height: 48,
                    //     radius: 9,
                    //     onPressed: () async {
                    //       var res= await Get.to(() =>AifOnboardingPage(),arguments: model);
                    //       if (res == true) {
                    //         c.getPendingKycInvestor();
                    //       }
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name : ",
                            style: TextStyle(
                                fontSize: 16,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Type : ",
                            style: TextStyle(
                                fontSize: 16,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.investorType.isEmpty
                                ? '—'
                                : model.investorType,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mobile : ",
                            style: TextStyle(
                                fontSize: 16,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${model.mobileNumber}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Email :",
                            style: TextStyle(
                                fontSize: 16,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.email,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return const NoDataView();
    }
  }
}

class _CustomTabBar extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.find<KycPendingInvestorPageCtrl>();
  final String title;
  final String data;
  final PendingTaskEnum type;

  _CustomTabBar({
    required this.title,
    required this.data,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          c.type(type);
          switch (c.type()) {
            case PendingTaskEnum.kyc:
              c.getPendingKycInvestor();
              break;
            case PendingTaskEnum.document:
              c.getTransactions(pendingDocSign: true);
              break;
            case PendingTaskEnum.fundTransfer:
              c.getTransactions(pendingPayment: true);
              break;
            case PendingTaskEnum.aif:
              c.getPendingKycInvestor(type: PendingTaskEnum.aif);
              break;
          }
        },
        child: Obx(() {
          bool isSelected = c.type.value == type;
          return CustomCardWidget(
            padding: const EdgeInsets.symmetric(vertical: 40),
            borderColor: isSelected
                ? context.theme.iconTheme.color
                : AppColors.borderColor(context),
            borderWidth: isSelected ? 1.5 : 1,
            child: Column(
              children: [
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.theme.disabledColor,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
