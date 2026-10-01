import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';

class DesktopPreIPOBuyTransactionView extends StatelessWidget {
  final PreIPOBuyTransactionPageCtrl c =
      Get.put(PreIPOBuyTransactionPageCtrl());

  DesktopPreIPOBuyTransactionView({super.key});

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
                              flex: 2,
                              child: HeadingText("Company"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Name"),
                            ),
                            Expanded(
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
                            Expanded(
                                child: Center(child: HeadingText("Action"))),
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
                                            child: Text(
                                              model.investor.name,
                                              // "${index + 1}",
                                              style: const TextStyle(),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                model.investmentAmount
                                                    .toFormattedPrice,
                                                style: const TextStyle(),
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
                                          Expanded(
                                            child: Center(
                                              child: _buildActionColumn(
                                                  context, model),
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

  TransactionStatusModel? _getNextStepStatus(
      PreIPOTransactionModel model) {
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
                horizontal: 10,
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
