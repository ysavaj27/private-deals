import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page_ctrl.dart';

class DesktopSendDocumentView extends StatelessWidget {
  final SendDocumentPageCtrl c = Get.find<SendDocumentPageCtrl>();

  DesktopSendDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("Send Documents"),
            const SizedBox(height: 18),
            SearchBarTextField(
              onChanged: (p0) => c.search(p0),
              hintText: 'Search startup/investors',
            ),
            const SizedBox(height: 18),
            Expanded(
              child: CustomCardWidget(
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
                            child: HeadingText("Starup"),
                          ),
                          Expanded(
                            flex: 2,
                            child: HeadingText("Investor"),
                          ),
                          Expanded(
                            flex: 2,
                            child: HeadingText("Amount"),
                          ),
                          Expanded(child: Center(child: HeadingText("Action"))),
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
                              itemCount: c.finalList.length,
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              itemBuilder: (context, index) {
                                var model = c.finalList[index];
                                RxBool isSending = false.obs;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
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
                                          children: [
                                            // CacheImage(
                                            //   url: model.startupLogo,
                                            //   height: 45,
                                            //   width: 45,
                                            // ),
                                            // const SizedBox(width: 20),
                                            Text(
                                              model.startup.brandName,
                                              style: TextStyle(
                                                  color: context
                                                      .theme.disabledColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          model.investor.name,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          model.investmentAmount
                                              .toFormattedPrice,
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Obx(() {
                                            return PopupMenuButton<String>(
                                                splashRadius: 20,
                                                icon: isSending.isFalse
                                                    ? SVGImage(
                                                        AppAssets.downloadIc,
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                                context.theme
                                                                    .primaryColor,
                                                                BlendMode
                                                                    .srcIn),
                                                        height: 18,
                                                        width: 18,
                                                      )
                                                    : SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 0.8,
                                                        ),
                                                      ),
                                                onSelected:
                                                    (String result) async {
                                                  isSending(true);

                                                  switch (result) {
                                                    case 'SSA':
                                                      await c.sendDocument(
                                                          model.ssaDocument.id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .ssa);
                                                      break;
                                                    case 'MGT14 Challan':
                                                      await c.sendDocument(
                                                          model
                                                              .mgtChallanDocument
                                                              .id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .mgtchallan);
                                                      break;
                                                    case 'MGT14 ZIP':
                                                      await c.sendDocument(
                                                          model.mgtZipDocument
                                                              .id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .mgtzip);
                                                    case 'Offer':
                                                      await c.sendDocument(
                                                          model
                                                              .offerDocument.id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .offer);
                                                      break;
                                                    case 'Counter Slip':
                                                      await c.sendDocument(
                                                          model.counterSlip.id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .sha);
                                                      break;
                                                    case 'Rtgs Receipt':
                                                      await c.sendDocument(
                                                          model.rtgsReceipt.id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .pas);
                                                      break;
                                                    case 'SHA':
                                                      await c.sendDocument(
                                                          model.shaDocument.id,
                                                          app
                                                              .config
                                                              .enumValues
                                                              .documentType
                                                              .pas);
                                                      break;
                                                  }
                                                  isSending(false);
                                                },
                                                itemBuilder:
                                                    (BuildContext context) {
                                                  List<PopupMenuItem<String>>
                                                      list = [];
                                                  list.addIf(
                                                    model.ssaDocument.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'SSA',
                                                      child: Text('SSA'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.mgtChallanDocument.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'MGT14 Challan',
                                                      child:
                                                          Text('MGT14 Challan'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.mgtZipDocument.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'MGT14 ZIP',
                                                      child: Text('MGT14 ZIP'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.offerDocument.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'Offer',
                                                      child:
                                                          Text('Offer Letter'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.counterSlip.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'Counter Slip',
                                                      child:
                                                          Text('Counter Slip'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.rtgsReceipt.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'Rtgs Receipt',
                                                      child:
                                                          Text('Rtgs Receipt'),
                                                    ),
                                                  );
                                                  list.addIf(
                                                    model.shaDocument.id
                                                        .isNotEmpty,
                                                    const PopupMenuItem<String>(
                                                      value: 'SHA',
                                                      child: Text('SHA'),
                                                    ),
                                                  );
                                                  return list;
                                                });
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
