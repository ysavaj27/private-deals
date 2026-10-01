import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';

class DesktopPrimaryLandingView extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  DesktopPrimaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: c.scaffoldKey,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      // endDrawer: const NotificationDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body:           SingleChildScrollView(
        controller: c.scrollController,
        // physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Stack(
            //   alignment: Alignment.centerRight,
            //   children: [
            //     SizedBox(
            //       height: context.height * 0.8,
            //       child: SVGImage(
            //         context.isDarkMode
            //             ? AppAssets.darkLandingPageBgImage
            //             : AppAssets.lightLandingPageBgImage,
            //         // fit: BoxFit.fill,
            //       ),
            //     ),
            //     Row(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Expanded(
            //           child: Padding(
            //             padding: EdgeInsets.fromLTRB(
            //                 50, 50, context.width * 0.07, 0),
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text.rich(
            //                   TextSpan(
            //                     style: const TextStyle(fontSize: 87),
            //                     children: [
            //                       const TextSpan(
            //                         text: 'Providing A \n',
            //                         style: TextStyle(
            //                             fontWeight: FontWeight.bold),
            //                       ),
            //                       const TextSpan(text: 'Better way to \n'),
            //                       TextSpan(
            //                           text: 'Invest',
            //                           style: TextStyle(
            //                             decorationThickness: 2.5,
            //                             decorationColor: context
            //                                 .theme.primaryColor
            //                                 .withValues(alpha: 0.7),
            //                           )),
            //                     ],
            //                   ),
            //                   textAlign: TextAlign.center,
            //                 ),
            //                 const SizedBox(height: 25),
            //                 Text(
            //                   "Investing in start-ups is now at your fingertips. You can meet, greet, invest, exit and stay connected with start-ups on the same platform.",
            //                   maxLines: 6,
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     fontSize: 15,
            //                     color: context.theme.disabledColor
            //                         .withValues(alpha: 0.5),
            //                   ),
            //                 ),
            //                 // const SizedBox(height: 50),
            //                 // Row(
            //                 //   children: [
            //                 //     CustomElevatedButton(
            //                 //       width: 200,
            //                 //       height: 56,
            //                 //       radius: 22,
            //                 //       text: 'Get Started Now',
            //                 //       onPressed: () {
            //                 //         Scrollable.ensureVisible(
            //                 //             c.liveDeal.currentContext!);
            //                 //       },
            //                 //     ),
            //                 //     // const SizedBox(width: 25),
            //                 //     // Expanded(
            //                 //     //   child: TextButton(
            //                 //     //     onPressed: () {
            //                 //     //       toast("Coming soon");
            //                 //     //       // showCustomDialog(
            //                 //     //       //   const VideoPlayerScreen(
            //                 //     //       //       url:
            //                 //     //       //           "https://www.shuruup.com/web/intro-video.mp4"),
            //                 //     //       // );
            //                 //     //     },
            //                 //     //     child: Row(
            //                 //     //       children: [
            //                 //     //         Container(
            //                 //     //           margin: const EdgeInsets.all(4),
            //                 //     //           height: 38,
            //                 //     //           width: 38,
            //                 //     //           decoration: BoxDecoration(
            //                 //     //               color: context
            //                 //     //                   .theme.primaryColor,
            //                 //     //               shape: BoxShape.circle),
            //                 //     //           child: Icon(
            //                 //     //             Icons.play_arrow,
            //                 //     //             color: context.theme
            //                 //     //                 .scaffoldBackgroundColor,
            //                 //     //           ),
            //                 //     //         ),
            //                 //     //         const SizedBox(width: 8),
            //                 //     //         const Text(
            //                 //     //           "Tour Video",
            //                 //     //           style: TextStyle(
            //                 //     //             fontSize: 18,
            //                 //     //             fontWeight: FontWeight.w500,
            //                 //     //           ),
            //                 //     //         ),
            //                 //     //       ],
            //                 //     //     ),
            //                 //     //   ),
            //                 //     // ),
            //                 //   ],
            //                 // ),
            //               ],
            //             ),
            //           ),
            //         ),
            //         const Expanded(child: SizedBox()),
            //       ],
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 20),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     AchievementWidget(
            //       image: AppAssets.investmentIc,
            //       title: '₹12.94Cr',
            //       subTitle: 'Total Investments',
            //     ),
            //     AchievementWidget(
            //       image: AppAssets.fundDealsIc,
            //       title: '10',
            //       subTitle: 'Total Funded deals',
            //     ),
            //     AchievementWidget(
            //       image: AppAssets.dealsIc,
            //       title: '40',
            //       subTitle: 'Completed Deals Secondary market',
            //     ),
            //     AchievementWidget(
            //       image: AppAssets.opportunitiesIc,
            //       title: '4',
            //       subTitle: 'Current opportunities',
            //     ),
            //   ],
            // ),
            const SizedBox(height: 40),
            LiveDealWidget(),
            const SizedBox(height: 90),
            Visibility(
              visible: c.model().comingSoon.isNotEmpty,
              child: ComingSoonWidget(),
            ),
            Visibility(
              visible: c.model().comingSoon.isNotEmpty,
              child: const SizedBox(height: 90),
            ),
            CompletedWidget(),
            const SizedBox(height: 90),
            FeaturedWidget(),
            const SizedBox(height: 90),
            BlogWidget(),
            const SizedBox(height: 40),
          ],
        ),
      ),

    );
  }
}

