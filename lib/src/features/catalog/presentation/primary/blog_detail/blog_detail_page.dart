import 'dart:convert';

import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import '../primary_startup_card.dart';

Future<void> showBlogDetailBottomSheet(
  BuildContext context, {
  required BlogModel blog,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  constraints: const BoxConstraints(maxWidth: 900),
  builder: (_) => DraggableScrollableSheet(
    initialChildSize: .88,
    minChildSize: .55,
    maxChildSize: .95,
    expand: false,
    builder: (context, scrollController) => ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.card),
      ),
      child: BlogArticleReader(
        slug: blog.urlSlug,
        initialBlog: blog,
        scrollController: scrollController,
        sheet: true,
      ),
    ),
  ),
);

/// Keep shared blog links usable without requiring a previous catalog page.
class BlogDetailPage extends StatelessWidget {
  const BlogDetailPage({super.key});
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
    child: Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: BlogArticleReader(slug: Get.parameters['slug'] ?? ''),
          ),
        ),
      ),
    ),
  );
}

class BlogArticleReader extends StatefulWidget {
  const BlogArticleReader({
    super.key,
    required this.slug,
    this.initialBlog,
    this.scrollController,
    this.sheet = false,
  });
  final String slug;
  final BlogModel? initialBlog;
  final ScrollController? scrollController;
  final bool sheet;
  @override
  State<BlogArticleReader> createState() => _BlogArticleReaderState();
}

class _BlogArticleReaderState extends State<BlogArticleReader> {
  BlogModel? _blog;
  bool _loading = true;
  bool _failed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant BlogArticleReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _failed = false;
      _blog = widget.initialBlog;
    });
    try {
      if (widget.slug.isEmpty) {
        if (_blog?.longDescription.isNotEmpty != true) {
          throw StateError('Missing article');
        }
      } else {
        final result = await LandingPageApi.blogDetail(slug: widget.slug);
        if (!mounted || request != _request) return;
        if (!result.isSuccess ||
            result.r == null ||
            result.r!.title.trim().isEmpty) {
          throw StateError('Article unavailable');
        }
        _blog = result.r;
      }
    } catch (_) {
      if (mounted && request == _request) _failed = true;
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _openLink(String? value) async {
    if (value == null) return;
    final uri = Uri.tryParse(value);
    if (uri == null || !['https', 'http'].contains(uri.scheme)) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      toast('This link could not be opened.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      child: Column(
        children: [
          if (widget.sheet) ...[
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: [
                Icon(Icons.article_outlined, size: 20, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Startup insights',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: widget.sheet ? 'Close article' : 'Back to startups',
                  onPressed: widget.sheet
                      ? () => Navigator.of(context).pop()
                      : onBackPressed,
                  icon: Icon(
                    widget.sheet
                        ? Icons.close_rounded
                        : Icons.arrow_back_rounded,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                if (_blog?.banner.isNotEmpty == true)
                  AspectRatio(
                    aspectRatio: 2,
                    child: CacheImage(url: _blog!.banner, fit: BoxFit.cover),
                  ),
                Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).width < 600 ? 20 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_blog != null) ...[
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const PrimaryCatalogBadge(
                              label: 'Startup insights',
                            ),
                            if (_blog!.createdAt.year > 0)
                              Text(
                                _blog!.createdAt.dateWithSortMonthYear,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _blog!.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_loading)
                        const SizedBox(height: 160, child: Loader())
                      else if (_failed)
                        PrimaryCatalogState(
                          title: 'This article is unavailable',
                          message: 'We couldn’t load the full article. Please try again.',
                          onRetry: _load,
                        )
                      else if (_blog != null)
                        Html(
                          data: _blog!.longDescription.isEmpty
                              ? '<p>${HtmlEscape().convert(_blog!.shortDescription)}</p>'
                              : _blog!.longDescription,
                          onLinkTap: (url, _, _) => _openLink(url),
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              color: colors.onSurfaceVariant,
                              fontSize: FontSize(16),
                              lineHeight: const LineHeight(1.7),
                            ),
                            'h1': Style(
                              color: colors.onSurface,
                              fontSize: FontSize(26),
                            ),
                            'h2': Style(
                              color: colors.onSurface,
                              fontSize: FontSize(22),
                            ),
                            'h3': Style(
                              color: colors.onSurface,
                              fontSize: FontSize(19),
                            ),
                            'a': Style(color: colors.primary),
                            'img': Style(
                              height: Height.auto(),
                              width: Width(100, Unit.percent),
                            ),
                          },
                        ),
                    ],
                  ),
                ),
                const SafeArea(top: false, child: SizedBox(height: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
