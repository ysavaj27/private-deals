import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Theme-aware fallbacks, without tinting successfully loaded images.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key, this.asset = '', this.isLogo = false});

  final String asset;
  final bool isLogo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPerson = asset.contains('user_placeholder');
    final useIcon =
        asset.isEmpty ||
        isPerson ||
        asset.contains('empty_placeholder') ||
        asset.contains('empty_state_illustration');
    return ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: useIcon
            ? Icon(
                isPerson || (!isLogo && asset.isEmpty)
                    ? Icons.person_outline
                    : Icons.business_outlined,
                color: colors.onPrimaryContainer,
                size: 24,
              )
            : asset.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(asset, fit: BoxFit.contain)
            : Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.business_outlined,
                  color: colors.onPrimaryContainer,
                ),
              ),
      ),
    );
  }
}
