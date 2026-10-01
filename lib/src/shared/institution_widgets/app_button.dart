import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final callback = isLoading ? null : onPressed;

    // Builder reads the foreground style provided by the button.
    final child = Builder(
      builder: (buttonContext) {
        if (isLoading) {
          return Semantics(
            label: '$label, loading',
            liveRegion: true,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: DefaultTextStyle.of(buttonContext).style.color,
              ),
            ),
          );
        }

        if (icon == null) return Text(label);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(label)),
          ],
        );
      },
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        style: FilledButton.styleFrom(
          backgroundColor: colors.secondaryContainer,
          foregroundColor: colors.onSecondaryContainer,
        ),
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.text => TextButton(onPressed: callback, child: child),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
