import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';

class PhonePreIPOBuyTransactionView extends StatelessWidget {
  final PreIPOBuyTransactionPageCtrl c =
      Get.put(PreIPOBuyTransactionPageCtrl());

  PhonePreIPOBuyTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          SearchBarTextField(
            hintText: "Search Company",
            onChanged: (p0) => c.search(p0),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              if (c.isLoading.isFalse) {
                if (c.finalList.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: c.getData,
                    child: ListView.builder(
                      itemCount: c.finalList.length,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      itemBuilder: (context, index) {
                        var model = c.finalList[index];
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
                                    ClipOval(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: context
                                              .textTheme.titleMedium?.color,
                                        ),
                                        child: CacheImage(
                                          url: model.company.logo,
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        model.company.brandName,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      model.investmentAmount.toFormattedPrice,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    _buildActionColumn(context, model)
                                  ],
                                ),
                                const SizedBox(height: 23),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomCardWidget(
                                          isBorder: false,
                                          radius: 6,
                                          margin: EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 17, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Current Status",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 13),
                                              Text(
                                                model.currentStatus,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: context
                                                      .theme.disabledColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: CustomCardWidget(
                                          isBorder: false,
                                          radius: 6,
                                          margin: EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 17, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Next Step",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 13),
                                              Text(
                                                model.nextStep,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: context
                                                      .theme.disabledColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
/*
                                CustomCardWidget(
                                  margin: EdgeInsets.zero,
                                  isBorder: false,
                                  radius: 6,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Progress",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(height: 13),
                                      Text.rich(
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                                text: '${model.percentage}%'),
                                            TextSpan(
                                              text: 'Completed',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      CustomProgressBar(
                                          progress: model.percentage / 100),
                                      SizedBox(height: 4),
                                    ],
                                  ),
                                ),
*/
                              ],
                            ),
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
  }

  TransactionStatusModel? _getNextStepStatus(PreIPOTransactionModel model) {
    final activeIndex = model.statusList.indexWhere((s) => s.isActive);
    if (activeIndex == -1) return null;
    final nextIndex = activeIndex + 1;
    if (nextIndex >= model.statusList.length) return null;
    return model.statusList[nextIndex];
  }

  List<TransactionStatusModel> _getStatusesWithDocuments(
      PreIPOTransactionModel model) {
    return model.statusList.where((s) => s.document.id.isNotEmpty).toList();
  }

  Widget _buildActionColumn(
      BuildContext context, PreIPOTransactionModel model) {
    final nextStepStatus = _getNextStepStatus(model);
    final hasAction =
        nextStepStatus != null && nextStepStatus.action.type.isNotEmpty;
    final documentsWithFiles = _getStatusesWithDocuments(model);
    final hasDocuments = documentsWithFiles.isNotEmpty;

    if (!hasAction && !hasDocuments) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasAction)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 12,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              minimumSize: Size.zero,
            ),
            onPressed: () => _onActionPress(model, nextStepStatus.action),
            child: Text(
              nextStepStatus.action.btnName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        if (hasAction && hasDocuments) const SizedBox(width: 8),
        if (hasDocuments)
          PopupMenuButton<DocumentModel>(
            tooltip: 'Download documents',
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (context) {
              return documentsWithFiles.map((status) {
                return PopupMenuItem<DocumentModel>(
                  value: status.document,
                  child: Text(
                    status.document.meta.name,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList();
            },
            onSelected: (document) => _downloadDocument(document),
            child: const DownloadButton(),
          ),
      ],
    );
  }

  Future<void> _onActionPress(
    PreIPOTransactionModel model,
    ActionData action,
  ) async {
    logger.d(model.id);
    switch (action.type) {
      case 'dealslip':
        await Launcher.openNewTab(action.url);
        c.getData();
        break;
      case 'kyc':
        await Get.toNamed(
            Routes.kycPath(Get.currentRoute, model.investorId.toString()));
        c.getData();
        break;
      case 'receipt':
        // var res = await showCustomBottomSheet(
        //   widget: ReceiptUploadView(
        //     model: model,
        //     bankDetail: action.details,
        //   ),
        //   title: ' ',
        // );
        // Get.delete<ReceiptUploadViewCtrl>();
        // if (res == true) {
        //   c.getData();
        //   c.refreshList();
        // }
        break;
    }
  }

  Future<void> _downloadDocument(DocumentModel document) async {
    await DownloadFile.downloadFromUrl(
      url: document.signedPath,
      fileName: document.meta.name,
    );
  }
}
