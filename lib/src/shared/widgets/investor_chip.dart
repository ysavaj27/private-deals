import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';

/// Compact investor identity chip — lists, filters, investment flows.
class InvestorChip extends StatelessWidget {
  const InvestorChip({
    super.key,
    required this.name,
    this.avatarUrl,
    this.kycLabel,
    this.aumLabel,
    this.onTap,
    this.selected = false,
  });

  final String name;
  final String? avatarUrl;
  final String? kycLabel;
  final String? aumLabel;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final trimmed = name.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? colors.primaryContainer : colors.surface,
        borderRadius: AppRadii.pill,
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colors.secondaryContainer,
            foregroundImage:
                avatarUrl != null && avatarUrl!.isNotEmpty
                    ? NetworkImage(avatarUrl!)
                    : null,
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Text(
                    initial,
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpace.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge,
                ),
                if (kycLabel != null || aumLabel != null)
                  Text(
                    [
                      if (kycLabel != null && kycLabel!.isNotEmpty) kycLabel!,
                      if (aumLabel != null && aumLabel!.isNotEmpty) aumLabel!,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.pill,
      child: chip,
    );
  }
}
