import 'package:private_deals/src/shared/app_exports.dart';

class LogoutDialog extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? primaryText;

  final String? secondaryText;
  final void Function()? onPressed;

  const LogoutDialog({
    super.key,
    required this.onPressed,
    this.title,
    this.subTitle,
    this.primaryText,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      radius: 16,
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? "Logout",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(
            color: context.theme.dividerColor,
            height: 30,
            thickness: 0.8,
          ),
          SizedBox(height: 10),
          Text(
            subTitle ?? "Are you sure you want to logout ?",
            style: TextStyle(
              color: context.theme.colorScheme.onSurfaceVariant,
              // fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                padding: EdgeInsets.zero,
                size: Size(80, 38),
                radius: 15,
                text: primaryText ?? 'Ok',
                onPressed: onPressed,
              ),
              SizedBox(width: 20),
              CustomOutlinedButton(
                size: Size(80, 38),
                borderRadius: 15,
                borderColor: AppColors.borderColor(context),
                onPressed: Get.back,
                text: secondaryText ?? "Cancel",
              ),
            ],
          )
        ],
      ),
    );
  }
}
