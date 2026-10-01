import 'package:flutter/material.dart';

/// The same thin circular loading indicator used by Seller.
class Loader extends StatelessWidget {
  const Loader({super.key, this.size = 36, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: 1, color: color),
    ),
  );
}
