import 'package:private_deals/src/shared/widgets/image_placeholder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class CacheImage extends StatelessWidget {
  final String url;
  final String placeHolderImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final WidgetBuilder? placeholderBuilder;

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
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return SizedBox(
        width: width,
        height: height,
        child:
            errorWidget?.call(
              context,
              url,
              const FormatException('Empty image URL'),
            ) ??
            placeholderBuilder?.call(context) ??
            ImagePlaceholder(asset: placeHolderImage),
      );
    }
    return CachedNetworkImage(
      // A recycled list item must not retain another company's image state.
      key: ValueKey(url),
      // Decode bytes instead of retaining an HTML image element. On web the
      // latter can render stale/black textures after scrolling and eviction.
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
      width: width,
      height: height,
      fit: fit,
      imageUrl: url,
      color: color,
      imageBuilder: imageBuilder,
      // memCacheHeight: height?.toInt(),
      // memCacheWidth: width?.toInt(),
      placeholder: (context, url) {
        if (placeholderBuilder != null) return placeholderBuilder!(context);
        if (placeHolderImage.isNotEmpty) {
          return ImagePlaceholder(asset: placeHolderImage);
        }
        return Loader(color: context.theme.primaryColor, size: 40);
      },
      errorWidget:
          errorWidget ??
          (context, url, error) {
            logger.e(error);
            if (placeHolderImage.isNotEmpty) {
              return ImagePlaceholder(asset: placeHolderImage);
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
  final void Function()? onTap;
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

    Widget fallback() =>
        ImagePlaceholder(asset: placeHolderImage, isLogo: true);

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
                      placeholderBuilder: (_) => fallback(),
                      imageBuilder: imageBuilder,
                      errorWidget: (_, _, error) {
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
