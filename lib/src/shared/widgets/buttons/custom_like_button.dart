import 'package:private_deals/src/shared/app_exports.dart';
import 'package:like_button/like_button.dart';

class CustomLikeButton extends StatelessWidget {
  final RxBool isLike;
  final int id;
  final VoidCallback? onSuccess;

  const CustomLikeButton(
      {super.key, required this.isLike, required this.id, this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (context.isPhone) {
        return LikeButton(
          isLiked: isLike.value,
          size: 25,
          onTap: (isLiked) async {
            var res = await FavoriteApi.addRemove(id);
            if (res.isSuccess) {
              // toast(res.m,
              //     MessageEnum.alert);
              isLike(!isLiked);
              onSuccess?.call();
              return !isLiked;
            } else {
              toast(res.m, MessageEnum.alert);
              isLike(isLiked);
              return isLiked;
            }
          },
          circleColor: CircleColor(
              start: context.theme.primaryColor,
              end: context.theme.primaryColor),
          bubblesColor: BubblesColor(
            dotPrimaryColor: context.theme.primaryColor,
            dotSecondaryColor: context.theme.primaryColor,
          ),
          likeBuilder: (bool isLiked) {
            return Icon(
              isLiked ? Icons.star : Icons.star_outline,
              color: isLiked
                  ? context.theme.primaryColor
                  : context.theme.dividerColor,
              size: 18,
            );
          },
        );
      } else {
        return Container(
          height: 35,
          width: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // color: isLike.isTrue
            //     ? context.theme.primaryColor
            //     : context.theme.scaffoldBackgroundColor,
            color: isLike.isTrue
                ? context.isDarkMode
                    ? context.theme.scaffoldBackgroundColor
                    : context.theme.primaryColor
                : context.isDarkMode
                    ? context.theme.scaffoldBackgroundColor
                    : context.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: LikeButton(
              isLiked: isLike.value,
              size: 25,
              onTap: (isLiked) async {
                var res = await FavoriteApi.addRemove(id);
                if (res.isSuccess) {
                  // toast(res.m,
                  //     MessageEnum.alert);
                  onSuccess?.call();
                  isLike(!isLiked);
                  return !isLiked;
                } else {
                  toast(res.m, MessageEnum.alert);
                  isLike(isLiked);
                  return isLiked;
                }
              },
              circleColor: CircleColor(
                  start: context.theme.primaryColor,
                  end: context.theme.primaryColor),
              bubblesColor: BubblesColor(
                dotPrimaryColor: context.theme.primaryColor,
                dotSecondaryColor: context.theme.primaryColor,
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  isLiked ? Icons.star : Icons.star_outline,
                  // Icons.star,
                  // color: isLiked
                  //     ? context.theme.cardColor
                  //     : context.theme.dividerColor,
                  color: isLiked
                      ? context.isDarkMode
                          ? context.theme.primaryColorLight
                          : context.theme.cardColor
                      : context.isDarkMode
                          ? context.theme.dividerColor
                          : context.theme.dividerColor,
                  size: 18,
                );
              },
            ),
          ),
        );
      }
    });
  }
}
