import 'package:flutter/material.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/presentation/investor_kyc_dialog.dart';

/// Every completion action uses the investor page's CML/manual KYC dialog.
/// Callers reload server data after saving; saving alone does not imply approval.
class CompleteInvestorKycButton extends StatefulWidget {
  const CompleteInvestorKycButton({
    super.key,
    required this.investor,
    required this.onSaved,
  });

  final InvestorModel investor;
  final Future<void> Function() onSaved;

  @override
  State<CompleteInvestorKycButton> createState() =>
      _CompleteInvestorKycButtonState();
}

class _CompleteInvestorKycButtonState extends State<CompleteInvestorKycButton> {
  bool _working = false;

  Future<void> _open() async {
    if (_working) return;
    setState(() => _working = true);
    try {
      final saved = await showInvestorKycDialog(context, widget.investor);
      if (saved == true && mounted) await widget.onSaved();
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: _working || widget.investor.isPreIpoKycComplete ? null : _open,
    icon: const Icon(Icons.badge_outlined, size: 18),
    label: Text(_working ? 'Please wait…' : 'Complete KYC'),
  );
}
