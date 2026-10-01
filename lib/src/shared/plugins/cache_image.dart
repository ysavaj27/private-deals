import 'package:cached_network_image/cached_network_image.dart';
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
        return Loader(color: context.theme.primaryColor, size: 40);
      },
      errorWidget: errorWidget ??
          (context, url, error) {
            logger.e(error);
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
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: CacheImage(
        url: url,
        color: color,
        width: width,
        height: height,
        fit: BoxFit.cover,
        imageBuilder: (p0, p1) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor(p0)),
              color: AppColors.logoBgColor(context),
              borderRadius: BorderRadius.circular(radius),
              image: DecorationImage(image: p1, fit: fit),
            ),
          );
        },
        // imageBuilder: imageBuilder,
        placeHolderImage: placeHolderImage,
      ),
    );
  }
}
