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
    final name =
        seller.companyName.isNotEmpty ? seller.companyName : 'Seller';
    final profile = seller.profile;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (_canLoadLogo)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CacheImage(
                  url: seller.logo,
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) =>
                      _fallbackAvatar(context),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.borderColor(context),
                        ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
        ),
        if (showDetails && !profile.isEmpty) ...[
          if (profile.hasStats) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (profile.yearsOfExperience.isNotEmpty)
                  _ProfileStat(
                    label: 'Years of Experience',
                    value: profile.yearsOfExperience,
                  ),
                if (profile.totalTradesExecuted.isNotEmpty)
                  _ProfileStat(
                    label: 'Total Trades Executed',
                    value: profile.totalTradesExecuted,
                  ),
                if (profile.totalInvestorBase.isNotEmpty)
                  _ProfileStat(
                    label: 'Total Investor Base',
                    value: profile.totalInvestorBase,
                  ),
              ],
            ),
          ],
          if (profile.companiesPreviouslyListed.isNotEmpty)
            _ProfileDetail(
              label: 'Companies Previously Listed / Transacted',
              value: profile.companiesPreviouslyListed,
            ),
          if (profile.geographicPresence.isNotEmpty)
            _ProfileDetail(
              label: 'Cities / Geographic Presence',
              value: profile.geographicPresence,
            ),
          if (profile.approach.isNotEmpty)
            _ProfileDetail(
              label: 'How We Do It / Our Approach',
              value: profile.approach,
            ),
        ],
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, height: 1.35)),
        ],
      ),
    );
  }
}
