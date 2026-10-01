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
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
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
      color: context.theme.scaffoldBackgroundColor,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title ?? "Delete Account",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          Divider(
            color: context.theme.dividerColor,
            height: 30,
            thickness: 0.8,
          ),
          const SizedBox(height: 10),
          Text(
            widget.subTitle ??
                "Please enter 'delete' in the field below to confirm account deletion.",
            style: TextStyle(
              color: context.theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _textController,
            hintText: "Type 'Delete' to confirm",
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomElevatedButton(
                padding: EdgeInsets.zero,
                size: const Size(80, 38),
                radius: 15,
                text: widget.primaryText ?? 'Delete',
                onPressed:
                    _isValid ? widget.onDelete : null, // Enable only when valid
              ),
              const SizedBox(width: 20),
              CustomOutlinedButton(
                size: const Size(80, 38),
                borderRadius: 15,
                borderColor: AppColors.borderColor(context),
                onPressed: Get.back,
                text: widget.secondaryText ?? "Cancel",
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
