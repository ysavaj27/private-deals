import 'package:private_deals/src/shared/app_exports.dart';

/// Shared landing-page typography for Primary and Pre-IPO.
class CatalogSectionHeading extends StatelessWidget {
  const CatalogSectionHeading({
    super.key,
    this.prefix = '',
    required this.title,
  });
  final String prefix;
  final String title;

  @override
  Widget build(BuildContext context) => Center(
    child: Text.rich(
      TextSpan(
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix),
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: context.isPhone ? 22 : 36,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

/// Pre-IPO's outlined mobile and filled desktop section action.
class CatalogExploreButton extends StatelessWidget {
  const CatalogExploreButton({
    super.key,
    required this.onPressed,
    this.text = 'Explore More',
  });
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: context.isPhone
        ? CustomOutlinedButton(
            text: text,
            width: 150,
            borderRadius: AppRadii.button,
            color: context.theme.primaryColor,
            onPressed: onPressed,
          )
        : CustomElevatedButton(
            text: text,
            width: 236,
            height: 56,
            radius: AppRadii.button,
            onPressed: onPressed,
          ),
  );
}
