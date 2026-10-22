import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/shared/theme/app_motion.dart';
import 'package:private_deals/src/shared/theme/app_tokens.dart';

enum AppToastType {
  info('For your information', Icons.info_outline_rounded),
  success('Success', Icons.check_rounded),
  error('Something went wrong', Icons.error_outline_rounded),
  alert('Please note', Icons.priority_high_rounded);

  const AppToastType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Shared presentation for both partner and institution notifications.
void showAppToast(
  String message, {
  AppToastType type = AppToastType.alert,
  Duration? duration,
}) {
  final content = message.trim();
  if (content.isEmpty) return;

  final context = Get.overlayContext;
  if (context == null) return;
  final media = MediaQuery.of(context);
  late SnackbarController controller;
  controller = Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      margin: EdgeInsets.fromLTRB(
        media.padding.left + AppSpace.lg,
        AppSpace.lg,
        media.padding.right + AppSpace.lg,
        AppSpace.lg,
      ),
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      barBlur: 0,
      borderRadius: AppRadii.lg,
      animationDuration: AppMotion.duration(context, AppMotion.dialog),
      forwardAnimationCurve: AppMotion.easeOut,
      reverseAnimationCurve: Curves.easeInCubic,
      dismissDirection: DismissDirection.horizontal,
      // Keep announcements available until dismissed for assistive navigation.
      duration:
          duration ??
          (media.accessibleNavigation
              ? null
              : Duration(seconds: content.length > 120 ? 7 : 4)),
      messageText: Builder(
        builder: (context) => Align(
          alignment: MediaQuery.sizeOf(context).width >= 1200
              ? Alignment.topRight
              : Alignment.topCenter,
          heightFactor: 1,
          child: SizedBox(
            width: 440,
            child: AppToastCard(
              message: content,
              type: type,
              onDismiss: () => controller.close(),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A quiet, theme-aware surface; status is conveyed by words and iconography.
class AppToastCard extends StatelessWidget {
  const AppToastCard({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? colors.secondary : colors.onSecondaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.lgAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Material(
        color: isDark ? colors.surfaceContainerHigh : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.10),
                    borderRadius: AppRadii.mdAll,
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Icon(type.icon, size: 20, color: accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              height: 1.4,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              height: 1.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDismiss,
                tooltip: 'Dismiss notification',
                style: IconButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                  minimumSize: const Size(44, 44),
                  maximumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.standard,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
