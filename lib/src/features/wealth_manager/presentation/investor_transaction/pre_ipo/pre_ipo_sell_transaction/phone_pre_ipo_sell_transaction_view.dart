import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_sell_transaction/pre_ipo_sell_transaction_page_ctrl.dart';

class PhonePreIPOSellTransactionView extends StatelessWidget {
  final PreIPOSellTransactionPageCtrl c =
      Get.put(PreIPOSellTransactionPageCtrl());

  PhonePreIPOSellTransactionView({super.key});

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
                                      model.price.toFormattedPrice,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      splashRadius: 20,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        // color: context.theme.primaryColorLight,
                                      ),
                                      onSelected: (String result) async {
                                        switch (result) {
                                          case 'CMR':
                                            await DownloadFile.downloadFromUrl(
                                              url: model.file,
                                              fileName: 'CMR/CML File',
                                            );
                                            break;
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        var list = <PopupMenuEntry<String>>[];
                                        list.addIf(
                                            model.file.isNotEmpty,
                                            const PopupMenuItem<String>(
                                              value: 'CMR',
                                              child: Text('CMR/CML File'),
                                            ));
                                        return list;
                                      },
                                    ),
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
}
