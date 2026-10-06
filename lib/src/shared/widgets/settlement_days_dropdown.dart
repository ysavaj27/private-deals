import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/models/settlement_option.dart';

/// Dropdown bound to `get-config` settlement options. Sends [SettlementOption.value].
class SettlementDaysDropdown extends StatelessWidget {
  const SettlementDaysDropdown({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelText = 'Settlement cycle',
    this.hintText = 'Select settlement',
    this.enabled = true,
    this.isDense = false,
    this.errorText,
    this.validator,
  });

  final List<SettlementOption> options;
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? labelText;
  final String hintText;
  final bool enabled;
  final bool isDense;
  final String? errorText;
  final FormFieldValidator<int>? validator;

  @override
  Widget build(BuildContext context) {
    final selected = options.any((option) => option.value == value)
        ? value
        : null;

    return DropdownButtonFormField<int>(
      initialValue: selected,
      isDense: isDense,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
      ),
      items: [
        for (final option in options)
          DropdownMenuItem<int>(
            value: option.value,
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
