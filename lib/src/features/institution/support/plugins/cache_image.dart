import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:private_deals/src/shared/plugins/cache_image.dart' as shared;

export 'package:private_deals/src/shared/plugins/cache_image.dart'
    show LogoImage;

/// Retains Institution's ripple loader while sharing URL and cache handling.
class CacheImage extends shared.CacheImage {
  const CacheImage({
    super.key,
    required super.url,
    super.width,
    super.height,
    super.fit,
    super.placeHolderImage,
    super.imageBuilder,
    super.color,
    super.errorWidget,
    super.placeholderBuilder,
  });

  @override
  Widget buildLoadingIndicator(BuildContext context) =>
      SpinKitRipple(color: Theme.of(context).primaryColor, size: 40);
}
