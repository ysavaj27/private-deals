import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_progressbar.dart';

/// Shared shell for PE / LP Secondary transaction cards.
class TransactionCardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const TransactionCardShell({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Container(
      width: width,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class TransactionTypeBadge extends StatelessWidget {
  final String label;
  final bool isBuy;

  const TransactionTypeBadge({
    super.key,
    required this.label,
    this.isBuy = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final bg = isBuy ? colors.primaryContainer : colors.surfaceContainerHigh;
    final fg = isBuy ? colors.onPrimaryContainer : colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class TransactionCardHeader extends StatelessWidget {
  final String logoUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? badge;
  final VoidCallback? onLogoTap;
  final double logoSize;

  const TransactionCardHeader({
    super.key,
    required this.logoUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badge,
    this.onLogoTap,
    this.logoSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: LogoImage(
            url: logoUrl,
            radius: 12,
            height: logoSize,
            width: logoSize,
            onTap: onLogoTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: logoSize >= 56 ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  height: 1.25,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (badge != null) ...[
                const SizedBox(height: 8),
                badge!,
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class TransactionMetricChip extends StatelessWidget {
  final String label;
  final String value;

  const TransactionMetricChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionMetricRow extends StatelessWidget {
  final List<({String label, String value})> metrics;

  const TransactionMetricRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          TransactionMetricChip(label: metrics[i].label, value: metrics[i].value),
        ],
      ],
    );
  }
}

class TransactionInfoTile extends StatelessWidget {
  final String label;
  final Widget child;
  final IconData icon;

  const TransactionInfoTile({
    super.key,
    required this.label,
    required this.child,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: colors.onSurfaceVariant,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionStatusRow extends StatelessWidget {
  final String currentStatus;
  final Widget nextStep;
  final bool stacked;

  const TransactionStatusRow({
    super.key,
    required this.currentStatus,
    required this.nextStep,
    this.stacked = false,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      TransactionInfoTile(
        label: 'Current Status',
        icon: Icons.flag_outlined,
        child: Text(currentStatus),
      ),
      TransactionInfoTile(
        label: 'Next Step',
        icon: Icons.arrow_forward_outlined,
        child: nextStep,
      ),
    ];

    if (stacked) {
      return Column(
        children: [
          Row(children: [tiles[0]]),
          const SizedBox(height: 8),
          Row(children: [tiles[1]]),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tiles[0],
          const SizedBox(width: 8),
          tiles[1],
        ],
      ),
    );
  }
}

class TransactionProgressSection extends StatelessWidget {
  final double percentage;
  final bool compact;

  const TransactionProgressSection({
    super.key,
    required this.percentage,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final pct = percentage.clamp(0, 100);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomProgressBar(
            progress: pct / 100,
            height: compact ? 10 : 12,
            radius: 8,
            backgroundColor: colors.surfaceContainerHighest,
            gradientColors: [
              colors.primary.withValues(alpha: 0.55),
              colors.primary,
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionAmountLabel extends StatelessWidget {
  final String amount;
  final String? caption;

  const TransactionAmountLabel({
    super.key,
    required this.amount,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (caption != null)
          Text(
            caption!,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class TransactionExpireTimer extends StatelessWidget {
  final DateTime expiredAt;
  final Color progressColor;

  const TransactionExpireTimer({
    super.key,
    required this.expiredAt,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return SizedBox(
      height: 56,
      width: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 56,
            child: CircularProgressIndicator(
              value: expiredAt.progress(),
              color: progressColor,
              strokeCap: StrokeCap.round,
              strokeWidth: 4,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(
                  text: '${expiredAt.timeRemainingValue}\n',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: expiredAt.timeRemainingUnit,
                  style: TextStyle(
                    fontSize: 9,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionLinkAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const TransactionLinkAction({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: context.theme.colorScheme.primary,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: context.theme.colorScheme.primary,
        ),
      ),
    );
  }
}
