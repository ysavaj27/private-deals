import 'package:private_deals/src/shared/app_exports.dart';

Future<String?> showPreIpoReasonDialog({
  required String title,
  String hint = 'Enter reason',
  String confirmLabel = 'Submit',
  int maxLength = 1000,
}) {
  return showCustomDialog(
    _PreIpoReasonDialog(
      title: title,
      hint: hint,
      confirmLabel: confirmLabel,
      maxLength: maxLength,
    ),
  ).then((value) => value is String ? value : null);
}

class _PreIpoReasonDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmLabel;
  final int maxLength;

  const _PreIpoReasonDialog({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.maxLength,
  });

  @override
  State<_PreIpoReasonDialog> createState() => _PreIpoReasonDialogState();
}

class _PreIpoReasonDialogState extends State<_PreIpoReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: isPhone ? double.infinity : 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: isPhone ? 18 : 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _controller,
                hintText: widget.hint,
                maxLines: 4,
                maxLength: widget.maxLength,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Reason is required';
                  if (text.length > widget.maxLength) {
                    return 'Max ${widget.maxLength} characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomOutlinedButton(
                    width: isPhone ? 100 : 120,
                    height: 42,
                    onPressed: Get.back,
                    text: 'Close',
                  ),
                  const SizedBox(width: 16),
                  CustomElevatedButton(
                    width: isPhone ? 110 : 140,
                    height: 42,
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      Get.back(result: _controller.text.trim());
                    },
                    text: widget.confirmLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<MediaModel?> showPreIpoReceiptUploadDialog({
  required String title,
  String subtitle = 'Upload png, jpg, jpeg, or pdf',
}) {
  return showCustomDialog(
    _PreIpoReceiptUploadDialog(title: title, subtitle: subtitle),
  ).then((value) => value is MediaModel ? value : null);
}

class _PreIpoReceiptUploadDialog extends StatefulWidget {
  final String title;
  final String subtitle;

  const _PreIpoReceiptUploadDialog({
    required this.title,
    required this.subtitle,
  });

  @override
  State<_PreIpoReceiptUploadDialog> createState() =>
      _PreIpoReceiptUploadDialogState();
}

