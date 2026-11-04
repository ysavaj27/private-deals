import 'package:private_deals/src/shared/app_exports.dart';

import '../widgets/catalog_article_card.dart';
import '../widgets/catalog_section_style.dart';
import '../pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart'
    show AutoScrollSectorList;

import 'primary_landing_page_ctrl.dart';
import 'primary_startup_card.dart';
import 'blog_detail/blog_detail_page.dart';

class PrimaryFeaturedSectors extends StatelessWidget {
  const PrimaryFeaturedSectors({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryLandingPageCtrl>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogSectionHeading(prefix: 'Featured ', title: 'Sectors'),
        SizedBox(height: context.isPhone ? 20 : 40),
        Obx(() {
          if (c.sectorsLoading.value) {
            return const SizedBox(height: 120, child: Loader());
          }
          if (c.sectorsError.value.isNotEmpty) {
            return PrimaryCatalogState(
              title: 'Sectors are unavailable',
              message: c.sectorsError.value,
              onRetry: c.sectorList,
            );
          }
          if (c.sectors.isEmpty) {
            return const PrimaryCatalogState(
              title: 'Sectors are coming soon',
              message: 'Check back for more opportunities.',
            );
          }
          void openSector(SectorModel sector) {
            if (sector.slug.isNotEmpty) {
              Get.toNamed(
                Routes.primaryListPath(
                  Routes.catalogPath(WTabBarEnum.primary.slug),
                  sector.slug,
                ),
              );
            }
          }

          return AutoScrollSectorList(
            sectors: c.sectors.toList(),
            isPhone: MediaQuery.sizeOf(context).width < 600,
            onViewMore: openSector,
            onLogoTap: (sector, _) => openSector(sector),
          );
        }),
      ],
    );
  }
}

class PrimaryArticles extends StatelessWidget {
  const PrimaryArticles({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryLandingPageCtrl>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CatalogSectionHeading(title: 'Blogs'),
        SizedBox(height: context.isPhone ? 20 : 60),
        Obx(() {
          if (c.blogsLoading.value) {
            return const SizedBox(height: 180, child: Loader());
          }
          if (c.blogsError.value.isNotEmpty) {
            return PrimaryCatalogState(
              title: 'Articles are unavailable',
              message: c.blogsError.value,
              onRetry: c.blogList,
            );
          }
          if (c.blogs.isEmpty) {
            return const PrimaryCatalogState(
              title: 'New insights are on the way',
              message: 'Articles will appear here when published.',
            );
          }
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: context.isPhone ? 0 : 20),
            child: CatalogArticleCarousel(
              itemCount: c.blogs.length,
              itemBuilder: (_, index) => PrimaryBlogCard(blog: c.blogs[index]),
            ),
          );
        }),
        SizedBox(height: context.isPhone ? 20 : 40),
        CatalogExploreButton(
          onPressed: () => Get.toNamed(
            Routes.blogListPath(Routes.catalogPath(WTabBarEnum.primary.slug)),
          ),
        ),
      ],
    );
  }
}

class PrimaryBlogCard extends StatelessWidget {
  const PrimaryBlogCard({super.key, required this.blog, this.onTap});
  final BlogModel blog;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => CatalogArticleCard(
    image: blog.banner,
    title: blog.title,
    description: blog.shortDescription,
    date: blog.createdAt,
    onTap:
        onTap ??
        () => Get.toNamed(
          Routes.blogDetailPath(Get.currentRoute, blog.urlSlug),
        ),
  );
}
