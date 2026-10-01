import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:private_deals/src/features/institution/support/theme/app_spacing.dart';
import 'package:private_deals/src/shared/institution_widgets/gap.dart';

/// A labeled text input built on [TextFormField].
///
/// Centralizes look-and-feel (label, hint, icons) and supports password fields
/// with a built-in show/hide toggle via [obscurable].
class AppTextField extends StatefulWidget {
  const AppTextField({
    // required this.label,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.suffixIcon,
    this.enabled = true,
    super.key,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
  });

  // final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;

  /// When true, the field hides its content and shows a visibility toggle
  /// (use for passwords).
  final bool obscurable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscurable;

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.obscurable != widget.obscurable) {
      _obscured = widget.obscurable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.obscurable ? 1 : widget.maxLines,
      minLines: widget.obscurable ? 1 : widget.minLines,
      autocorrect: !widget.obscurable,
      enableSuggestions: !widget.obscurable,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: widget.enabled ? colors.onSurface : theme.disabledColor,
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon:
            widget.suffixIcon ??
            (widget.obscurable
                ? IconButton(
                    onPressed: widget.enabled
                        ? () => setState(() => _obscured = !_obscured)
                        : null,
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    tooltip: _obscured ? 'Show password' : 'Hide password',
                  )
                : null),
      ),
    );
  }
}

class AppTitleTextField extends StatelessWidget {
  const AppTitleTextField({
    super.key,
    required this.title,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.obscurable = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
  });

  final String title;
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscurable;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.bodyMedium),
        Gap(AppSpacing.sm),
        AppTextField(
          controller: controller,
          hint: hint,
          prefixIcon: prefixIcon,
          obscurable: obscurable,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          enabled: enabled,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: minLines,
        ),
      ],
    );
  }
}
