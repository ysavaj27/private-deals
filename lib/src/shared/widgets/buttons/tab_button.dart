import 'package:private_deals/src/shared/app_exports.dart';

class TabButton<T> extends StatelessWidget {
  const TabButton({
    super.key,
    required this.title,
    required this.type,
    required this.onTap,
    required this.currentIndex,
  });

  final String title;
  final Rx<T> currentIndex;
  final T type;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSelected = currentIndex() == type;
      return Clickable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: CustomCardWidget(
          radius: 12,
          color: isSelected
              ? context.theme.colorScheme.primaryContainer
              : context.theme.colorScheme.surfaceContainerHigh,
          isBorder: true,
          borderColor: context.theme.colorScheme.outlineVariant,
          padding: EdgeInsets.symmetric(horizontal: 27, vertical: 10),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
                color: isSelected
                    ? context.theme.colorScheme.onPrimaryContainer
                    : context.theme.colorScheme.onSurface),
          ),
        ),
      );
    });
  }
}
