import 'package:flutter/material.dart';
import 'package:private_deals/src/features/institution/support/theme/app_spacing.dart';

import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/gap.dart';
import 'package:private_deals/src/shared/widgets/fade_in.dart';

/// A centered empty-state placeholder with an optional call to action.
///
/// The counterpart to `ErrorView`: use it when a request succeeds but there is
/// simply nothing to show.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppFadeIn(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const Gap(AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.35,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const Gap(AppSpacing.lg),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
