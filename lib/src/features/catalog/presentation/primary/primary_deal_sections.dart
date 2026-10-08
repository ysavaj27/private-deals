part of 'desktop_primary_landing_view.dart';

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
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(400),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(400),
            ),
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
                          icon: const Icon(Icons.arrow_back_ios_new_outlined),
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
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                            ),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 85),
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
                        right: context.width * 0.1,
                      ),
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
                              'Current Route :${Get.currentRoute}, Url Slug :${model.startup.urlSlug}',
                            );

                            Get.toNamed(
                              Routes.primaryDetailPath(
                                Get.currentRoute,
                                model.startup.urlSlug,
                              ),
                            );

                            // logger.d("Startup Id :${model.id}");
                            // Get.to(StartUpDetailPage(),
                            //     arguments: model.id);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 20),
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
            Get.toNamed(Routes.primaryListPath(Get.currentRoute, "raisingnow"));

            // Get.toNamed(Routes.startUpList, arguments: c.model().raisingNow);
            // Get.to(() => StartupListPage(), arguments: c.model().raisingNow);
          },
        ),
      ],
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(400),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(400),
            ),
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
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                            ),
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
                                ),
                              ),
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
                          icon: const Icon(Icons.arrow_back_ios_new_outlined),
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
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
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
                            Get.toNamed(
                              Routes.primaryDetailPath(
                                Get.currentRoute,
                                model.startup.urlSlug,
                              ),
                            );
                            // Get.toNamed(Routes.startUpDetailPage,
                            //     arguments: model.startupId);

                            // logger.d("Startup Id :${model.id}");
                            // Get.to(StartUpDetailPage(),
                            //     arguments: model.id);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(width: 20),
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
              Routes.primaryListPath(Get.currentRoute, "completed"),
              arguments: c.model().completed,
            );

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
                  decorationColor: context.theme.primaryColor.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
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
                              top: Radius.circular(14),
                            ),
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
                              bottom: Radius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
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
            Get.toNamed(Routes.primaryListPath(Get.currentRoute, "comingsoon"));
          },
        ),
      ],
    );
  }
}
