import 'package:private_deals/src/shared/app_exports.dart';

import 'dashboard_insights.dart';

class DashboardPanel extends StatelessWidget {
  const DashboardPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCardWidget(
      padding: const EdgeInsets.all(22),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (trailing != null) ...[const SizedBox(height: 14), trailing!],
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardEmpty extends StatelessWidget {
  const DashboardEmpty({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.insert_chart_outlined_rounded,
  });
  final String title;
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardAmount extends StatelessWidget {
  const DashboardAmount(
    this.amount, {
    super.key,
    this.style,
    this.signed = false,
  });
  final num amount;
  final TextStyle? style;
  final bool signed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message:
        '${signed && amount > 0 ? '+' : ''}${dashboardMoney(amount, full: true)}',
    child: Text(
      '${signed && amount > 0 ? '+' : ''}${dashboardMoney(amount)}',
      style: style,
    ),
  );
}

class DashboardLegend extends StatelessWidget {
  const DashboardLegend({super.key, required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
    ],
  );
}

class DashboardBar extends StatelessWidget {
  const DashboardBar({
    super.key,
    required this.fraction,
    required this.color,
    required this.label,
    this.height = 8,
  });
  final double fraction;
  final Color color;
  final String label;
  final double height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    ),
  );
}
