import 'dart:async';

import '../../widgets/catalog_article_card.dart';
import '../../widgets/catalog_section_style.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/rendering.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/news_list/news_detail_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/pre_ipo_landing_page_ctrl.dart';

class DesktopPreIPOLandingView extends StatelessWidget {
  final PreIPOLandingPageCtrl c = Get.find<PreIPOLandingPageCtrl>();

  DesktopPreIPOLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CatalogSectionHeading(
              prefix: 'Explore ',
              title: 'Unlisted Shares',
            ),

            const SizedBox(height: 24),

            // Tab chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: Obx(() {
                        return CustomTabBar<UnListedShareTabEnum>(
                          items: PreIPOLandingPageCtrl.tabs,
                          labelBuilder: (tab) => tab.label,
                          selected: c.tab.value,
                          onSelected: c.changeTab,
                          isHighlighted: (tab) =>
                              tab == UnListedShareTabEnum.hotDeals,
                          highlightedIcon: Icons.local_fire_department_rounded,
                        );
                      }),
                    ),
                  ),
                  // const SizedBox(width: 12),
                  Visibility(
                    visible: context.width > 800,
                    child: SizedBox(
                      width: 400,
                      child: SearchBarTextField(
                        readOnly: true,
                        radius: AppRadii.control,
                        hintText: "Search Company's",
                        onTap: () {
                          var routes = Routes.preIPOListPath(
                            Get.currentRoute,
                            "search",
                          );
                          logger.d(routes);
                          Get.toNamed(routes);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Card list — swaps automatically when tab changes
            Obx(() {
              final companies = c.currentCompanies;

              if (c.isLoading.isTrue) {
                return SizedBox(height: context.height * 0.4, child: Loader());
              }

              if (companies.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: NoDataView(
                    title: 'No companies to show here.',
                    isRefreshButton: false,
                  ),
                );
              }

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  for (final company in companies)
                    CustomCompanyCard(
                      company: company,
                      // logo: CacheImage(url: company.logo),
                      // companyName: company.brandName,
                      // changePercent: company.percentageChange,
                      // sector: company.category,
                      // badgeText: company.headingText,
                      onTap: () {
                        var route = Routes.preIPODetailPath(
                          Routes.catalogPath(WTabBarEnum.preIPO.slug),
                          company.slug,
                        );
                        logger.d(route);
                        Get.toNamed(route);
                      },
                    ),
                  // CustomCompanyCard(
                  //   company,
                  //   onTap: () {
                  //     var route = Routes.preIPODetailPath(
                  //         "/wealth-manager/${WTabBarEnum.preIPO.slug}", company.slug);
                  //     logger.d(route);
                  //     Get.toNamed(route);
                  //   },
                  // ),
                ],
              );
            }),
            const SizedBox(height: 40),
            Obx(() {
              return CustomElevatedButton(
                radius: AppRadii.button,
                text: "Explore ${c.tab.value.label}",
                // radius: 22,
                width: 236,
                height: 56,
                onPressed: () {
                  var routes = Routes.preIPOListPath(
                    Get.currentRoute,
                    c.tab.value.route,
                  );
                  logger.d(routes);
                  Get.toNamed(routes);
                },
              );
            }),
            const SizedBox(height: 80),
            FeaturedWidget(),
            const SizedBox(height: 100),
            NewsWidget(),
            const SizedBox(height: 80),

            // --- rest of your page content goes below this line ---
          ],
        ),
      ),
    );
  }
}

