import 'package:flutter/material.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';
import 'package:private_deals/src/shared/theme/app_motion.dart';

class Clickable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final void Function(bool)? onHover;

  /// When false, skips press scale (useful for dense controls).
  final bool enablePressScale;

  /// Stable analytics name. When set, logs [Analytics.tap] on press.
  final String? analyticsName;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.onHover,
    this.enablePressScale = true,
    this.analyticsName,
  });

  @override
  State<Clickable> createState() => _ClickableState();
}

class _ClickableState extends State<Clickable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enablePressScale || widget.onTap == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.fast);
    return AnimatedScale(
      scale: _pressed ? AppMotion.pressScale : 1,
      duration: duration,
      curve: AppMotion.easeOut,
      alignment: Alignment.center,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: widget.borderRadius,
        onTap: widget.onTap == null
            ? null
            : () {
                final name = widget.analyticsName;
                if (name != null && name.isNotEmpty) {
                  Analytics.tap(name);
                }
                widget.onTap!();
              },
        onHover: widget.onHover,
        onTapDown:
            widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: widget.child,
      ),
    );
  }
}
