import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTitleDropdown<T extends Object> extends StatelessWidget {
  const AppTitleDropdown({
    super.key,
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.value,
    this.hint = 'Select an option',
    this.validator,
    this.enabled = true,
  });

  final String title;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String hint;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.bodyMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          // Recreates form state when the externally selected value changes.
          key: ValueKey<T?>(value),
          initialValue: value,
          isExpanded: true,
          dropdownColor: context.theme.colorScheme.surface,
          decoration: InputDecoration(hintText: hint),
          // hint: Text(hint),
          validator: validator,
          onChanged: enabled ? onChanged : null,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ],
    );
  }
}