class FeaturedWidget extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  FeaturedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
            children: [
              const TextSpan(
                text: 'Featured ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: 'Sectors',
                  style: TextStyle(
                    decorationThickness: 2.5,
                    decorationColor:
                        context.theme.primaryColor.withValues(alpha: 0.7),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 70),
        Obx(() {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: c.sectors.length,
              itemBuilder: (context, index) {
                var model = c.sectors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Clickable(
                    onTap: () {
                      Get.toNamed(
                        Routes.primaryListPath(Get.currentRoute, model.slug),
                      );

                      // Get.toNamed(Routes.startUpList, arguments: model.id);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: CustomCardWidget(
                      radius: 15,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: 250,
                        height: 192,
                        child: Column(
                          children: [
                            Expanded(
                              child: CacheImage(
                                url: model.iconImage,
                                // color: context.textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              model.name.toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class BlogWidget extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  BlogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.width,
          margin: EdgeInsets.only(right: context.width * 0.1),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? const Color(0xff0C0C0C)
                : context.theme.primaryColor.withValues(alpha: 0.08),
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(400)),
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(400)),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.blogController.animateTo(
                              c.blogController.offset - 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.blogController.animateTo(
                              c.blogController.offset + 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                            children: [
                              // const TextSpan(
                              //   text: 'Completed ',
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                              TextSpan(
                                  text: 'Blog',
                                  style: TextStyle(
                                    decorationThickness: 2.5,
                                    decorationColor: context.theme.primaryColor
                                        .withValues(alpha: 0.7),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 85)
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 400,
                  child: Obx(() {
                    return ListView.separated(
                      controller: c.blogController,
                      padding: EdgeInsets.only(
                          left: context.width * 0.0276,
                          right: context.width * 0.1),
                      itemCount: c.blogs.length,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var model = c.blogs[index];
                        return SizedBox(
                          width: 300,
                          height: 425,
                          child: Clickable(
                            // splashColor: Colors.transparent,
                            // hoverColor: Colors.transparent,
                            // highlightColor: Colors.transparent,
                            // borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Get.toNamed(
                                Routes.blogDetailPath(
                                    Get.currentRoute, model.urlSlug),
                              );
                            },
                            child: CustomCardWidget(
                              color: context.theme.scaffoldBackgroundColor,
                              radius: 14,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14)),
                                    child: CacheImage(
                                      url: model.banner,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      height: 200,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.calendar_month,
                                                        color: context.theme
                                                            .disabledColor,
                                                        size: 24),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      model.createdAt
                                                          .dateWithMonthYear,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  model.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  // Ensure text does not overflow
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Flexible(
                                                  child: Text(
                                                    model.shortDescription,
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    // Ensure text does not overflow
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: context
                                                          .theme.disabledColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.toNamed(Routes.blogDetailPath(
                                                  Get.currentRoute,
                                                  model.urlSlug));
                                              // Get.toNamed(Routes.blogDetailPage,
                                              //     arguments: model);
                                            },
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Read More",
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                SizedBox(width: 5),
                                                Icon(
                                                    Icons
                                                        .arrow_forward_outlined,
                                                    size: 24),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        width: 20,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomElevatedButton(
          text: "Explore More",
          radius: 22,
          width: 236,
          height: 56,
          onPressed: () {
            Get.toNamed(Routes.blogListPath(Get.currentRoute));
            // Get.to(() => BlogListPage());
          },
        ),
      ],
    );
  }
}

// class AppBarWidget extends StatelessWidget {
//   final LandingPageCtrl c = Get.find<LandingPageCtrl>();
//
//   AppBarWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       // logger.d(
//       //     'Color :${c.atTop.isTrue ? "Colors.transparent" : "Colors.white"}');
//       return Visibility(
//         visible: c.isHeaderVisible.value,
//         child: Container(
//           decoration: BoxDecoration(
//             color: c.atTop.isTrue
//                 ? Colors.transparent
//                 : context.theme.scaffoldBackgroundColor,
//             // boxShadow: c.atTop.isTrue
//             //     ? []
//             //     : [
//             //         BoxShadow(
//             //           color: Colors.grey,
//             //           blurRadius: 5.0,
//             //         ),
//             //       ],
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SVGImage(
//                 AppAssets.logo,
//                 height: 41.2,
//                 width: 74.05,
//                 colorFilter: ColorFilter.mode(
//                   context.isDarkMode
//                       ? Colors.white
//                       : context.theme.primaryColor,
//                   BlendMode.srcIn,
//                 ),
//               ),
//               const Row(
//                 children: [
//                   // CustomTextButton(
//                   //   title: 'Home',
//                   //   color: Colors.red,
//                   // onTap: () {},
//                   // type: LandingEnum.home,
//                   // ),
//                   // CustomTextButton(
//                   //   title: 'Secondary Marketplace',
//                   //   onTap: () {
//                   //     Get.toNamed(Routes.secondary);
//                   //   },
//                   // onTap: () {},
//                   // type: LandingEnum.home,
//                   // ),
//                   // const SizedBox(width: 15),
//                   // CustomTextButton(
//                   //   title: 'Invest',
//                   //   onTap: () {
//                   //     Scrollable.ensureVisible(c.liveDeal.currentContext!);
//                   //   },
//                   //   // type: LandingEnum.invest,
//                   // ),
//                   // const SizedBox(width: 15),
//                   // CustomTextButton(
//                   //   title: 'Notification',
//                   //   onTap: () {
//                   //     c.scaffoldKey.currentState?.openEndDrawer();
//                   //   },
//                   //   // type: LandingEnum.notification,
//                   // ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Obx(() {
//                     return IconButton(
//                       mouseCursor: SystemMouseCursors.click,
//                       onPressed: () async {
//                         await init.changeTheme();
//                       },
//                       icon: SVGImage(
//                         icon,
//                         colorFilter: ColorFilter.mode(
//                           context.textTheme.titleMedium?.color ?? Colors.white,
//                           BlendMode.srcIn,
//                         ),
//                       ),
//                     );
//                   }),
//                   const SizedBox(width: 50),
//                   if (app.isUserLogin) ...[
//                     DropdownMenuWidget(),
//                   ] else ...[
//                     CustomElevatedButton(
//                       text: "Login",
//                       width: 150,
//                       radius: 20,
//                       onPressed: () {
//                         Get.toNamed(Routes.signIn);
//                       },
//                     ),
//                   ]
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   String get icon {
//     switch (init.themeModes()) {
//       case ThemeMode.light:
//         return AppAssets.darkModeBg;
//       case ThemeMode.system:
//         return AppAssets.lightModeBg;
//       case ThemeMode.dark:
//         return AppAssets.lightModeBg;
//     }
//   }
// }

class LiveDealWidget extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  LiveDealWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: c.liveDeal,
      children: [
        Container(
          width: context.width,
          margin: EdgeInsets.only(right: context.width * 0.11),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? const Color(0xff0C0C0C)
                : context.theme.primaryColor.withValues(alpha: 0.08),
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(400)),
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(topRight: Radius.circular(400)),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.liveDealController.animateTo(
                              c.liveDealController.offset - 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.liveDealController.animateTo(
                              c.liveDealController.offset + 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                            children: [
                              const TextSpan(
                                text: 'Live ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text: 'Deals',
                                  style: TextStyle(
                                    decorationThickness: 2.5,
                                    decorationColor: context.theme.primaryColor
                                        .withValues(alpha: 0.7),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 85)
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 400,
                  child: Obx(() {
                    return ListView.separated(
                      controller: c.liveDealController,
                      padding: EdgeInsets.only(
                          left: context.width * 0.0276,
                          right: context.width * 0.1),
                      itemCount: c.model().raisingNow.length,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var model = c.model().raisingNow[index];
                        model.startup.isLike.value = model.startup.isFavorite;
                        model.startup.isLike.refresh();
                        return StartupCardWidget(
                          model: model,
                          onTap: () {
                            logger.d(
                                'Current Route :${Get.currentRoute}, Url Slug :${model.startup.urlSlug}');

                            Get.toNamed(Routes.primaryDetailPath(
                                Get.currentRoute, model.startup.urlSlug));

                            // logger.d("Startup Id :${model.id}");
                            // Get.to(StartUpDetailPage(),
                            //     arguments: model.id);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        width: 20,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomElevatedButton(
          text: "Explore More",
          radius: 22,
          width: 236,
          height: 56,
          onPressed: () {
            Get.toNamed(
              Routes.primaryListPath(Get.currentRoute, "raisingnow"),
            );

            // Get.toNamed(Routes.startUpList, arguments: c.model().raisingNow);
            // Get.to(() => StartupListPage(), arguments: c.model().raisingNow);
          },
        ),
      ],
    );
  }
}

class StartupCardWidget extends StatelessWidget {
  final StartupRoundModel model;
  final void Function()? onTap;

  const StartupCardWidget({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    // logger.d(model.startup.cms.logo);
    return SizedBox(
      width: 361,
      height: 425,
      child: Clickable(
        // splashColor: Colors.transparent,
        // hoverColor: Colors.transparent,
        // highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: CustomCardWidget(
          color: context.theme.scaffoldBackgroundColor,
          radius: 14,
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(14)),
                    child: CacheImage(
                      url: model.startup.cms.banner,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10,
                  //   right: 10,
                  //   child: Visibility(
                  //     visible: app.isIUserLogin,
                  //     child: CustomLikeButton(
                  //         isLike: model.startup.isLike,
                  //         id: model.startupId),
                  //   ),
                  // ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          LogoImage(
                            url: model.startup.cms.logo,
                            height: 43,
                            width: 43,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            model.startup.brandName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Round size',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model.startup.raisingRound
                                            .totalFundRequirement
                                            .toFormattedPrice,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          model.startup.raisingRound
                                                      .sharePrice >
                                                  0
                                              ? 'Share price'
                                              : 'Investors',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model.startup.raisingRound.sharePrice >
                                                0
                                            ? model.startup.raisingRound
                                                .sharePrice.toFormattedPrice
                                            : '${model.startup.investorCount}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          model.startup.raisingRound
                                                      .minimumInvestment >
                                                  0
                                              ? 'Min ticket'
                                              : 'Valuation',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model.startup.raisingRound
                                                    .minimumInvestment >
                                                0
                                            ? model.startup.raisingRound
                                                .minimumInvestment
                                                .toFormattedPrice
                                            : model.startup.raisingRound.floor
                                                .toFormattedPrice,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomCardWidget(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
                width: double.infinity,
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.smart_display, size: 17),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          model.startup.sector.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SVGImage(
                      AppAssets.indiaIc,
                      height: 17,
                      width: 17,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          model.startup.city.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedWidget extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  CompletedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.width,
          margin: EdgeInsets.only(left: context.width * 0.1),
          decoration: BoxDecoration(
            color: context.isDarkMode
                ? const Color(0xff0C0C0C)
                : context.theme.primaryColor.withValues(alpha: 0.08),
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(400)),
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.only(topLeft: Radius.circular(400)),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const SizedBox(width: 85),
                    Expanded(
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.w400),
                            children: [
                              const TextSpan(
                                text: 'Completed ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text: 'Campaigns',
                                  style: TextStyle(
                                    decorationThickness: 2.5,
                                    decorationColor: context.theme.primaryColor
                                        .withValues(alpha: 0.7),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.completedDealController.animateTo(
                              c.completedDealController.offset - 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new_outlined,
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          mouseCursor: SystemMouseCursors.click,
                          onPressed: () {
                            c.completedDealController.animateTo(
                              c.completedDealController.offset + 200,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.decelerate,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 400,
                  child: Obx(() {
                    return ListView.separated(
                      controller: c.completedDealController,
                      padding: EdgeInsets.only(left: context.width * 0.12),
                      itemCount: c.model().completed.length,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        var model = c.model().completed[index];
                        model.startup.isLike.value = model.startup.isFavorite;
                        model.startup.isLike.refresh();
                        return StartupCardWidget(
                          model: model,
                          onTap: () {
                            // logger.d(
                            //     'Current Route :${Get.currentRoute}, Url Slug :${model.startup.urlSlug}');
                            Get.toNamed(Routes.primaryDetailPath(
                                Get.currentRoute, model.startup.urlSlug));
                            // Get.toNamed(Routes.startUpDetailPage,
                            //     arguments: model.startupId);

                            // logger.d("Startup Id :${model.id}");
                            // Get.to(StartUpDetailPage(),
                            //     arguments: model.id);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        width: 20,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        CustomElevatedButton(
          text: "Explore More",
          radius: 22,
          width: 236,
          height: 56,
          onPressed: () {
            Get.toNamed(Routes.primaryListPath(Get.currentRoute, "completed"),
                arguments: c.model().completed);

            // Get.toNamed(Routes.startUpList, arguments: c.model().completed);
            // Get.to(() => StartupListPage(), arguments: c.model().completed);
          },
        ),
      ],
    );
  }
}

class ComingSoonWidget extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  ComingSoonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 25),
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
            children: [
              const TextSpan(
                text: 'Coming ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: 'Soon',
                  style: TextStyle(
                    decorationThickness: 2.5,
                    decorationColor:
                        context.theme.primaryColor.withValues(alpha: 0.7),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Obx(() {
          var comingSoonList = c.model().comingSoon;
          var itemsToDisplay = comingSoonList.length > 3
              ? comingSoonList.take(3)
              : comingSoonList;
          return Visibility(
            visible: c.model().comingSoon.isNotEmpty,
            child: Wrap(
              spacing: 15,
              runSpacing: 15,
              children: itemsToDisplay.map((data) {
                var model = data.startup;
                return SizedBox(
                  width: 300,
                  height: 320,
                  child: Clickable(
                    // borderRadius: const BorderRadius.all(Radius.circular(14)),
                    onTap: () {
                      // logger.d("Video :${e.startupPitchVideo}");
                      showCustomDialog(
                        VideoPlayerScreen(url: model.cms.pitchVideo),
                      );
                    },
                    child: CustomCardWidget(
                      margin: EdgeInsets.zero,
                      radius: 14,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: CacheImage(
                              url: model.cms.banner,
                              // height: 153,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      LogoImage(
                                        url: model.cms.logo,
                                        height: 43,
                                        width: 43,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        model.brandName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                          CustomCardWidget(
                            width: double.infinity,
                            height: 40,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            child: Row(
                              children: [
                                CacheImage(
                                  url: model.sector.iconImage,
                                  height: 22,
                                ),
                                // Icon(Icons.smart_display, size: 17),
                                const SizedBox(width: 5),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    model.sector.name,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const SVGImage(
                                  AppAssets.indiaIc,
                                  height: 17,
                                  width: 17,
                                ),
                                const SizedBox(width: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    model.city.name,
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
                  ),
                );
              }).toList(),
            ),
          );
        }),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        CustomElevatedButton(
          text: "Explore More",
          radius: 22,
          width: 236,
          height: 56,
          onPressed: () {
            Get.toNamed(
              Routes.primaryListPath(Get.currentRoute, "comingsoon"),
            );
          },
        ),
      ],
    );
  }
}

class AchievementWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final double? subTitleSize;
  final double? titleSize;

  const AchievementWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    this.subTitleSize,
    this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 300,
      height: 156,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 41),
      radius: 4,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 68,
            width: 68,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffFACFD4),
            ),
            padding: const EdgeInsets.all(10),
            child: SVGImage(image),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize ?? 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subTitle,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: subTitleSize,
                    color: context.theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  final String title;

  // final LandingEnum type;
  final void Function()? onTap;
  final Color? color;

  CustomTextButton({
    super.key,
    required this.title,
    this.onTap,
    this.color,
    /*required this.type*/
  });

  @override
  Widget build(BuildContext context) {
    // return Obx(() {
    // var isSelected = c.currentPage() == type;
    //                                    Scrollable.ensureVisible(
    //                                         c.liveDeal.currentContext!);
    return Clickable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            // color: isSelected ? context.theme.primaryColor : null,
          ),
        ),
      ),
    );
    // });
  }
}
