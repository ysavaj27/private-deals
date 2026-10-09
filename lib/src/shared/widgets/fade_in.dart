import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/app_motion.dart';

/// Soft fade-in on first appear. Layout is unchanged; opacity only.
///
/// Named [AppFadeIn] to avoid clashing with `animate_do`'s [FadeIn].
class AppFadeIn extends StatefulWidget {
  const AppFadeIn({
    super.key,
    required this.child,
    this.duration = AppMotion.normal,
    this.curve = AppMotion.easeOut,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<AppFadeIn> createState() => _AppFadeInState();
}

class _AppFadeInState extends State<AppFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final d = AppMotion.duration(context, widget.duration);
    if (_controller.duration != d) {
      _controller.duration = d;
      if (d == Duration.zero) {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
