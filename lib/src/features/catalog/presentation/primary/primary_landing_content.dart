part of 'desktop_primary_landing_view.dart';

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
                  decorationColor: context.theme.primaryColor.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
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
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
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
                            c.blogController.animateTo(
                              c.blogController.offset - 200,
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
                            c.blogController.animateTo(
                              c.blogController.offset + 200,
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
                      controller: c.blogController,
                      padding: EdgeInsets.only(
                        left: context.width * 0.0276,
                        right: context.width * 0.1,
                      ),
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
                                  Get.currentRoute,
                                  model.urlSlug,
                                ),
                              );
                            },
                            child: CustomCardWidget(
                              color: context.theme.scaffoldBackgroundColor,
                              radius: 14,
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14),
                                    ),
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
                                                    Icon(
                                                      Icons.calendar_month,
                                                      color: context
                                                          .theme
                                                          .disabledColor,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      model
                                                          .createdAt
                                                          .dateWithMonthYear,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
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
                                                          .theme
                                                          .disabledColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.toNamed(
                                                Routes.blogDetailPath(
                                                  Get.currentRoute,
                                                  model.urlSlug,
                                                ),
                                              );
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
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Icon(
                                                  Icons.arrow_forward_outlined,
                                                  size: 24,
                                                ),
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
            Get.toNamed(Routes.blogListPath(Get.currentRoute));
            // Get.to(() => BlogListPage());
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
