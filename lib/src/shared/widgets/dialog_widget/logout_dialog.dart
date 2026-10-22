import 'package:private_deals/src/shared/app_exports.dart';

class LogoutDialog extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? primaryText;
  final String? secondaryText;
  final void Function()? onPressed;

  const LogoutDialog({
    super.key,
    required this.onPressed,
    this.title,
    this.subTitle,
    this.primaryText,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final text = context.textTheme;
    final compact = context.isPhone;

    return CustomCardWidget(
      color: colors.surfaceContainerLow,
      radius: AppRadii.lg,
      borderColor: colors.outlineVariant,
      padding: EdgeInsets.all(compact ? AppSpace.xl : AppSpace.xxl),
      child: SizedBox(
        width: compact ? double.infinity : 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Sign out',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        subTitle ??
                            'Are you sure you want to sign out of this account?',
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    child: Text(secondaryText ?? 'Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: FilledButton(
                    onPressed: onPressed == null
                        ? null
                        : () {
                            Analytics.tap('logout_confirm');
                            onPressed!();
                          },
                    child: Text(primaryText ?? 'Sign out'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
