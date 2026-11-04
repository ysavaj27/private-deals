import 'package:private_deals/src/shared/app_exports.dart';

/// Image-led startup cards with reserved content slots for consistent heights.
class PrimaryStartupCard extends StatelessWidget {
  const PrimaryStartupCard({
    super.key,
    required this.round,
    this.comingSoon = false,
  });
  final StartupRoundModel round;
  final bool comingSoon;

  static double heightFor(BuildContext context) =>
      450 +
      ((MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 3.0) - 1) *
          230;

  bool get _preview =>
      comingSoon ||
      round.type == StartupStatusEnum.comingsoon ||
      (round.roundStatus.isNotEmpty &&
          round.roundStatus ==
              app.config.enumValues.startupPrimaryRoundStatus.comingsoon);

  void _open() {
    final startup = round.startup;
    if (_preview && startup.cms.pitchVideo.trim().isNotEmpty) {
      showCustomDialog(VideoPlayerScreen(url: startup.cms.pitchVideo));
    } else if (startup.urlSlug.isNotEmpty) {
      Get.toNamed(
        Routes.primaryDetailPath(
          Routes.catalogPath(WTabBarEnum.primary.slug),
          startup.urlSlug,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final startup = round.startup;
    final terms = startup.raisingRound;
    final scale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(
      1.0,
      3.0,
    );
    final hasVideo = _preview && startup.cms.pitchVideo.trim().isNotEmpty;
    final canOpen = hasVideo || startup.urlSlug.isNotEmpty;
    final price = round.sharePrice > 0 ? round.sharePrice : terms.sharePrice;
    final metrics = <(String, String)>[
      if (terms.totalFundRequirement > 0 && terms.totalFundRequirement.isFinite)
        ('Round size', terms.totalFundRequirement.toFormattedPrice),
      if (price > 0 && price.isFinite) ('Share price', price.toFormattedPrice),
      if (terms.minimumInvestment > 0 && terms.minimumInvestment.isFinite)
        ('Min. investment', terms.minimumInvestment.toFormattedPrice),
      if (startup.investorCount > 0) ('Investors', '${startup.investorCount}'),
    ].take(3).toList();
    return SizedBox(
      height: heightFor(context),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canOpen ? _open : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (startup.cms.banner.isNotEmpty)
                      CacheImage(url: startup.cms.banner, fit: BoxFit.cover)
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.primary.withValues(alpha: .22),
                              colors.surfaceContainerHighest,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          size: 60,
                          color: colors.primary.withValues(alpha: .5),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 12,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (round.roundStatus.isNotEmpty ||
                              terms.roundStatus.isNotEmpty)
                            _BannerBadge(
                              label: round.roundStatus.isNotEmpty
                                  ? round.roundStatus
                                  : terms.roundStatus,
                            ),
                          if (terms.instrument.isNotEmpty)
                            _BannerBadge(label: terms.instrument.toUpperCase()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 64 * scale,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.control,
                                ),
                              ),
                              child: startup.cms.logo.isEmpty
                                  ? Icon(
                                      Icons.business_outlined,
                                      color: colors.onSurfaceVariant,
                                    )
                                  : CacheImage(
                                      url: startup.cms.logo,
                                      fit: BoxFit.contain,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    startup.brandName.isEmpty
                                        ? startup.companyName
                                        : startup.brandName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      startup.sector.name,
                                      startup.city.name,
                                    ].where((v) => v.isNotEmpty).join(' · '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 42 * scale,
                        child: Text(
                          startup.briefInformation,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      SizedBox(
                        height: 60 * scale,
                        child: metrics.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Round details are not available yet.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var i = 0; i < metrics.length; i++) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            metrics[i].$1,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color:
                                                      colors.onSurfaceVariant,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            metrics[i].$2,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hasVideo ? 'Watch pitch' : 'View startup',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: canOpen
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            hasVideo
                                ? Icons.play_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                            color: canOpen
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ],
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

class _BannerBadge extends StatelessWidget {
  const _BannerBadge({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .95),
      borderRadius: BorderRadius.circular(AppRadii.badge),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

class PrimaryCatalogBadge extends StatelessWidget {
  const PrimaryCatalogBadge({
    super.key,
    required this.label,
    this.muted = false,
  });
  final String label;
  final bool muted;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: muted
            ? colors.surfaceContainerHighest
            : colors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppRadii.badge),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: muted ? colors.onSurfaceVariant : colors.primary),
      ),
    );
  }
}

/// Builds only visible startup cards, with equal heights at every text scale.
class PrimaryCatalogSliverGrid extends StatelessWidget {
  const PrimaryCatalogSliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) => SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ((constraints.crossAxisExtent + 16) / 346)
            .floor()
            .clamp(1, 4),
        mainAxisExtent: PrimaryStartupCard.heightFor(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
    ),
  );
}

class PrimaryCatalogState extends StatelessWidget {
  const PrimaryCatalogState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            onRetry == null ? Icons.search_rounded : Icons.cloud_off_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    ),
  );
}
