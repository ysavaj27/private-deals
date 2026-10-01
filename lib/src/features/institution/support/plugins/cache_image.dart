import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';

import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/features/institution/support/plugins/svg_image.dart';

class CacheImage extends StatelessWidget {
  final String url;
  final String placeHolderImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  const CacheImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.placeHolderImage = '',
    this.imageBuilder,
    this.color,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: width,
      height: height,
      fit: fit,
      imageUrl: url,
      color: color,
      imageBuilder: imageBuilder,
      // memCacheHeight: height?.toInt(),
      // memCacheWidth: width?.toInt(),
      placeholder: (context, url) {
        if (placeHolderImage.isNotEmpty) {
          return SVGImage(placeHolderImage);
        }
        return SpinKitRipple(color: context.theme.primaryColor, size: 40);
      },
      errorWidget:
          errorWidget ??
          (context, url, error) {
            if (placeHolderImage.isNotEmpty) {
              return SVGImage(placeHolderImage);
            } else {
              return const SizedBox();
            }
          },
    );
  }
}

class LogoImage extends StatelessWidget {
  final String url;
  final String placeHolderImage;
  final double? width;
  final double radius;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final VoidCallback? onTap;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;

  const LogoImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 6,
    this.fit,
    this.placeHolderImage = '',
    this.imageBuilder,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(radius);
    final effectiveFit = fit ?? BoxFit.contain;

    Widget fallback() {
      final icon = Icon(
        Icons.business_outlined,
        color: colors.primary,
        size: 24,
      );

      if (placeHolderImage.isEmpty) {
        return Center(child: icon);
      }

      return Image.asset(
        placeHolderImage,
        fit: effectiveFit,
        errorBuilder: (_, __, ___) => Center(child: icon),
      );
    }

    return SizedBox(
      width: width ?? 48,
      height: height ?? 48,
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: url.trim().isEmpty
                  ? fallback()
                  : CacheImage(
                      url: url.trim(),
                      color: color,
                      fit: effectiveFit,
                      placeHolderImage: placeHolderImage,
                      imageBuilder: imageBuilder,
                      errorWidget: (_, __, error) {
                        logger.e('Unable to load company logo', error: error);
                        return fallback();
                      },
                    ),
            ),
            // Keeps touch and hover feedback visible above the image.
            Material(
              type: MaterialType.transparency,
              child: InkWell(borderRadius: borderRadius, onTap: onTap),
            ),
          ],
        ),
      ),
    );
  }
}
