import 'package:private_deals/src/shared/app_exports.dart';

/// Shared section title + optional action for deal landings and details.
class DealSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const DealSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Responsive carousel height for phone landings (replaces fixed 347).
class DealCarouselSlot extends StatelessWidget {
  final Widget child;
  final double aspectRatio;

  const DealCarouselSlot({
    super.key,
    required this.child,
    this.aspectRatio = 1.1,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = (width / aspectRatio).clamp(260.0, 400.0);
    return SizedBox(height: height, child: child);
  }
}

/// Compact card chrome aligned to theme surfaces.
class DealSurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const DealSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Clickable(
      onTap: onTap,
      borderRadius: AppRadii.lgAll,
      child: card,
    );
  }
}