class CustomTabBar<T> extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.selected,
    required this.onSelected,
    this.isHighlighted,
    this.highlightedIcon,
    this.itemKey,
  });

  final Key Function(T item)? itemKey;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool Function(T item)? isHighlighted;
  final IconData? highlightedIcon;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item == selected;
        final highlighted = isHighlighted?.call(item) ?? false;
        return _TabItem(
          key: itemKey?.call(item),
          label: labelBuilder(item),
          isSelected: isSelected,
          isHighlighted: highlighted,
          highlightedIcon: highlighted ? highlightedIcon : null,
          onTap: () => onSelected(item),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isHighlighted = false,
    this.highlightedIcon,
  });

  final String label;
  final bool isSelected;
  final bool isHighlighted;
  final IconData? highlightedIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final accent = AppColors.secondaryStartUp;
    final primary = context.theme.primaryColor;

    final Color bg;
    final Color borderColor;
    final Color textColor;
    final double borderWidth;

    if (isHighlighted) {
      bg = scheme.surface;
      borderColor = isSelected ? accent : accent.withValues(alpha: 0.55);
      textColor = isSelected ? primary : scheme.onSurface;
      borderWidth = isSelected ? 2 : 1.5;
    } else {
      bg = scheme.surface;
      borderColor = isSelected ? primary : scheme.outlineVariant;
      textColor = isSelected ? scheme.onSurface : scheme.onSurfaceVariant;
      borderWidth = isSelected ? 1.5 : 1;
    }

    return Clickable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.tab),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (highlightedIcon != null) ...[
              Icon(
                highlightedIcon,
                size: 18,
                color: isSelected ? accent : accent.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: isSelected || isHighlighted
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCompanyCard extends StatelessWidget {
  const CustomCompanyCard({super.key, required this.company, this.onTap});

  /// Logo image widget (e.g. Image.network / Image.asset / SvgPicture).
  // final Widget logo;

  // final String companyName;

  /// e.g. 1.3 for +1.3%, -2.4 for -2.4%
  // final double changePercent;

  // final String sector;

  /// Optional ribbon text, e.g. "Low entry price".
  /// Pass an empty string to hide the ribbon entirely.
  // final String badgeText;

  final CompanyModel company;
  final VoidCallback? onTap;

  static const double cardWidth = 400;

  // bool get _isPositive => company.profitLossValue >= 0;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final accents = context.sectionAccents;

    // ---- Theme-aware palette ----
    final cardBg = scheme.surface;
    final cardBorder = scheme.outlineVariant;
    final logoBg = scheme.surfaceContainerHighest;
    final nameColor = scheme.onSurface;
    final sectorColor = scheme.onSurfaceVariant;
    final badgeBg = accents.unlistedShares;
    const badgeTextColor = Colors.white;

    // const positiveColor = Color(0xFF3DD68C);
    // const negativeColor = Color(0xFFFF6B6B);
    // final changeColor = _isPositive ? positiveColor : negativeColor;
    // Slightly stronger tint needed on white backgrounds to stay legible.
    // final changeBg = (_isPositive ? positiveColor : negativeColor)
    //     .withValues(alpha:isDark ? 0.12 : 0.14);
    // final sign = _isPositive ? '+' : '';

    final isPhone = context.isPhone;
    final width = isPhone ? MediaQuery.sizeOf(context).width - 24 : cardWidth;
    final phoneContentHeight = isPhone
        ? _phoneContentHeight(context, width)
        : 0.0;
    // Keep the 80 slot unless the badge or price row is taller than it.
    final double? height = isPhone
        ? (phoneContentHeight > 80 ? null : 80)
        : 120;

    return Clickable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: height == null ? StackFit.loose : StackFit.expand,
          children: [
            Container(
              width: width,
              constraints: height == null
                  ? BoxConstraints(minHeight: phoneContentHeight)
                  : null,
              padding: EdgeInsets.all(context.isPhone ? 10 : 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo box
                  Container(
                    width: context.isPhone ? 56 : 80,
                    height: context.isPhone ? 56 : 80,
                    decoration: BoxDecoration(
                      color: logoBg,
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          company.logo,
                          imageRenderMethodForWeb:
                              ImageRenderMethodForWeb.HttpGet,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          company.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: nameColor,
                            fontSize: context.isPhone ? 16 : 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: context.isPhone ? 5 : 10),
                        Row(
                          children: [
                            Text(
                              company.sharePrice.toCurrency,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 8,
                            //     vertical: 3,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: changeBg,f
                            //     borderRadius: BorderRadius.circular(AppRadii.badge),
                            //   ),
                            //   child: Text(
                            //     '$sign${company.percentageChange.toStringAsFixed(1)}%',
                            //     style: TextStyle(
                            //       color: changeColor,
                            //       fontSize: 14,
                            //       fontWeight: FontWeight.w600,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                company.sector,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: sectorColor,
                                  fontSize: context.isPhone ? 14 : 16,
                                ),
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
            // Ribbon badge (optional)
            if (company.headingText.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppRadii.card),
                    bottomLeft: Radius.circular(AppRadii.control),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    color: badgeBg,
                    child: Text(
                      company.headingText,
                      style: const TextStyle(
                        color: badgeTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Height of the phone card's padding, logo/text row, and ribbon badge.
  double _phoneContentHeight(BuildContext context, double width) {
    final scaler = MediaQuery.textScalerOf(context);
    final base = DefaultTextStyle.of(context).style;
    final direction = Directionality.of(context);
    final textWidth = width - 90;

    final nameHeight = _textHeight(
      company.brandName,
      base.copyWith(fontSize: 16, fontWeight: FontWeight.w900),
      textWidth,
      scaler,
      direction,
      maxLines: 1,
    );
    final priceHeight = _textHeight(
      company.sharePrice.toCurrency,
      base.copyWith(fontSize: 14, fontWeight: FontWeight.w800),
      textWidth,
      scaler,
      direction,
      maxLines: 1,
    );
    final sectorHeight = _textHeight(
      company.sector,
      base.copyWith(fontSize: 14),
      textWidth,
      scaler,
      direction,
      maxLines: 1,
    );
    final rowHeight = priceHeight > sectorHeight ? priceHeight : sectorHeight;
    final textColumn = nameHeight + 5 + rowHeight;
    final body = 20 + (textColumn > 56 ? textColumn : 56.0);

    if (company.headingText.isEmpty) return body;

    final badgeHeight =
        _textHeight(
          company.headingText,
          base.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          width - 28,
          scaler,
          direction,
        ) +
        16;
    return body > badgeHeight ? body : badgeHeight;
  }

  double _textHeight(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler scaler,
    TextDirection direction, {
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      maxLines: maxLines,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth > 0 ? maxWidth : 0);
    final height = painter.height;
    painter.dispose();
    return height;
  }
}

class FeaturedWidget extends StatelessWidget {
  final PreIPOLandingPageCtrl c = Get.find<PreIPOLandingPageCtrl>();

  FeaturedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CatalogSectionHeading(prefix: 'Featured ', title: 'Sectors'),
        SizedBox(height: context.isPhone ? 20 : 40),
        Obx(() {
          return AutoScrollSectorList(
            sectors: c.newsSector().sectors,
            isPhone: context.isPhone,
            onViewMore: (model) {
              var routes = Routes.preIPOListPath(Get.currentRoute, model.slug);
              logger.d(routes);
              Get.toNamed(routes);
            },
            onLogoTap: (model, company) {
              var routes = Routes.preIPOListPath(Get.currentRoute, model.slug);
              logger.d(routes);
              Get.toNamed(routes);
            },
          );
        }),
      ],
    );
  }
}

class NewsWidget extends StatelessWidget {
  final PreIPOLandingPageCtrl c = Get.find<PreIPOLandingPageCtrl>();

  NewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CatalogSectionHeading(title: 'News'),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(
            () => CatalogArticleCarousel(
              itemCount: c.newsSector().news.length,
              itemBuilder: (context, index) {
                final news = c.newsSector().news[index];
                return CatalogArticleCard(
                  image: news.image,
                  title: news.title,
                  description: news.description,
                  date: news.createdAt,
                  onTap: () => showNewsDetailBottomSheet(context, news: news),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 40),
        CatalogExploreButton(
          onPressed: () {
            Get.toNamed(Routes.newsListPath(Get.currentRoute));
          },
        ),
      ],
    );
  }
}

class SectorCard extends StatelessWidget {
  const SectorCard({
    super.key,
    required this.icon,
    required this.sectorName,
    required this.companyCount,
    required this.logos,
    this.onViewMore,
    this.onLogoTap,
  });

  final String icon;
  final String sectorName;
  final int companyCount;

  final List<SectorCompanyModel> logos;
  final VoidCallback? onViewMore;
  final void Function(SectorCompanyModel item)? onLogoTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;

    final cardBg = scheme.surface;
    final cardBorder = scheme.outlineVariant;
    final titleColor = scheme.onSurface;
    final subtitleColor = scheme.onSurfaceVariant;
    final logoBg = scheme.surfaceContainerHighest;

    return Container(
      width: context.isPhone ? 270 : 400,
      // height: 400,
      padding: EdgeInsets.all(context.isPhone ? 10 : 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon + name + count
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: context.isPhone ? 54 : 60,
                height: context.isPhone ? 54 : 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: logoBg,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                  image: icon.isEmpty
                      ? null
                      : DecorationImage(
                          fit: BoxFit.contain,
                          image: CachedNetworkImageProvider(
                            icon,
                            imageRenderMethodForWeb:
                                ImageRenderMethodForWeb.HttpGet,
                          ),
                        ),
                ),
                child: icon.isEmpty
                    ? Icon(Icons.category_outlined, color: scheme.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: context.isPhone ? 16 : 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      companyCount > 0
                          ? '$companyCount Companies'
                          : 'Explore companies',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: context.isPhone ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.isPhone ? 6 : 16),
          Row(
            children: [
              OverlappingLogoRow(
                logos: logos,
                overlap: context.isPhone ? 20 : 16,
                maxVisible: context.isPhone
                    ? (MediaQuery.textScalerOf(context).scale(14) > 17 ? 3 : 4)
                    : 6,
                size: 45,
                onTap: onLogoTap,
              ),
              const Spacer(),
              if (onViewMore != null)
                Clickable(
                  onTap: onViewMore,
                  // behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View more',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: context.isPhone ? 13 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: subtitleColor,
                        size: context.isPhone ? 16 : 20,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Overlapping circular logo row (based on your existing structure) —
/// each logo is clipped into a circle, plus a "+N" circle for overflow.
class OverlappingLogoRow extends StatelessWidget {
  const OverlappingLogoRow({
    super.key,
    required this.logos,
    this.size = 38,
    this.maxVisible = 6,
    this.overlap = 16,
    this.onTap,
  });

  final List<SectorCompanyModel> logos;
  final int maxVisible;
  final double size;
  final double overlap;
  final void Function(SectorCompanyModel model)? onTap;

  @override
  Widget build(BuildContext context) {
    final visibleCount = logos.length > maxVisible ? maxVisible : logos.length;
    final remaining = logos.length - visibleCount;

    return SizedBox(
      height: size,
      width:
          (visibleCount + (remaining > 0 ? 1 : 0)) * (size - overlap) + overlap,
      child: Stack(
        children: [
          for (int i = 0; i < visibleCount; i++)
            Positioned(
              left: i * (size - overlap),
              child: _LogoCircle(model: logos[i], size: size, onTap: onTap),
            ),
          if (remaining > 0)
            Positioned(
              left: visibleCount * (size - overlap),
              child: _MoreCircle(count: remaining, size: size),
            ),
        ],
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  const _LogoCircle({required this.model, required this.size, this.onTap});

  final SectorCompanyModel model;
  final double size;
  final void Function(SectorCompanyModel model)? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final ringColor = scheme.surface;
    final bg = scheme.surfaceContainerHighest;

    return Clickable(
      onTap: onTap == null ? null : () => onTap!(model),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: ringColor, width: 2),
          image: model.logo.isEmpty
              ? null
              : DecorationImage(
                  fit: BoxFit.contain,
                  image: CachedNetworkImageProvider(
                    model.logo,
                    imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
                  ),
                ),
        ),
        padding: const EdgeInsets.all(1),
        clipBehavior: Clip.antiAlias,
        child: model.logo.isEmpty
            ? Icon(
                Icons.business_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}

class _MoreCircle extends StatelessWidget {
  const _MoreCircle({required this.count, required this.size});

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final ringColor = scheme.surface;
    final bg = scheme.surfaceContainerHigh;
    final textColor = scheme.onSurface;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: ringColor, width: 2),
      ),
      child: Text(
        '+$count',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AutoScrollSectorList extends StatefulWidget {
  final List<SectorModel> sectors; // replace with your actual model type
  final bool isPhone;
  final void Function(SectorModel model) onViewMore;
  final void Function(SectorModel model, dynamic company) onLogoTap;

  const AutoScrollSectorList({
    super.key,
    required this.sectors,
    required this.isPhone,
    required this.onViewMore,
    required this.onLogoTap,
  });

  @override
  State<AutoScrollSectorList> createState() => _AutoScrollSectorListState();
}

class _AutoScrollSectorListState extends State<AutoScrollSectorList> {
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;

  static const _scrollStep = 300.0; // approx card width + separator
  static const _tickInterval = Duration(seconds: 3);
  static const _scrollAnimDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    if (!mounted) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_tickInterval, (_) {
      if (!_scrollController.hasClients) return;

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      final current = _scrollController.offset;

      if (current >= maxExtent - 1) {
        // Loop back to start
        _scrollController.animateTo(
          0,
          duration: _scrollAnimDuration,
          curve: Curves.easeInOut,
        );
      } else {
        final next = (current + _scrollStep).clamp(0.0, maxExtent);
        _scrollController.animateTo(
          next,
          duration: _scrollAnimDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseAndResumeLater() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 4), _startAutoScroll);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          (widget.isPhone ? 128 : 160) +
          ((MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 3.0) -
                  1) *
              90,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // If the user manually drags, pause auto-scroll and resume after a delay
          if (notification is UserScrollNotification &&
              notification.direction != ScrollDirection.idle) {
            _pauseAndResumeLater();
          }
          return false;
        },
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: widget.isPhone ? 12 : 20),
          itemCount: widget.sectors.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            var model = widget.sectors[index];
            return Clickable(
              onTap: model.slug.isEmpty ? null : () => widget.onViewMore(model),
              child: SectorCard(
                icon: model.iconImage,
                sectorName: model.name,
                companyCount: model.companyCount,
                logos: model.companies,
                onViewMore: () => widget.onViewMore(model),
                onLogoTap: (company) => widget.onLogoTap(model, company),
              ),
            );
          },
        ),
      ),
    );
  }
}
