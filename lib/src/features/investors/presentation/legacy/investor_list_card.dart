import 'package:flutter/material.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/constant/app_colors.dart';
import 'package:private_deals/src/shared/plugins/cache_image.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';

/// Classic investor row for wealth-manager / partner list screens.
class InvestorListCard extends StatelessWidget {
  const InvestorListCard({
    super.key,
    required this.investor,
    this.onOpenKyc,
    this.onViewPortfolio,
    this.onTap,
    this.compact = false,
  });

  final InvestorModel investor;
  final VoidCallback? onOpenKyc;
  final VoidCallback? onViewPortfolio;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isSelf = CmlApi.isSelf(investor);
    final name = investor.name.trim().isEmpty
        ? 'Unnamed'
        : investor.name.trim();
    final initial = name.substring(0, 1).toUpperCase();

    final card = CustomCardWidget(
      radius: AppRadii.lg,
      margin: EdgeInsets.only(bottom: compact ? AppSpace.md : AppSpace.lg),
      padding: EdgeInsets.all(compact ? AppSpace.lg : AppSpace.xl),
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                url: investor.profile,
                placeholder: investor.placeholderImage,
                initial: initial,
                size: compact ? 44 : 56,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.xs,
                      children: [
                        Text(
                          name,
                          style: (compact ? text.titleMedium : text.titleLarge)
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (isSelf)
                          _StatusChip(
                            label: 'My account',
                            foreground: colors.onSecondaryContainer,
                            background: colors.secondaryContainer,
                          ),
                      ],
                    ),
                    if (investor.investorType.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        investor.investorType,
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (investor.contactLine.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        investor.contactLine,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              _StatusChip(
                label: investor.isActive == 1 ? 'Active' : 'Inactive',
                foreground: investor.isActive == 1
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
                background: investor.isActive == 1
                    ? colors.primaryContainer
                    : colors.surfaceContainerLow,
              ),
              _StatusChip(
                label: investor.isPreIpoKycComplete
                    ? 'KYC complete'
                    : 'KYC pending',
                foreground: investor.isPreIpoKycComplete
                    ? colors.onSecondaryContainer
                    : colors.onSurfaceVariant,
                background: investor.isPreIpoKycComplete
                    ? colors.secondaryContainer
                    : colors.surfaceContainerLow,
              ),
              if (investor.aifStatus)
                _StatusChip(
                  label: 'AIF',
                  foreground: colors.onSecondaryContainer,
                  background: colors.secondaryContainer,
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Divider(height: 1, color: AppColors.borderColor(context)),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (onOpenKyc != null)
                TextButton.icon(
                  onPressed: investor.isPreIpoKycComplete ? null : onOpenKyc,
                  icon: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(
                    investor.isPreIpoKycComplete ? 'KYC' : 'Complete KYC',
                  ),
                ),
              if (onViewPortfolio != null)
                TextButton.icon(
                  onPressed: onViewPortfolio,
                  icon: const Icon(Icons.pie_chart_outline, size: 18),
                  label: const Text('Portfolio'),
                ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.placeholder,
    required this.initial,
    required this.size,
  });

  final String url;
  final String placeholder;
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasPhoto = url.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? CacheImage(
              url: url,
              placeHolderImage: placeholder,
              fit: BoxFit.cover,
              width: size,
              height: size,
            )
          : Center(
              child: Text(
                initial,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.smAll,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}
