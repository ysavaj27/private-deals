import 'package:private_deals/src/shared/app_exports.dart';
import 'package:searchfield/searchfield.dart';

class SearchableTextField<T> extends StatelessWidget {
  final List<SearchFieldListItem<T>> suggestions;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String title;
  final String hint;
  final bool isRequired;
  final dynamic Function(SearchFieldListItem<T>)? onSuggestionTap;

  const SearchableTextField({
    super.key,
    required this.suggestions,
    this.validator,
    this.controller,
    this.onSuggestionTap,
    required this.title,
    required this.hint,
    this.isRequired = false,
  });

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
              TextSpan(text: title),
              TextSpan(
                text: isRequired ? '*' : "",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        SearchField<T>(
          suggestions: suggestions,
          hint: hint,
          controller: controller,
          searchInputDecoration: SearchInputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 17),
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: context.theme.colorScheme.surface,
            border: _buildBorder(context, 12),
            enabledBorder: _buildBorder(context, 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: context.theme.colorScheme.primary, width: 2),
            ),
            errorBorder: _buildBorder(context, 12, isError: true),
            focusedErrorBorder: _buildBorder(context, 12, isError: true),
            prefixIcon: Icon(Icons.search, color: context.theme.primaryColor),
          ),
          maxSuggestionsInViewPort: 5,
          onSuggestionTap: onSuggestionTap,
          itemHeight: 50,
          validator: validator,
        ),
      ],
    );
  }

  static OutlineInputBorder _buildBorder(BuildContext context, double radius,
      {bool isError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: isError ? Colors.red : context.theme.colorScheme.outlineVariant,
        width: isError ? 1.5 : 1,
      ),
    );
  }
}
