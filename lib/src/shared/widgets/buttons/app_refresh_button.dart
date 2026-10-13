import 'package:flutter/material.dart';

/// Shared page-header refresh control used across workspaces.
class AppRefreshButton extends StatelessWidget {
  const AppRefreshButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Refresh',
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String tooltip;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: loading ? null : onPressed,
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
