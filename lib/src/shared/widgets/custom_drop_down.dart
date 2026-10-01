import 'package:private_deals/src/shared/app_exports.dart';

class CustomDropDown<T> extends StatelessWidget {
  final T? value;
  final String? Function(T?)? validator;
  final String label;
  final String? hintText;
  final bool isMandatory;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;

  const CustomDropDown({
    super.key,
    this.value,
    this.validator,
    this.label = '',
    this.isMandatory = false,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isDense: true,
      validator: validator,
      style: TextStyle(
        color: context.textTheme.titleMedium?.color,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      hint: Text(
        hintText ?? "",
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,

        // fillColor: context.isDarkMode
        //     ? context.theme.shadowColor
        //     : context.theme.scaffoldBackgroundColor,

        label: label.isNotEmpty
            ? RichText(
                text: TextSpan(
                    text: label,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600),
                    children: [
                      TextSpan(
                          text: isMandatory ? ' *' : "",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red))
                    ]),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
          color: Get.isDarkMode ? Color(0xff232323) : Colors.grey.shade400),
    );
  }
}

class CustomLabelDropDown<T> extends StatelessWidget {
  final bool isRequired;
  final T? value;
  final String? Function(T?)? validator;
  final String label;
  final String hintText;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;

  CustomLabelDropDown(
      {super.key,
      this.isRequired = false,
      this.value,
      this.hintText = '',
      this.validator,
      required this.label,
      this.items,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: context.theme.colorScheme.onSurfaceVariant,
                fontSize: context.isPhone ? 14 : 16),
            children: [
              TextSpan(text: label),
              TextSpan(
                text: isRequired ? '*' : "",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        CustomDropDown(
          onChanged: onChanged,
          items: items,
          hintText: hintText,
          validator: validator,
          value: value,
          isMandatory: isRequired,
        ),
      ],
    );
  }
}
