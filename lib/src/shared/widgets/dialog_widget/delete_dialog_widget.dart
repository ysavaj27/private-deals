import 'package:private_deals/src/shared/app_exports.dart';

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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final text = context.textTheme;
    final compact = context.isPhone;

    return CustomCardWidget(
      color: colors.surfaceContainerLow,
      radius: AppRadii.lg,
      borderColor: colors.outlineVariant,
      padding: EdgeInsets.all(compact ? AppSpace.xl : AppSpace.xxl),
      child: SizedBox(
        width: compact ? double.infinity : 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: colors.onErrorContainer,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title ?? 'Delete account',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        widget.subTitle ??
                            "This permanently removes your account. Type delete below to confirm.",
                        style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            CustomTextField(
              controller: _textController,
              hintText: "Type 'delete' to confirm",
            ),
            const SizedBox(height: AppSpace.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    child: Text(widget.secondaryText ?? 'Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _isValid ? widget.onDelete : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                      disabledBackgroundColor: colors.error.withValues(
                        alpha: 0.38,
                      ),
                      disabledForegroundColor: colors.onError.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    child: Text(widget.primaryText ?? 'Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
