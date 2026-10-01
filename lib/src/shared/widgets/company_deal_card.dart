import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';

/// Deal / company row for Pre-IPO, Secondary, and Primary lists.
/// Wire real fields in Waves 1–2; Phase 0 ships the layout contract only.
class CompanyDealCard extends StatelessWidget {
  const CompanyDealCard({
    super.key,
    required this.name,
    this.logo,
    this.price,
    this.changePercent,
    this.sector,
    this.badge,
    this.onTap,
  });

  final String name;
  final Widget? logo;
  final String? price;
  final String? changePercent;
  final String? sector;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final change = changePercent?.trim();
    final isUp = change != null &&
        change.isNotEmpty &&
        !change.startsWith('-') &&
        change != '0' &&
        change != '0%';
    final isDown = change != null && change.startsWith('-');

    final child = CustomCardWidget(
      padding: AppSpace.paddingMd,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.smAll,
            child: SizedBox(
              width: 48,
              height: 48,
              child: logo ??
                  ColoredBox(
                    color: colors.primaryContainer,
                    child: Icon(Icons.business, color: colors.primary),
                  ),
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                    ),
                    if (badge != null && badge!.isNotEmpty) ...[
                      const SizedBox(width: AppSpace.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.secondaryContainer,
                          borderRadius: AppRadii.smAll,
                        ),
                        child: Text(
                          badge!,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (sector != null && sector!.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    sector!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (price != null || change != null) ...[
                  const SizedBox(height: AppSpace.xs),
                  Row(
                    children: [
                      if (price != null)
                        Text(
                          price!,
                          style: textTheme.labelLarge,
                        ),
                      if (price != null && change != null)
                        const SizedBox(width: AppSpace.sm),
                      if (change != null)
                        Text(
                          change,
                          style: textTheme.labelMedium?.copyWith(
                            color: isDown
                                ? colors.error
                                : isUp
                                    ? const Color(0xFF059669)
                                    : colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.lgAll,
      child: child,
    );
  }
}
