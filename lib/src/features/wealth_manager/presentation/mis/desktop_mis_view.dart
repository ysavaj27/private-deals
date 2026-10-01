import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/mis/mis_page_ctrl.dart';

class DesktopMisView extends StatelessWidget {
  final MISPageCtrl c = Get.find<MISPageCtrl>();

  DesktopMisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("MIS"),
            const SizedBox(height: 18),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Obx(() {
                  if (c.isLoading.isFalse) {
                    if (c.list.isNotEmpty) {
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 40),
                        physics: const BouncingScrollPhysics(),
                        itemCount: c.list.length,
                        itemBuilder: (context, index) {
                          var model = c.list[index];
                          return ExpansionTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: AppColors.borderColor(context)),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: AppColors.borderColor(context)),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(20, 20, 40, 20),
                            textColor: context.textTheme.titleMedium?.color,
                            collapsedTextColor:
                                context.textTheme.titleMedium?.color,
                            iconColor: context.iconColor,
                            collapsedIconColor: context.iconColor,
                            collapsedBackgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            dense: false,
                            tilePadding:
                                const EdgeInsets.fromLTRB(20, 20, 40, 20),
                            backgroundColor:
                                context.theme.scaffoldBackgroundColor,
                            visualDensity: VisualDensity.comfortable,
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            leading: LogoImage(
                              url: model.startupLogo,
                              height: 50,
                              width: 50,
                              radius: 6,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    model.startupName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "MIS :  ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: context.theme.disabledColor,
                                        ),
                                      ),
                                      Text(
                                        "${model.misList.length}",
                                      ),
                                      // SizedBox(width: 40),
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
                                    horizontal: 30, vertical: 24),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.title,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            e.description,
                                            style: TextStyle(
                                                color: context.theme.colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DownloadButton(
                                      onTap: () async {
                                        logger.d(
                                            'Download From URL :${e.document}');
                                        DownloadFile.downloadFromUrl(
                                            url: e.document, fileName: e.title);
                                      },
                                      size: 32,
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
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
