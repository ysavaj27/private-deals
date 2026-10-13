import 'package:private_deals/src/shared/app_exports.dart';

class SellerProfileWidget extends StatelessWidget {
  final SharePriceSellerModel seller;
  final String label;

  /// When true, show partner.profile fields (deal dialog / invest panel).
  final bool showDetails;

  const SellerProfileWidget({
    super.key,
    required this.seller,
    this.label = 'Seller',
    this.showDetails = false,
  });

  bool get _canLoadLogo {
    final logo = seller.logo.trim();
    if (logo.isEmpty) return false;
    // CachedNetworkImage does not render SVG placeholders.
    if (logo.toLowerCase().endsWith('.svg')) return false;
    return true;
  }

  Widget _fallbackAvatar(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: const Icon(Icons.business_outlined, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = seller.companyName.isNotEmpty ? seller.companyName : label;
    final profile = seller.profile;
    final colors = Theme.of(context).colorScheme;

    final identity = Row(
      children: [
        if (_canLoadLogo)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CacheImage(
              url: seller.logo,
              height: 40,
              width: 40,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => _fallbackAvatar(context),
              imageBuilder: (context, imageProvider) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor(context)),
                    color: AppColors.logoBgColor(context),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          )
        else
          _fallbackAvatar(context),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: showDetails ? null : 2,
                overflow: showDetails ? null : TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showDetails && profile.verifiedStatus.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  profile.verifiedStatus,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDetails && profile.hasStats)
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
              if (constraints.maxWidth >= 700 * scale) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: identity),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: _ProfileStats(profile: profile)),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  const SizedBox(height: 20),
                  _ProfileStats(profile: profile),
                ],
              );
            },
          )
        else
          identity,
        if (showDetails && !profile.isEmpty) ...[
          if (profile.companiesPreviouslyListed.isNotEmpty ||
              profile.geographicPresence.isNotEmpty) ...[
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final details = [
                  if (profile.companiesPreviouslyListed.isNotEmpty)
                    _ProfileDetail(
                      key: const ValueKey('profile-companies'),
                      icon: Icons.business_outlined,
                      label: 'Companies transacted',
                      value: profile.companiesPreviouslyListed,
                    ),
                  if (profile.geographicPresence.isNotEmpty)
                    _ProfileDetail(
                      key: const ValueKey('profile-presence'),
                      icon: Icons.location_on_outlined,
                      label: 'Geographic presence',
                      value: profile.geographicPresence,
                    ),
                ];
                final columns =
                    constraints.maxWidth >= 600 &&
                        MediaQuery.textScalerOf(context).scale(14) <= 20
                    ? details.length
                    : 1;
                final width =
                    (constraints.maxWidth - (columns - 1) * 16) / columns;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final detail in details)
                      SizedBox(width: width, child: detail),
                  ],
                );
              },
            ),
          ],
          if (profile.approach.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ProfileDetail(
              key: const ValueKey('profile-approach'),
              icon: Icons.notes_rounded,
              label: 'Our approach',
              value: profile.approach,
            ),
          ],
        ],
      ],
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({required this.profile});
  final PartnerPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final stats = [
      if (profile.yearsOfExperience.isNotEmpty)
        _ProfileStat(
          label: 'Years of experience',
          value: profile.yearsOfExperience,
        ),
      if (profile.totalTradesExecuted.isNotEmpty)
        _ProfileStat(
          label: 'Trades executed',
          value: profile.totalTradesExecuted,
        ),
      if (profile.totalInvestorBase.isNotEmpty)
        _ProfileStat(label: 'Investor base', value: profile.totalInvestorBase),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final columns = (constraints.maxWidth / (140 * scale)).floor().clamp(
          1,
          stats.length,
        );
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final stat in stats) SizedBox(width: width, child: stat),
          ],
        );
      },
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.22,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatefulWidget {
  const _ProfileDetail({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  State<_ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<_ProfileDetail> {
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant _ProfileDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bodyStyle = theme.textTheme.bodyMedium!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 18, color: colors.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.label, style: theme.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Profile fields are free-form strings: preserve their line breaks
              // and prose instead of guessing whether commas separate entries.
              final painter = TextPainter(
                text: TextSpan(text: widget.value, style: bodyStyle),
                maxLines: 4,
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                locale: Localizations.maybeLocaleOf(context),
              )..layout(maxWidth: constraints.maxWidth);
              final overflows = painter.didExceedMaxLines;
              painter.dispose();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.value,
                    maxLines: _expanded ? null : 4,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: bodyStyle,
                  ),
                  if (overflows)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        expanded: _expanded,
                        child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(48, 44),
                          ),
                          iconAlignment: IconAlignment.end,
                          icon: Icon(
                            _expanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                          ),
                          label: Text(_expanded ? 'Show less' : 'Show more'),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
