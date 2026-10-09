import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_motion.dart';

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
    final duration = AppMotion.duration(context, AppMotion.fast);

    // Builder reads the foreground style provided by the button.
    final child = Builder(
      builder: (buttonContext) {
        final content = isLoading
            ? Semantics(
                key: const ValueKey('loading'),
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
              )
            : KeyedSubtree(
                key: const ValueKey('label'),
                child: icon == null
                    ? Text(label)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 20),
                          const SizedBox(width: 8),
                          Flexible(child: Text(label)),
                        ],
                      ),
              );

        return AnimatedSwitcher(
          duration: duration,
          switchInCurve: AppMotion.easeOut,
          switchOutCurve: AppMotion.easeInOut,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: content,
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
