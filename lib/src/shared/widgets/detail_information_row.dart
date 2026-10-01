import 'package:flutter/material.dart';

/// Readable company facts, including long identifiers on narrow screens.
class DetailInformationRow extends StatelessWidget {
  const DetailInformationRow(
      {super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labelWidget = Text(label,
        style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant, fontWeight: FontWeight.w500));
    final valueWidget = SelectableText(value.trim().isEmpty ? '—' : value,
        style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface, fontWeight: FontWeight.w600, height: 1.5));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 340) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [labelWidget, const SizedBox(height: 6), valueWidget]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 5, child: labelWidget),
          const SizedBox(width: 20),
          Expanded(flex: 6, child: valueWidget),
        ]);
      }),
    );
  }
}
