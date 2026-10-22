import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';

/// Shared page title + subtitle used at the top of workspace screens.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppSpace.xs),
          Text(
            subtitle!,
            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );

    if (trailing == null) return heading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: AppSpace.sm),
        trailing!,
      ],
    );
  }
}
