import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';

/// Compact metric tile — Dashboard, Earnings, Portfolio summary.
class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.delta,
    this.deltaPositive,
    this.onTap,
    this.width,
  });

  final String title;
  final String value;
  final String? delta;
  final bool? deltaPositive;
  final VoidCallback? onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color? deltaColor;
    if (delta != null && deltaPositive != null) {
      deltaColor = deltaPositive!
          ? const Color(0xFF059669)
          : colors.error;
    }

    final child = CustomCardWidget(
      width: width,
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (delta != null) ...[
            const SizedBox(height: AppSpace.xs),
            Text(
              delta!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: deltaColor ?? colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
