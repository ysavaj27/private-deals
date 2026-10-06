import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_progressbar.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';

class PhoneKycPendingInvestorView extends StatelessWidget {
  final KycPendingInvestorPageCtrl c = Get.find<KycPendingInvestorPageCtrl>();

  PhoneKycPendingInvestorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    return _CustomTabBar(
                      title: "KYC pending",
                      data: "${c.pendingTask().pendingKyc}",
                      type: PendingTaskEnum.kyc,
                    );
                  }),
                  const SizedBox(width: 12),
                  Obx(() {
                    return _CustomTabBar(
                      title: "Document sign",
                      data: "${c.pendingTask().documentSign}",
                      type: PendingTaskEnum.document,
                    );
                  }),
                  const SizedBox(width: 12),
                  Obx(() {
                    return _CustomTabBar(
                      title: "Fund Transfer",
                      data: "${c.pendingTask().pendingPayment}",
                      type: PendingTaskEnum.fundTransfer,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
    return Obx(() {
      if (c.transactions.isNotEmpty) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: c.transactions.length,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          itemBuilder: (context, index) {
            var model = c.transactions[index];
            return FadeInUp(
              child: CustomCardWidget(
                radius: 8,
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        LogoImage(
                          radius: 4,
                          url: model.startup.cms.logo,
                          height: 38,
                          width: 38,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Kedar Dave",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(model.startup.brandName),
                            ],
                          ),
                        ),
                        Text(
                          model.investmentAmount.toFormattedPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            splashRadius: 20,
                            icon: Icon(
                              Icons.more_vert,
                              color: context.theme.primaryColor,
                              size: 20,
                              // color: context.theme.primaryColorLight,
                            ),
                            onSelected: (String result) async {
                              switch (result) {
                                case 'SSA':
                                  await DownloadFile.downloadFromUrl(
                                    url: model.ssaDocument.signedPath,
                                    fileName: model.ssaDocument.meta.name,
                                  );
                                  break;
                                case 'Offer':
                                  await DownloadFile.downloadFromUrl(
                                    url: model.offerDocument.signedPath,
                                    fileName: model.offerDocument.meta.name,
                                  );
                                  break;
                                case 'SHA':
                                  await DownloadFile.downloadFromUrl(
                                    url: model.shaDocument.signedPath,
                                    fileName: model.shaDocument.meta.name,
                                  );
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              var list = <PopupMenuEntry<String>>[];
                              list.addIf(
                                  model.ssaDocument.signedPath.isNotEmpty,
                                  const PopupMenuItem<String>(
                                    value: 'SSA',
                                    child: Text('SSA'),
                                  ));
                              list.addIf(
                                  model.offerDocument.signedPath.isNotEmpty,
                                  const PopupMenuItem<String>(
                                    value: 'Offer',
                                    child: Text('Offer'),
                                  ));

                              list.addIf(
                                  model.shaDocument.signedPath.isNotEmpty,
                                  const PopupMenuItem<String>(
                                    value: 'SHA',
                                    child: Text('SHA'),
                                  ));
                              return list;
                            }),
                      ],
                    ),
                    const SizedBox(height: 21),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomCardWidget(
                              radius: 16,
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      SVGImage(
                                        AppAssets.currentStatusIc,
                                        width: 14,
                                        height: 14,
                                      ),
                                      SizedBox(width: 11),
                                      Text("Current Status"),
                                    ],
                                  ),
                                  const SizedBox(height: 17),
                                  Text(
                                    model.currentStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.theme.disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomCardWidget(
                              radius: 16,
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      SVGImage(
                                        AppAssets.nextStatusIc,
                                        width: 14,
                                        height: 14,
                                      ),
                                      SizedBox(width: 11),
                                      Text("Next Step"),
                                    ],
                                  ),
                                  const SizedBox(height: 17),
                                  Text(
                                    model.nextStep,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.theme.disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomCardWidget(
                      margin: EdgeInsets.zero,
                      radius: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SVGImage(
                                AppAssets.progressIc,
                                width: 14,
                                height: 14,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Progress",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 23),
                          Text.rich(
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                            TextSpan(
                              children: [
                                TextSpan(text: '${model.percentage}%   '),
                                const TextSpan(
                                  text: 'Completed',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          CustomProgressBar(progress: model.percentage / 100),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        return const NoDataView();
      }
    });
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
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (context, index) {
          var model = c.investorList[index];
          return CustomCardWidget(
            radius: 12,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoImage(
                      height: 65,
                      width: 65,
                      radius: 8,
                      url: model.profile,
                      placeHolderImage: model.placeholderImage,
                      // height: 97,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 20),
                    const Spacer(),
                    Visibility(
                      visible: c.type() == PendingTaskEnum.kyc,
                      child: CustomElevatedButton(
                        padding: EdgeInsets.zero,
                        text: 'Complete KYC',
                        width: 120,
                        height: 40,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        radius: 4,
                        onPressed: () async {
                          await Get.toNamed(
                              Routes.kycPath(Get.currentRoute, model.uuid));
                          c.getData();
                        },
                      ),
                    ),
                    // Visibility(
                    //   visible: c.type() == PendingTaskEnum.aif,
                    //   child: CustomElevatedButton(
                    //     padding: EdgeInsets.zero,
                    //     text: 'Complete AIF',
                    //     width: 120,
                    //     height: 40,
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w500,
                    //     radius: 4,
                    //     onPressed: () async {
                    //       await Get.to(() => AifOnboardingPage(),
                    //           arguments: model);
                    //       c.getData();
                    //     },
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name : ",
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Type : ",
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.investorType.isEmpty
                                ? '—'
                                : model.investorType,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Mobile : ",
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${model.mobileNumber}",
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Email :",
                            style: TextStyle(
                                fontSize: 12,
                                color: context.theme.disabledColor
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            model.email,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                  textAlign: TextAlign.center,
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
