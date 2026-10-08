import 'package:flutter/material.dart';
import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';

class SelectInvestorDialog extends StatelessWidget {
  const SelectInvestorDialog({super.key, this.selectedInvestorIds = const []});
  final List<int> selectedInvestorIds;

  @override
  Widget build(BuildContext context) => InvestorPickerDialog(
    multiple: true,
    requirePreIpoAccess: true,
    allowRegistration: true,
    selectedInvestorIds: selectedInvestorIds,
  );
}
