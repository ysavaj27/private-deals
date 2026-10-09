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
      final isSelected = currentIndex() == type;
      final scheme = context.theme.colorScheme;
      return Clickable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppMotion.fast),
          curve: AppMotion.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primaryContainer
                : scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              color: isSelected
                  ? scheme.onPrimaryContainer
                  : scheme.onSurface,
            ),
          ),
        ),
      );
    });
  }
}
