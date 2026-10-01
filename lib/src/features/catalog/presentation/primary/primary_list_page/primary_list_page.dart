import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page_ctrl.dart';

class PrimaryListPage extends StatelessWidget {
  final PrimaryListPageCtrl c = Get.put(PrimaryListPageCtrl());

  PrimaryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            if (c.isLoading.isFalse) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: context.height * 0.2,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Obx(() {
                            if (c.list.isNotEmpty) {
                              return PageView.builder(
                                physics: const BouncingScrollPhysics(),
                                controller: c.pageController,
                                itemCount: c.list.length,
                                itemBuilder: (context, index) {
                                  var model = c.list[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (model.type ==
                                          StartupStatusEnum.comingsoon) {
                                        showCustomDialog(
                                          VideoPlayerScreen(
                                              url:
                                                  model.startup.cms.pitchVideo),
                                        );
                                      } else {
                                        var route = Routes.primaryDetailPath(
                                            "/wealth-manager/${WTabBarEnum.primary.slug}",
                                            model.startup.urlSlug);
                                        Get.toNamed(route);
                                      }
                                    },
                                    child: CacheImage(
                                      url: context.isPhone
                                          ? model.startup.cms.banner
                                          : model.startup.cms.longBanner,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return SizedBox(
                                height: 120,
                                width: context.width,
                              );
                            }
                          }),
                          Obx(() {
                            return Visibility(
                              visible: c.list.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SmoothPageIndicator(
                                  controller: c.pageController,
                                  count: c.list.length,
                                  effect: WormEffect(
                                    dotHeight: 10,
                                    dotWidth: 10,
                                    activeDotColor: context.theme.primaryColor,
                                    dotColor: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                            );
                          }),
                          Positioned(
                            top: 20,
                            left: 20,
                            child: Clickable(
                              borderRadius: BorderRadius.circular(20),
                              onTap: onBackPressed,
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.theme.disabledColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Obx(() {
                      if (c.list.isNotEmpty) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 250,
                            mainAxisSpacing: context.isPhone ? 16 : 32,
                            crossAxisSpacing: context.isPhone ? 9 : 30,
                            childAspectRatio: context.isPhone ? 0.83 : 0.79,
                          ),
                          itemCount: c.list.length,
                          itemBuilder: (context, index) {
                            var model = c.list[index];
                            // logger.d('Fav :${model.startup.isFavorite}');
                            model.startup.isLike.value =
                                model.startup.isFavorite;
                            return InkWell(
                              onTap: () {
                                var route = Routes.primaryDetailPath(
                                    "/wealth-manager/${WTabBarEnum.primary.slug}",
                                    model.startup.urlSlug);
                                Get.toNamed(route);
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(14)),
                              child: CustomCardWidget(
                                radius: 14,
                                margin: EdgeInsets.zero,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(14)),
                                      child: CacheImage(
                                        url: model.startup.cms.banner,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  model.startup.brandName,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: context.isPhone
                                                        ? 14
                                                        : 16,
                                                  ),
                                                ),
                                                CustomLikeButton(
                                                  isLike: model.startup.isLike,
                                                  // isLike: true.obs,
                                                  id: model.id,
                                                  onSuccess: c.getData,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            // Expanded(
                                            //   child: Row(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment
                                            //             .spaceBetween,
                                            //     crossAxisAlignment:
                                            //         CrossAxisAlignment.center,
                                            //     children: [
                                            //       Expanded(
                                            //         child: Column(
                                            //           mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .center,
                                            //           children: [
                                            //             const FittedBox(
                                            //               fit: BoxFit.scaleDown,
                                            //               child: Text(
                                            //                 "Investors",
                                            //                 style: TextStyle(
                                            //                     fontSize: 12),
                                            //               ),
                                            //             ),
                                            //             const SizedBox(height: 3),
                                            //             Text(
                                            //               // "${model.investor}",
                                            //               "",
                                            //               style: const TextStyle(
                                            //                 fontSize: 12,
                                            //                 fontWeight:
                                            //                     FontWeight.w600,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         child: Column(
                                            //           mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .center,
                                            //           children: [
                                            //             const FittedBox(
                                            //               fit: BoxFit.scaleDown,
                                            //               child: Text(
                                            //                 "Round size",
                                            //                 style: TextStyle(
                                            //                     fontSize: 12),
                                            //               ),
                                            //             ),
                                            //             const SizedBox(height: 3),
                                            //             Text(
                                            //               // "${model.ask.toFormattedPrice}",
                                            //               "",
                                            //               style: const TextStyle(
                                            //                 fontSize: 12,
                                            //                 fontWeight:
                                            //                     FontWeight.w600,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       Expanded(
                                            //         child: Column(
                                            //           mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .center,
                                            //           children: [
                                            //             const FittedBox(
                                            //               fit: BoxFit.scaleDown,
                                            //               child: Text(
                                            //                 "Valuation",
                                            //                 style: TextStyle(
                                            //                     fontSize: 12),
                                            //               ),
                                            //             ),
                                            //             const SizedBox(height: 3),
                                            //             Text(
                                            //               // "${model.newValuation.toFormattedPrice}",
                                            //               "",
                                            //               style: const TextStyle(
                                            //                 fontSize: 12,
                                            //                 fontWeight:
                                            //                     FontWeight.w600,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    CustomCardWidget(
                                      height: 40,
                                      margin: EdgeInsets.zero,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 12),
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(0),
                                          bottom: Radius.circular(14)),
                                      radius: 14,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          const Icon(Icons.smart_display,
                                              size: 17),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              model.startup.sector.name,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SVGImage(
                                            AppAssets.indiaIc,
                                            height: 17,
                                            width: 17,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              model.startup.city.name,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
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
                        return const NoDataView(isRefreshButton: false);
                      }
                    }),
                  ],
                ),
              );
            } else {
              return const Loader();
            }
          }),
        ),
      ),
    );
  }
}
