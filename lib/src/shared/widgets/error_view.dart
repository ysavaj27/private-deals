import 'package:private_deals/src/shared/app_exports.dart';

/// Shared error / retry surface for failed loads.
class ErrorView extends StatelessWidget {
  final String title;
  final String? message;
  final void Function()? onRetry;
  final String retryLabel;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: scheme.error,
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                message!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpace.xl),
              CustomElevatedButton(
                text: retryLabel,
                radius: AppRadii.md,
                width: context.isPhone ? 140 : 200,
                height: 44,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact empty stub for nested sections (charts, financials) where a full
/// [NoDataView] illustration would overwhelm the layout.
class InlineEmptyView extends StatelessWidget {
  final String message;
  final double height;

  const InlineEmptyView({
    super.key,
    this.message = 'No data available',
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Text(
          message,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
