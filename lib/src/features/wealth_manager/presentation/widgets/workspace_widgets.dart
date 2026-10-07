import 'package:private_deals/src/shared/app_exports.dart';

/// Shared responsive layout for the wealth manager's operational screens.
class WorkspacePage extends StatelessWidget {
  const WorkspacePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
    required this.loading,
    required this.header,
    required this.itemCount,
    required this.itemBuilder,
    required this.empty,
    this.error = '',
  });
  final String title, subtitle, error;
  final Future<void> Function() onRefresh;
  final bool loading;
  final List<Widget> header;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget empty;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final padding = compact ? AppSpace.lg : AppSpace.xxl;
      final colors = Theme.of(context).colorScheme;
      final text = Theme.of(context).textTheme;
      return RefreshIndicator(
        onRefresh: () async {
          if (!loading) await onRefresh();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                padding,
                AppSpace.xl,
                padding,
                AppSpace.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: text.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpace.xs),
                              Text(
                                subtitle,
                                style: text.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        IconButton.filledTonal(
                          tooltip: 'Refresh $title',
                          onPressed: loading ? null : onRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.xl),
                    ...header,
                  ],
                ),
              ),
            ),
            if (loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(64),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (error.isNotEmpty || itemCount == 0)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverToBoxAdapter(
                  child: error.isNotEmpty
                      ? WorkspaceEmpty(
                          icon: Icons.cloud_off_outlined,
                          title: 'Unable to load data',
                          message: error,
                          onRetry: onRefresh,
                        )
                      : empty,
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverList.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: itemBuilder(context, index),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpace.xxl)),
          ],
        ),
      );
    },
  );
}

class WorkspaceMetrics extends StatelessWidget {
  const WorkspaceMetrics({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 600 ? 1 : children.length;
      final width =
          (constraints.maxWidth - AppSpace.md * (columns - 1)) / columns;
      return Wrap(
        spacing: AppSpace.md,
        runSpacing: AppSpace.md,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class WorkspaceMetric extends StatelessWidget {
  const WorkspaceMetric({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.selected = false,
    this.onTap,
  });
  final String label, value;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: onTap == null ? null : selected,
      button: onTap != null,
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: AppSpace.paddingLg,
            child: Row(
              children: [
                Container(
                  padding: AppSpace.paddingMd,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.surface.withValues(alpha: .5)
                        : colors.surfaceContainerLow,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(icon, color: colors.primary, size: 22),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WorkspaceSearch extends StatelessWidget {
  const WorkspaceSearch({
    super.key,
    required this.hint,
    required this.onChanged,
  });
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search_rounded),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
    ),
    onChanged: (value) => onChanged(value.trim().toLowerCase()),
  );
}

class WorkspaceEmpty extends StatelessWidget {
  const WorkspaceEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final String title, message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => CustomCardWidget(
    padding: AppSpace.paddingXl,
    child: Column(
      children: [
        Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpace.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpace.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ],
    ),
  );
}

class WorkspaceDetail extends StatelessWidget {
  const WorkspaceDetail({super.key, required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: AppSpace.xs),
      Text(
        value.isEmpty ? '—' : value,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ],
  );
}
