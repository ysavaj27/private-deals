import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

class DeleteAccountDialog extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final String? primaryText;
  final String? secondaryText;
  final void Function()? onDelete;

  const DeleteAccountDialog({
    super.key,
    required this.onDelete,
    this.title,
    this.subTitle,
    this.primaryText,
    this.secondaryText,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _isValid = _textController.text.trim().toLowerCase() == 'delete';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: double.infinity,
      color: context.theme.scaffoldBackgroundColor,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title ?? "Delete Account",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Divider(
              color: context.theme.colorScheme.outlineVariant,
              height: 30,
              thickness: 0.8,
            ),
            const SizedBox(height: 10),
            Text(
              widget.subTitle ??
                  "Please enter 'delete' in the field below to confirm account deletion.",
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.85,
                ),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _textController,
              hint: "Type 'Delete' to confirm",
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: widget.primaryText ?? 'Delete',
                    onPressed: _isValid ? widget.onDelete : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                    label: widget.secondaryText ?? "Cancel",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
