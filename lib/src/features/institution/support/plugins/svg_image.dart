import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVGImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final double? height;
  final double? width;
  final ColorFilter? colorFilter;

  const SVGImage(
    this.path, {
    super.key,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      colorFilter: colorFilter,
    );
  }
}
