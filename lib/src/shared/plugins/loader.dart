import 'package:flutter/material.dart';

/// The same thin circular loading indicator used by Seller.
class Loader extends StatelessWidget {
  const Loader({
    super.key,
    this.size = 36,
    this.color,
    this.centered = true,
  });

  final double size;
  final Color? color;

  /// When true (default), wraps the spinner in [Center] for page/section loaders.
  /// Pass false for inline/button use so the spinner does not expand to max width.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: 1, color: color),
    );
    return centered ? Center(child: indicator) : indicator;
  }
}
