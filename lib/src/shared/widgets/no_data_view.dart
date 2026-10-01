import 'package:private_deals/src/shared/app_exports.dart';

class NoDataView extends StatelessWidget {
  final void Function()? onPressed;
  final bool isRefreshButton;
  final String title;
  final String? subtitle;

  const NoDataView({
    super.key,
    this.onPressed,
    this.isRefreshButton = true,
    this.title = 'No Data Found',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final showRefresh = isRefreshButton && onPressed != null;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SVGImage(
              AppAssets.emptyPlaceHolder,
              height: context.height * 0.28,
            ),
            const SizedBox(height: AppSpace.xl),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              subtitle ??
                  (showRefresh
                      ? 'There is no data right now. You can refresh below.'
                      : 'There is no data right now.'),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRefresh) ...[
              const SizedBox(height: AppSpace.lg),
              CustomElevatedButton(
                text: 'Refresh',
                radius: AppRadii.full,
                width: context.isPhone ? 118 : 236,
                height: context.isPhone ? 38 : 56,
                fontSize: context.isPhone ? 12 : null,
                onPressed: onPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