class _PreIpoReceiptUploadDialogState
    extends State<_PreIpoReceiptUploadDialog> {
  final _nameCtrl = TextEditingController();
  MediaModel? _file;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final files = await FilePickers().pickFile(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'pdf'],
    );
    if (files.isEmpty) return;
    setState(() {
      _file = files.first;
      _nameCtrl.text = files.first.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: isPhone ? double.infinity : 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: isPhone ? 18 : 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.subtitle),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameCtrl,
              hintText: 'No file chosen',
              readOnly: true,
              onTap: _pick,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedButton(
                  width: isPhone ? 100 : 120,
                  height: 42,
                  onPressed: Get.back,
                  text: 'Close',
                ),
                const SizedBox(width: 16),
                CustomElevatedButton(
                  width: isPhone ? 110 : 140,
                  height: 42,
                  onPressed: () {
                    if (_file == null) {
                      toast('Please choose a file', MessageEnum.alert);
                      return;
                    }
                    Get.back(result: _file);
                  },
                  text: 'Upload',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PreIpoPaymentDetailsPanel extends StatelessWidget {
  final PreIpoPaymentDetails details;

  const PreIpoPaymentDetailsPanel({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final account = details.account;
    final bankSummary = account == null
        ? ''
        : [
            if (account.accountHolderName.trim().isNotEmpty)
              'Account holder: ${account.accountHolderName.trim()}',
            if (account.bankName.trim().isNotEmpty)
              'Bank: ${account.bankName.trim()}',
            if (account.accountNumber.trim().isNotEmpty)
              'Account number: ${account.accountNumber.trim()}',
            if (account.ifscCode.trim().isNotEmpty)
              'IFSC: ${account.ifscCode.trim()}',
            'Amount: ${details.amount.toFormattedPrice}',
          ].join('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment details',
                  style: context.theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (bankSummary.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      _copyText(context, bankSummary, 'Payment details copied'),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy all'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, 'Amount', details.amount.toCurrency),
          if (account == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Bank account details are not available yet.'),
            )
          else ...[
            _row(
              context,
              'Account holder',
              account.accountHolderName,
              copyable: true,
            ),
            _row(context, 'Bank', account.bankName, copyable: true),
            _row(
              context,
              'Account number',
              account.accountNumber,
              copyable: true,
            ),
            _row(context, 'IFSC', account.ifscCode, copyable: true),
          ],
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    final trimmed = value.trim();
    final display = trimmed.isEmpty ? '—' : value;
    final canCopy = copyable && trimmed.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: SelectableText(display)),
          if (canCopy)
            IconButton(
              tooltip: 'Copy $label',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              onPressed: () => _copyText(context, trimmed, '$label copied'),
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: context.theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copyText(
    BuildContext context,
    String text,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

class PreIpoOrderStepHeader extends StatelessWidget {
  final PreIpoOrderModel order;
  final bool compact;

  const PreIpoOrderStepHeader({
    super.key,
    required this.order,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final stepLabel = order.orderStep.replaceAll('_', ' ');
    final current = order.current.isEmpty ? '—' : order.current;
    final next =
        order.next != null && order.next != 'N/A' ? order.next!.trim() : '';
    final reason = order.cancellationReason?.trim() ?? '';

    if (compact) {
      final parts = <String>[
        if (stepLabel.isNotEmpty) stepLabel,
        current,
        if (next.isNotEmpty) 'Next: $next',
        if (reason.isNotEmpty) 'Reason: $reason',
      ];
      return Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                parts.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            stepLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          current,
          style: context.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (next.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Next: $next',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        if (reason.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Reason: $reason',
            style: TextStyle(color: colors.error),
          ),
        ],
      ],
    );
  }
}

class PreIpoOrderActionBar extends StatelessWidget {
  final PreIpoOrderModel order;
  final Future<void> Function(String action) onAction;
  final bool compact;

  const PreIpoOrderActionBar({
    super.key,
    required this.order,
    required this.onAction,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final actions = order.action ?? const <String>[];
    if (actions.isEmpty) return const SizedBox.shrink();
    final buttons = [
      for (final action in actions)
        _ActionButton(
          action: action,
          compact: compact,
          onPressed: () => onAction(action),
        ),
    ];
    if (compact) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              buttons[i],
            ],
          ],
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String action;
  final bool compact;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.action,
    required this.compact,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = PreIpoOrderAction.label(action);
    final isDestructive =
        action == PreIpoOrderAction.cancel ||
        action == PreIpoOrderAction.reject;
    final isPrimary =
        action == PreIpoOrderAction.approve ||
        action == PreIpoOrderAction.confirmPayment ||
        action == PreIpoOrderAction.confirmShareTransfer ||
        action == PreIpoOrderAction.uploadPaymentReceipt ||
        action == PreIpoOrderAction.uploadShareTransferReceipt;

    if (isDestructive) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.theme.colorScheme.error,
          side: BorderSide(color: context.theme.colorScheme.error),
          minimumSize: Size(compact ? 0 : 120, 36),
        ),
        child: Text(label),
      );
    }
    if (isPrimary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: Size(compact ? 0 : 120, 36)),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: Size(compact ? 0 : 120, 36)),
      child: Text(label),
    );
  }
}

Future<void> showPreIpoPaymentDetailsDialog(PreIpoPaymentDetails details) {
  return showCustomDialog(
    CustomCardWidget(
      color: Get.context!.theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PreIpoPaymentDetailsPanel(details: details),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: CustomOutlinedButton(
                width: 120,
                height: 42,
                onPressed: Get.back,
                text: 'Close',
              ),
            ),
          ],
        ),
      ),
    ),
  ).then((_) {});
}

/// Lists every stored order file from [PreIpoOrderModel.documents] (oldest first).
class PreIpoOrderDocumentsPanel extends StatelessWidget {
  final List<PreIpoOrderDocument> documents;

  const PreIpoOrderDocumentsPanel({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const SizedBox.shrink();
    final colors = context.theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents',
            style: context.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < documents.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(documents[i].displayName),
                subtitle: documents[i].type.isEmpty
                    ? null
                    : Text(
                        documents[i].type,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                trailing: TextButton(
                  onPressed: documents[i].url.isEmpty
                      ? null
                      : () => Launcher.openNewTab(documents[i].url),
                  child: const Text('Open'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
