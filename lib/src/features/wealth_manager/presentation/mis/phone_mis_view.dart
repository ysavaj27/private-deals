import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page_ctrl.dart';

class PhoneMisView extends StatelessWidget {
  final MISPageCtrl c = Get.find<MISPageCtrl>();

  PhoneMisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (c.isLoading.isFalse) {
          if (c.list.isNotEmpty) {
            return Obx(() {
              if (c.isLoading.isFalse) {
                if (c.list.isNotEmpty) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: c.list.length,
                    itemBuilder: (context, index) {
                      var model = c.list[index];
                      return ExpansionTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side:
                              BorderSide(color: AppColors.borderColor(context)),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side:
                              BorderSide(color: AppColors.borderColor(context)),
                        ),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(10, 10, 20, 10),
                        textColor: context.textTheme.titleMedium?.color,
                        collapsedTextColor:
                            context.textTheme.titleMedium?.color,
                        iconColor: context.iconColor,
                        collapsedIconColor: context.iconColor,
                        collapsedBackgroundColor:
                            context.theme.scaffoldBackgroundColor,
                        dense: false,
                        tilePadding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                        backgroundColor: context.theme.scaffoldBackgroundColor,
                        visualDensity: VisualDensity.comfortable,
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        leading: LogoImage(
                          url: model.startupLogo,
                          height: 40,
                          width: 40,
                          radius: 6,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                model.startupName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "MIS :  ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context
                                          .theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    "${model.misList.length}",
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        children: model.misList.map((e) {
                          return CustomCardWidget(
                            margin: const EdgeInsets.only(bottom: 10),
                            radius: 6,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.title,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e.description,
                                        maxLines: 3,
                                        style: TextStyle(
                                          color: context.theme.colorScheme
                                              .onSurfaceVariant,
                                          fontSize: 13,
                                          // fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                DownloadButton(
                                  onTap: () {
                                    DownloadFile.downloadFromUrl(
                                        url: e.document, fileName: e.title);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                  );
                } else {
                  return NoDataView(onPressed: c.getData);
                }
              } else {
                return const Loader();
              }
            });
          } else {
            return NoDataView(onPressed: c.getData);
          }
        } else {
          return const Loader();
        }
      }),
    );
  }
}
