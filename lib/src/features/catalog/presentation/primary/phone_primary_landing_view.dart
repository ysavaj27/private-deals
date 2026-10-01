import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';

class PhonePrimaryLandingView extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  PhonePrimaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // appBar: PhoneAppBar(
      //   title: 'Home',
      //   actions: [
      //     Obx(() {
      //       return IconButton(
      //         onPressed: () async {
      //           await init.changeTheme();
      //         },
      //         icon: SVGImage(
      //           icon,
      //           colorFilter: ColorFilter.mode(
      //             context.textTheme.titleMedium?.color ?? Colors.white,
      //             BlendMode.srcIn,
      //           ),
      //         ),
      //       );
      //     }),
      //     // if (!app.isUserLogin) ...[
      //     //   IconButton(
      //     //     splashRadius: 20,
      //     //     onPressed: () {
      //     //       Get.to(() => LoginPage());
      //     //     },
      //     //     icon: const Icon(Icons.person_2_outlined),
      //     //   ),
      //     //   // const Padding(
      //     //   //   padding: EdgeInsets.only(right: 10),
      //     //   //   child: DropdownMenuWidget(),
      //     //   // ),
      //     // ]
      //   ],
      // ),
      // drawer: DashboardDrawer(),
      body: Obx(() {
        if (c.isLoading.isFalse) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                DealCarouselSlot(
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: c.model().raisingNow.length,
                    itemBuilder: (context, index) {
                      var model = c.model().raisingNow[index];
                      return CustomCardWidget(
                        isForeground: true,
                        height: double.infinity,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        radius: AppRadii.sm,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.primaryDetailPath(
                              '/wealth-manager/${WTabBarEnum.primary.slug}',
                              model.startup.urlSlug,
                            ));
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.bottomLeft,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CacheImage(
                                  url: model.startup.cms.banner,
                                  fit: BoxFit.cover,
                                  height: context.height,
                                  width: context.width,
                                ),
                              ),
                              // Container(
                              //   color: const Color(0xff000000).withValues(alpha: 0.4),
                              //   height: context.height,
                              //   width: context.width,
                              // ),
                              Positioned(
                                left: -2,
                                bottom: -2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SVGImage(
                                    AppAssets.cardShape3,
                                    height: 330,
                                    colorFilter: ColorFilter.mode(
                                        context.theme.scaffoldBackgroundColor,
                                        BlendMode.srcIn),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 20,
                                top: 20,
                                child: CacheImage(
                                  url: model.startup.cms.logo,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 60, left: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          model.startup.brandName,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 165,
                                        child: Text(
                                          model.startup.briefInformation,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: context.theme.disabledColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25),
                                      SizedBox(
                                        width: 280,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Round Size'),
                                                const SizedBox(height: 5),
                                                Text(
                                                  model
                                                      .startup
                                                      .raisingRound
                                                      .totalFundRequirement
                                                      .toFormattedPrice,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: context
                                                        .theme.disabledColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (model.startup.raisingRound
                                                    .sharePrice >
                                                0)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Share price'),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    model.startup.raisingRound
                                                        .sharePrice
                                                        .toFormattedPrice,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: context
                                                          .theme.disabledColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (model.startup.raisingRound
                                                    .minimumInvestment >
                                                0)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Min ticket'),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    model
                                                        .startup
                                                        .raisingRound
                                                        .minimumInvestment
                                                        .toFormattedPrice,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: context
                                                          .theme.disabledColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Investors'),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    '${model.startup.investorCount}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: context
                                                          .theme.disabledColor,
                                                      fontWeight:
                                                          FontWeight.w600,
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
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.all(12),
                                  width: context.width,
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(8),
                                  //   color: context.theme.scaffoldBackgroundColor
                                  //       .withValues(alpha: 0.8),
                                  // ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.smart_display, size: 17),
                                      const SizedBox(width: 5),
                                      Text(
                                        model.startup.sector.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      const SVGImage(
                                        AppAssets.indiaIc,
                                        height: 17,
                                        width: 17,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        model.startup.city.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 38),
                Obx(() {
                  return Visibility(
                    visible: c.model().comingSoon.isNotEmpty,
                    child: FadeIn(
                      child: DealSectionHeader(
                        title: 'Coming Soon',
                        padding: const EdgeInsets.only(left: 17),
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: c.model().comingSoon.isNotEmpty,
                    child: const SizedBox(height: 20),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: c.model().comingSoon.isNotEmpty,
                    child: SizedBox(
                      height: 209,
                      child: PageView.builder(
                        itemCount: c.model().comingSoon.length,
                        itemBuilder: (context, index) {
                          var model = c.model().comingSoon[index];
                          return CustomCardWidget(
                            isForeground: true,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            radius: 18,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: CacheImage(
                                    url: model.startup.cms.banner,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  top: -2,
                                  child: SVGImage(
                                    AppAssets.cardShape2,
                                    fit: BoxFit.fill,
                                    colorFilter: ColorFilter.mode(
                                        context.theme.scaffoldBackgroundColor,
                                        BlendMode.srcIn),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: context.width * 0.55,
                                    // color: Colors.red,
                                    padding:
                                        const EdgeInsets.only(left: 7, top: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            LogoImage(
                                              url: model.startup.cms.logo,
                                              height: 52,
                                              width: 52,
                                            ),
                                            const SizedBox(width: 9),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    model.startup.brandName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    model.startup
                                                        .briefInformation,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: context
                                                          .theme.dividerColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 25),
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            const Icon(Icons.smart_display,
                                                size: 17),
                                            const SizedBox(width: 5),
                                            Text(
                                              model.startup.sector.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            const SVGImage(
                                              AppAssets.indiaIc,
                                              height: 17,
                                              width: 17,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              model.startup.city.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 26),
                                        SizedBox(
                                          height: 27.68,
                                          child: CustomElevatedButton(
                                            width: 84,
                                            padding: EdgeInsets.zero,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            text: 'Explore',
                                            onPressed: () {
                                              showCustomDialog(
                                                VideoPlayerScreen(
                                                    url: model.startup.cms
                                                        .pitchVideo),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: c.model().comingSoon.isNotEmpty,
                    child: const SizedBox(height: 38),
                  );
                }),
                FadeIn(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 17),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 24),
                        children: [
                          TextSpan(
                            text: 'Completed ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'Campaigns'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 120,
                  child: Obx(() {
                    if (c.model().completed.isNotEmpty) {
                      return CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 120,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: true,
                          viewportFraction: 0.4,
                        ),
                        itemCount: c.model().completed.length,
                        itemBuilder: (context, index, realIdx) {
                          var model = c.model().completed[index];
                          return SwipeablePage(model: model.startup);
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
                ),
                const SizedBox(height: 48),
                FadeIn(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 17),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 24),
                        children: [
                          TextSpan(
                            text: 'Featured ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: 'Sectors'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 103,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var model = c.sectors[index];
                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            Routes.primaryListPath(
                                '/wealth-manager/${WTabBarEnum.primary.slug}',
                                model.slug),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: CustomCardWidget(
                          padding: const EdgeInsets.all(10),
                          width: 88,
                          child: Column(
                            children: [
                              CacheImage(
                                url: model.iconImage,
                                height: 48,
                                // color: context.iconColor,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                model.name,
                                maxLines: 2,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemCount: c.sectors.length,
                  ),
                ),
                const SizedBox(height: 38),
                FadeIn(
                  child: const Padding(
                    padding: EdgeInsets.only(left: 17),
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 24),
                        children: [
                          TextSpan(
                            text: 'Featured ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: c.controller,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var model = c.blogs[index];
                      return CustomCardWidget(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 13),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: "${model.id}",
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CacheImage(
                                  url: model.banner,
                                  height: 191,
                                  width: context.width,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              model.title,
                              maxLines: 2,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              model.shortDescription,
                              maxLines: 2,
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: SizedBox(
                                height: 30,
                                child: CustomElevatedButton(
                                  text: 'Read More',
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    var route = Routes.blogDetailPath(
                                        '/wealth-manager/${WTabBarEnum.primary.slug}',
                                        model.urlSlug);
                                    Get.toNamed(route);
                                  },
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  maximumSize: const Size(130, 30),
                                  size: const Size(130, 30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: c.blogs.length,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: c.controller,
                    count: c.blogs.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 5,
                      dotColor: Colors.white54,
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 38),
              ],
            ),
          );
        } else {
          return const Loader();
        }
      }),
      /*  body: Stack(
        children: [
          SingleChildScrollView(
            controller: c.scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SVGImage(
                        AppAssets.landingBg,
                        height: 364.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(fontSize: 32),
                              children: [
                                TextSpan(
                                  text: 'Providing A \n',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.theme.primaryColor,
                                  ),
                                ),
                                const TextSpan(text: 'Better way to \n'),
                                TextSpan(
                                    text: 'Invest',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2.5,
                                      decorationColor: context
                                          .theme.primaryColor
                                          .withValues(alpha: 0.7),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Investing in start-ups is now at your fingertips. you can meet, greet, Invest, Exit and stay connected with start-ups on the same platform.",
                            maxLines: 6,
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  context.theme.disabledColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Row(
                            children: [
                              CustomElevatedButton(
                                width: 118,
                                height: 38,
                                borderRadius: 22,
                                fontSize: 12,
                                text: 'Get Started Now',
                                onPressed: () {
                                  Scrollable.ensureVisible(
                                      c.liveDeal.currentContext!);
                                },
                              ),
                              const SizedBox(width: 15),
                              TextButton(
                                onPressed: () {
                                  showCustomDialog(
                                    const VideoPlayerScreen(
                                        url:
                                            "https://www.shuruup.com/web/intro-video.mp4"),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(4),
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                          color: context.theme.primaryColor,
                                          shape: BoxShape.circle),
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 20,
                                        color: context
                                            .theme.scaffoldBackgroundColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Tour Video",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: context.isDarkMode
                                            ? context.theme.primaryColor
                                            : context.theme.shadowColor,
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
                const SizedBox(height: 60),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 10),
                      AchievementWidget(
                        image: AppAssets.investmentIc,
                        title: '₹12.94Cr',
                        titleSize: 14,
                        subTitle: 'Total Investments',
                        subTitleSize: 12,
                      ),
                      SizedBox(width: 10),
                      AchievementWidget(
                        image: AppAssets.fundDealsIc,
                        title: '10',
                        titleSize: 14,
                        subTitle: 'Total Funded deals',
                        subTitleSize: 12,
                      ),
                      SizedBox(width: 10),
                      AchievementWidget(
                        image: AppAssets.dealsIc,
                        titleSize: 14,
                        title: '40',
                        subTitle: 'Completed Deals Secondary market',
                        subTitleSize: 12,
                      ),
                      SizedBox(width: 10),
                      AchievementWidget(
                        image: AppAssets.opportunitiesIc,
                        titleSize: 14,
                        title: '4',
                        subTitle: 'Current opportunities',
                        subTitleSize: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 70),
                LiveDealWidget(),
                const SizedBox(height: 30),
                ComingSoonWidget(),
                const SizedBox(height: 30),
                CompletedWidget(),
                const SizedBox(height: 30),
                FeaturedWidget(),
                const SizedBox(height: 30),
                BlogWidget(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),*/
    );
  }

  String get icon {
    switch (init.themeModes()) {
      case ThemeMode.light:
        return AppAssets.darkModeBg;
      case ThemeMode.system:
        return AppAssets.lightModeBg;
      case ThemeMode.dark:
        return AppAssets.lightModeBg;
    }
  }
}

class SwipeablePage extends StatelessWidget {
  final StartupModel model;

  const SwipeablePage({required this.model});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.primaryDetailPath(
          '/wealth-manager/${WTabBarEnum.primary.slug}',
          model.urlSlug,
        ));
        // Get.toNamed(Routes.primaryDetailPage, arguments: model.id);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CacheImage(
                  url: model.cms.banner,
                  height: 85,
                  width: 145,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            model.brandName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Text(
          //   subtitle,
          //   style: TextStyle(
          //     color: Colors.grey,
          //     fontSize: 18,
          //   ),
          // ),
        ],
      ),
    );
  }
}
