import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

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
      width: double.infinity,
      color: context.theme.scaffoldBackgroundColor,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? "Logout",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          Divider(
            color: context.theme.colorScheme.outlineVariant,
            height: 30,
            thickness: 0.8,
          ),
          const SizedBox(height: 10),
          Text(
            subTitle ?? "Are you sure you want to logout ?",
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(
                alpha: 0.85,
              ),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: primaryText ?? 'Ok',
                  onPressed: onPressed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.back(),
                  label: secondaryText ?? "Cancel",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
