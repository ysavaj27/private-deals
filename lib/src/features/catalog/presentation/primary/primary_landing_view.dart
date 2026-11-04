import 'package:private_deals/src/shared/app_exports.dart';

import '../widgets/catalog_section_style.dart';
import '../pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart'
    show CustomTabBar;
import 'primary_landing_page_ctrl.dart';
import 'primary_startup_card.dart';
import 'primary_landing_content.dart';

class PrimaryLandingView extends StatelessWidget {
  const PrimaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryLandingPageCtrl>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1496),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                return CustomScrollView(
                  controller: c.scrollController,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 16 : 28,
                        compact ? 24 : 40,
                        compact ? 16 : 28,
                        24,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const CatalogSectionHeading(
                              prefix: 'Explore ',
                              title: 'Startups',
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, size) {
                                final tabs = Obx(() {
                                  final selected = c.selectedTab;
                                  if (selected == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final textScale =
                                      (MediaQuery.textScalerOf(context)
                                                  .scale(15) /
                                              15)
                                          .clamp(1.0, 3.0);
                                  return SizedBox(
                                    height: 44 + (textScale - 1) * 24,
                                    child: CustomTabBar<PrimaryCatalogTab>(
                                      items: c.availableTabs,
                                      labelBuilder: (tab) => tab.label,
                                      itemKey: (tab) =>
                                          ValueKey('primary-tab-${tab.slug}'),
                                      selected: selected,
                                      onSelected: c.tab.call,
                                    ),
                                  );
                                });
                                final search = TextField(
                                  key: const ValueKey('primary-catalog-search'),
                                  controller: c.searchController,
                                  onChanged: c.query.call,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search_rounded),
                                    hintText: 'Search startups or sectors',
                                  ),
                                );
                                if (size.maxWidth < 960) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      tabs,
                                      const SizedBox(height: 16),
                                      search,
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(child: tabs),
                                    const SizedBox(width: 24),
                                    SizedBox(width: 360, child: search),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 16 : 28,
                      ),
                      sliver: Obx(() {
                        if (c.isLoading.value) {
                          return const SliverToBoxAdapter(
                            child: SizedBox(height: 260, child: Loader()),
                          );
                        }
                        if (c.loadError.value.isNotEmpty) {
                          return SliverToBoxAdapter(
                            child: PrimaryCatalogState(
                              title: 'Startups are unavailable',
                              message: c.loadError.value,
                              onRetry: c.getData,
                            ),
                          );
                        }
                        final startups = c.currentStartups;
                        if (startups.isEmpty) {
                          return SliverToBoxAdapter(
                            child: PrimaryCatalogState(
                              title: c.query.value.isEmpty
                                  ? 'No startups here yet'
                                  : 'No matching startups',
                              message: 'Try another category or search term.',
                            ),
                          );
                        }
                        return PrimaryCatalogSliverGrid(
                          itemCount: startups.length.clamp(0, 6),
                          itemBuilder: (_, index) => PrimaryStartupCard(
                            round: startups[index],
                            comingSoon:
                                c.selectedTab == PrimaryCatalogTab.comingSoon,
                          ),
                        );
                      }),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 16 : 28,
                        24,
                        compact ? 16 : 28,
                        40,
                      ),
                      sliver: SliverList.list(
                        children: [
                          Obx(() {
                            final selected = c.selectedTab;
                            if (selected == null ||
                                c.isLoading.value ||
                                c.loadError.value.isNotEmpty) {
                              return const SizedBox.shrink();
                            }
                            return CatalogExploreButton(
                              text: context.isPhone
                                  ? 'Explore More'
                                  : 'Explore ${selected.label}',
                              onPressed: () => Get.toNamed(
                                Routes.primaryListPath(
                                  Routes.catalogPath(WTabBarEnum.primary.slug),
                                  selected.slug,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 48),
                          const PrimaryFeaturedSectors(),
                          const SizedBox(height: 48),
                          const PrimaryArticles(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
