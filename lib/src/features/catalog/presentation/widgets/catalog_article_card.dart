import 'package:private_deals/src/shared/app_exports.dart';

/// One news-style article card for news and blogs, on landing and list pages.
class CatalogArticleCard extends StatelessWidget {
  const CatalogArticleCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.date,
    required this.onTap,
  });
  final String image;
  final String title;
  final String description;
  final DateTime date;
  final VoidCallback onTap;

  static double heightFor(BuildContext context) =>
      425 +
      ((MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 3.0) - 1) *
          210;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      height: heightFor(context),
      child: Material(
        color: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: image.isEmpty
                    ? ColoredBox(
                        color: colors.surfaceContainerHighest,
                        child: Icon(
                          Icons.article_outlined,
                          size: 40,
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    : CacheImage(url: image, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 20,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              date.year > 0
                                  ? date.dateWithMonthYear
                                  : 'Article',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onTap,
                        label: const Text('Read More'),
                        icon: const Icon(
                          Icons.arrow_forward_outlined,
                          size: 20,
                        ),
                        iconAlignment: IconAlignment.end,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
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
  }
}

class CatalogArticleCarousel extends StatelessWidget {
  const CatalogArticleCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) => SizedBox(
      height: CatalogArticleCard.heightFor(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) => SizedBox(
          width: size.maxWidth.clamp(0.0, 300.0),
          child: itemBuilder(context, index),
        ),
      ),
    ),
  );
}

class CatalogArticleGrid extends StatelessWidget {
  const CatalogArticleGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      final padding = size.maxWidth < 600 ? 20.0 : 40.0;
      final columns = ((size.maxWidth - padding * 2 + 20) / 320).floor().clamp(
        1,
        5,
      );
      return GridView.builder(
        controller: controller,
        itemCount: itemCount,
        padding: EdgeInsets.fromLTRB(padding, 12, padding, 32),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: CatalogArticleCard.heightFor(context),
        ),
        itemBuilder: itemBuilder,
      );
    },
  );
}
