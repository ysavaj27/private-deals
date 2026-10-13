import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class EnquiryDecisionDialog extends StatefulWidget {
  const EnquiryDecisionDialog({
    super.key,
    required this.action,
    required this.institution,
    required this.companyName,
    this.sell = false,
    this.counterparty = false,
  });
  final String action, companyName;

  /// [sell] is true when the investor picked here is the one selling.
  final bool institution, sell;

  /// Accepting another partner's open enquiry rather than one's own.
  final bool counterparty;

  @override
  State<EnquiryDecisionDialog> createState() => _EnquiryDecisionDialogState();
}

class EnquiryDecision {
  const EnquiryDecision({this.reason, this.investorId});
  final String? reason;
  final int? investorId;
}

class _EnquiryDecisionDialogState extends State<EnquiryDecisionDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  int? _investorId;
  bool get _pickInvestor => !widget.institution && widget.action == 'accept';

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (widget.action) {
      'accept' when widget.counterparty => 'Accept',
      'accept' => 'Approve',
      'reject' => 'Reject',
      _ => 'Withdraw',
    };
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Expanded(child: Text('$label enquiry')),
          IconButton(
            tooltip: 'Close enquiry',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: _pickInvestor ? 600 : 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.companyName),
                const SizedBox(height: 16),
                if (widget.action == 'reject')
                  TextFormField(
                    controller: _reason,
                    maxLength: 1000,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: widget.institution
                          ? 'Reason (optional)'
                          : 'Reason (required)',
                    ),
                    validator: (value) =>
                        !widget.institution && (value?.trim().isEmpty ?? true)
                        ? 'Enter a rejection reason'
                        : null,
                  )
                else if (_pickInvestor) ...[
                  Text(
                    widget.counterparty
                        ? 'Select the investor who will ${widget.sell ? 'sell' : 'buy'} the shares on your side. Accepting creates a transaction with the partner who raised this enquiry.'
                        : 'Select the investor who will ${widget.sell ? 'sell' : 'buy'} the shares. Approval creates a transaction and sends their mandate for signing.',
                  ),
                  const SizedBox(height: 16),
                  InvestorPicker(
                    onSelectionChanged: (investors) => setState(() {
                      _investorId = investors.isEmpty
                          ? null
                          : investors.single.id;
                    }),
                  ),
                ] else
                  Text(
                    widget.action == 'accept'
                        ? 'This enquiry will be locked to you while the wealth manager makes their decision.'
                        : 'Withdraw this open enquiry?',
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _pickInvestor && _investorId == null
              ? null
              : () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      EnquiryDecision(
                        reason: _reason.text.trim(),
                        investorId: _investorId,
                      ),
                    );
                  }
                },
          child: Text(label),
        ),
      ],
    );
  }
}
