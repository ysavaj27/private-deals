import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_appbar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<BaseModel<List<NotificationModel>>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationApi.wNotificationList();
  }

  Future<void> _reload() async {
    setState(() {
      _future = NotificationApi.wNotificationList();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const PhoneAppBar(title: 'Notifications'),
      body: NotificationListBody(
        future: _future,
        onRefresh: _reload,
        compact: false,
      ),
    );
  }
}

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  late Future<BaseModel<List<NotificationModel>>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationApi.wNotificationList();
  }

  Future<void> _reload() async {
    setState(() {
      _future = NotificationApi.wNotificationList();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final textTheme = context.textTheme;

    return Drawer(
      backgroundColor: colors.surface,
      width: 420,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(AppRadii.xl)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.xl,
                AppSpace.lg,
                AppSpace.md,
                AppSpace.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: AppRadii.mdAll,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: colors.onPrimaryContainer,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Updates from your workspace',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: NotificationListBody(
                future: _future,
                onRefresh: _reload,
                compact: true,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.lg,
                  AppSpace.lg,
                  AppSpace.lg,
                  AppSpace.xl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared list shell for phone page and desktop drawer.
class NotificationListBody extends StatelessWidget {
  const NotificationListBody({
    super.key,
    required this.future,
    required this.onRefresh,
    this.compact = false,
    this.padding = const EdgeInsets.all(AppSpace.lg),
  });

  final Future<BaseModel<List<NotificationModel>>> future;
  final Future<void> Function() onRefresh;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BaseModel<List<NotificationModel>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: onRefresh,
          );
        }

        final response = snapshot.data;
        if (response == null) {
          return ErrorView(
            message: 'Unable to load notifications.',
            onRetry: onRefresh,
          );
        }

        if (!response.isSuccess) {
          return ErrorView(
            message: response.m.isNotEmpty
                ? response.m
                : 'Unable to load notifications.',
            onRetry: onRefresh,
          );
        }

        final items = response.r ?? const <NotificationModel>[];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              children: const [
                SizedBox(
                  height: 420,
                  child: NoDataView(
                    title: 'No notifications',
                    subtitle: 'You are all caught up.',
                    isRefreshButton: false,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.separated(
            itemCount: items.length,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: padding,
            itemBuilder: (context, index) {
              return NotificationTile(
                model: items[index],
                compact: compact,
                index: index,
              );
            },
            separatorBuilder: (_, _) => SizedBox(
              height: compact ? AppSpace.md : AppSpace.sm + 2,
            ),
          ),
        );
      },
    );
  }
}

class NotificationTile extends StatefulWidget {
  const NotificationTile({
    super.key,
    required this.model,
    this.compact = false,
    this.index = 0,
  });

  final NotificationModel model;
  final bool compact;
  final int index;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final textTheme = context.textTheme;
    final model = widget.model;
    final body = model.body.trim();
    final isLong = body.length > 140;
    final showMedia = model.hasImage;

    final tile = CustomCardWidget(
      radius: AppRadii.lg,
      color: colors.surfaceContainerLow,
      borderColor: colors.outlineVariant.withValues(alpha: 0.65),
      padding: EdgeInsets.all(widget.compact ? AppSpace.lg : AppSpace.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationLeading(
                imageUrl: model.image,
                recent: model.isRecent,
                size: widget.compact ? 48 : 44,
              ),
              SizedBox(width: widget.compact ? AppSpace.lg : AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            model.title.trim().isEmpty
                                ? 'Notification'
                                : model.title.trim(),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                              fontSize: widget.compact ? 16 : 14.5,
                            ),
                          ),
                        ),
                        if (model.isRecent) ...[
                          const SizedBox(width: AppSpace.sm),
                          _NewBadge(),
                        ],
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        body,
                        maxLines: _expanded ? null : (widget.compact ? 3 : 3),
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                          fontSize: widget.compact ? 14 : 13,
                        ),
                      ),
                      if (isLong)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.xs),
                          child: Clickable(
                            onTap: () => setState(() => _expanded = !_expanded),
                            child: Text(
                              _expanded ? 'Show less' : 'Show more',
                              style: textTheme.labelLarge?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            model.createdAt.timeAgo,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.sm,
                          ),
                          child: Text(
                            '·',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          model.createdAt.dateWithMonthYear,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showMedia) ...[
            const SizedBox(height: AppSpace.md),
            ClipRRect(
              borderRadius: AppRadii.mdAll,
              child: AspectRatio(
                aspectRatio: widget.compact ? 16 / 7 : 16 / 9,
                child: CacheImage(
                  url: model.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholderBuilder: (_) => ColoredBox(
                    color: colors.surfaceContainer,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: colors.surfaceContainer,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return AppFadeIn(
      duration: Duration(
        milliseconds: 160 + (widget.index.clamp(0, 6) * 30),
      ),
      child: tile,
    );
  }
}

class _NotificationLeading extends StatelessWidget {
  const _NotificationLeading({
    required this.imageUrl,
    required this.recent,
    required this.size,
  });

  final String imageUrl;
  final bool recent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final hasImage = imageUrl.trim().isNotEmpty;
    final radius = BorderRadius.circular(AppRadii.md);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: hasImage ? colors.surfaceContainer : colors.primaryContainer,
            borderRadius: radius,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? CacheImage(
                  url: imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => _IconFallback(colors: colors),
                  errorWidget: (context, url, error) =>
                      _IconFallback(colors: colors),
                )
              : _IconFallback(colors: colors),
        ),
        if (recent)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _IconFallback extends StatelessWidget {
  const _IconFallback({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.notifications_rounded,
          size: 22,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        'New',
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
