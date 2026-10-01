import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page_ctrl.dart';

class PhoneSendDocumentView extends StatelessWidget {
  final SendDocumentPageCtrl c = Get.find<SendDocumentPageCtrl>();

  PhoneSendDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            CustomCardWidget(
              radius: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CustomTextField(
                  radius: 20,
                  isBorder: false,
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 14),
                  hintText: "Search Startups",
                  prefixIcon: const Icon(Icons.search, size: 25),
                  onChanged: (p0) => c.search(p0),
                ),
              ),
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
                          RxBool isSending = false.obs;
                          return FadeInUp(
                            child: CustomCardWidget(
                              radius: 8,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CacheImage(
                                        url: model.investor.profile,
                                        placeHolderImage:
                                            model.investor.placeholderImage,
                                        height: 64,
                                        width: 64,
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.investor.name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Text(
                                      //   model.investmentAmount.toFormattedPrice,
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontWeight: FontWeight.w500,
                                      //   ),
                                      // ),
                                      Obx(() {
                                        return PopupMenuButton<String>(
                                            splashRadius: 20,
                                            icon: isSending.isFalse
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 4, 2, 4),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 2,
                                                            color: context.theme
                                                                .primaryColor),
                                                        shape: BoxShape.circle),
                                                    child: Icon(
                                                      Icons.send,
                                                      color: context
                                                          .theme.primaryColor,
                                                      size: 20,
                                                      // color: context.theme.primaryColorLight,
                                                    ),
                                                  )
                                                : SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 0.8,
                                                    ),
                                                  ),
                                            onSelected: (String result) async {
                                              isSending(true);

                                              switch (result) {
                                                case 'SSA':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.ssa);
                                                  break;
                                                case 'MGT14 Challan':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app
                                                          .config
                                                          .enumValues
                                                          .documentType
                                                          .mgtchallan);
                                                  break;
                                                case 'MGT14 ZIP':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.mgtzip);
                                                case 'Offer':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.offer);
                                                  break;
                                                case 'Counter Slip':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.sha);
                                                  break;
                                                case 'Rtgs Receipt':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.pas);
                                                  break;
                                                case 'SHA':
                                                  await c.sendDocument(
                                                      model.id,
                                                      app.config.enumValues
                                                          .documentType.pas);
                                                  break;
                                              }
                                              isSending(false);
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                              List<PopupMenuItem<String>> list =
                                                  [];
                                              list.addIf(
                                                model.ssaDocument.id.isNotEmpty,
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
                                                  child: Text('MGT14 Challan'),
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
                                                  child: Text('Offer Letter'),
                                                ),
                                              );
                                              list.addIf(
                                                model.counterSlip.id.isNotEmpty,
                                                const PopupMenuItem<String>(
                                                  value: 'Counter Slip',
                                                  child: Text('Counter Slip'),
                                                ),
                                              );
                                              list.addIf(
                                                model.rtgsReceipt.id.isNotEmpty,
                                                const PopupMenuItem<String>(
                                                  value: 'Rtgs Receipt',
                                                  child: Text('Rtgs Receipt'),
                                                ),
                                              );
                                              list.addIf(
                                                model.shaDocument.id.isNotEmpty,
                                                const PopupMenuItem<String>(
                                                  value: 'SHA',
                                                  child: Text('SHA'),
                                                ),
                                              );
                                              return list;
                                            });
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 17),
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _InfoCard(
                                            title: 'Startup',
                                            data: model.startup.brandName,
                                            image: AppAssets.rocketIc,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Expanded(
                                        //   child: _InfoCard(
                                        //     title: 'Investor',
                                        //     data: 'Kedar Dave',
                                        //     image: AppAssets.userIc3,
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 6),
                                        Expanded(
                                          child: _InfoCard(
                                            title: 'Amount',
                                            data: model.investmentAmount
                                                .toFormattedPrice,
                                            image: AppAssets.amountIc,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String data;
  final String image;

  const _InfoCard({
    required this.title,
    required this.data,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      radius: 8,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SVGImage(
            image,
            width: 22,
            height: 22,
          ),
          const SizedBox(height: 19),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: FittedBox(child: Text(title)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: FittedBox(
              child: Text(
                data,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
