import 'package:flutter/material.dart';

class Clickable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final void Function(bool)? onHover;

  const Clickable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: borderRadius,
      onTap: onTap,
      onHover: onHover,
      child: child,
    );
  }
}
