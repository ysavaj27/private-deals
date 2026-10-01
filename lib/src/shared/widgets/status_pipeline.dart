import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';

/// Status + progress + next-step CTA for Transactions / Pending Tasks.
class StatusPipeline extends StatelessWidget {
  const StatusPipeline({
    super.key,
    required this.status,
    this.nextStep,
    this.progress,
    this.onNextStep,
    this.leading,
    this.title,
    this.subtitle,
  });

  final String status;
  final String? nextStep;
  final double? progress;
  final VoidCallback? onNextStep;
  final Widget? leading;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pct = (progress ?? 0).clamp(0.0, 1.0);

    return CustomCardWidget(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpace.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: AppRadii.smAll,
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpace.md),
            ClipRRect(
              borderRadius: AppRadii.xsAll,
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHigh,
                color: colors.primary,
              ),
            ),
          ],
          if (nextStep != null && nextStep!.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNextStep,
                child: Text(nextStep!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
