import 'package:flutter/material.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';

/// Shared page-header refresh control used across workspaces.
class AppRefreshButton extends StatelessWidget {
  const AppRefreshButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Refresh',
    this.loading = false,
    this.analyticsName,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final bool loading;
  final String? analyticsName;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: loading || onPressed == null
          ? null
          : () {
              Analytics.tap(analyticsName ?? 'refresh');
              onPressed!();
            },
      icon: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}
