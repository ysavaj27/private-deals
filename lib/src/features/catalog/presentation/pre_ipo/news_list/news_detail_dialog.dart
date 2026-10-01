import 'package:url_launcher/url_launcher.dart';
import 'package:private_deals/src/shared/app_exports.dart';

Future<void> showNewsDetailBottomSheet(BuildContext context,
    {required NewsModel news}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,

    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 900),
    builder: (context) => NewsDetailBottomSheet(
      news: news,
    ),
  );
}

class NewsDetailBottomSheet extends StatelessWidget {
  const NewsDetailBottomSheet({super.key, required this.news});

  final NewsModel news;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day} ${months[local.month - 1]} ${local.year}, $hour:$minute $period';
  }

  Future<void> _openLink() async {
    final uri = Uri.parse(news.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;

    final sheetBg = scheme.surfaceContainerLow;
    final handleColor = scheme.outlineVariant;
    final titleColor = scheme.onSurface;
    final bodyColor = scheme.onSurfaceVariant;
    final mutedColor = scheme.onSurfaceVariant;
    final badgeBg = scheme.surfaceContainerHighest;
    final primaryColor = scheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.80,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 8),
                    // Image
                    SizedBox(
                      width: 800,
                      height: 400,
                      child: CacheImage(
                        url: news.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Platform badge + date
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  news.platformName,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _formatDate(news.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: mutedColor, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Title
                          Text(
                            news.title,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Description
                          Text(
                            news.description,
                            style: TextStyle(
                              color: bodyColor,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Fixed bottom CTA (stays visible, doesn't scroll with content)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _openLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Read full article',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.north_east, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
