import 'package:private_deals/src/shared/app_exports.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData? icon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool enableSuggestions;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool? enabled;
  final bool readOnly;
  final int? maxLength;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool? isDense;
  final List<TextInputFormatter>? inputFormatters;
  final bool isMandatory;
  final bool autofocus;
  final bool isBorder;
  final bool isFilled;
  final bool? showCursor;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final EdgeInsets? contentPadding;
  final double radius;
  final TextStyle? errorStyle;
  final Color? borderColor;
  final bool isAuthFocusBorder;
  final TextAlign textAlign;

  const CustomTextField({
    super.key,
    this.label,
    this.inputFormatters,
    this.hintText = '',
    this.icon,
    this.onChanged,
    this.suffixIcon,
    this.obscureText = false,
    this.validator,
    this.enableSuggestions = true,
    this.controller,
    this.keyboardType,
    this.autofillHints,
    this.minLines,
    this.maxLines,
    this.enabled,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.focusNode,
    this.isDense,
    this.maxLength,
    this.isMandatory = false,
    this.autofocus = false,
    this.isBorder = true,
    this.isFilled = true,
    this.showCursor,
    this.fillColor,
    this.hintStyle,
    this.contentPadding,
    this.radius = 12,
    this.errorStyle,
    this.borderColor,
    this.isAuthFocusBorder = false,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      mouseCursor: SystemMouseCursors.basic,
      enabled: enabled,
      focusNode: focusNode,
      showCursor: showCursor,
      maxLength: maxLength,
      autofocus: autofocus,
      textAlign: textAlign,
      // autofocus: true,
      onTap: onTap,
      readOnly: readOnly,
      obscuringCharacter: '*',
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      inputFormatters: inputFormatters,
      enableSuggestions: enableSuggestions,
      autofillHints: autofillHints,
      minLines: minLines,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines ?? 1,
      // autocorrect: false,
      style: context.textTheme.bodyMedium,
      decoration: InputDecoration(
        counterText: "",
        errorMaxLines: 3,
        // hoverColor: context.theme.scaffoldBackgroundColor,
        label: hintText.isEmpty
            ? RichText(
                text: TextSpan(
                    text: label ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.isDarkMode
                          ? context.theme.disabledColor
                          : context.theme.shadowColor.withOpacity(0.6),
                      // color: Colors.grey,
                    ),
                    children: [
                      if (isMandatory)
                        const TextSpan(
                            text: ' *',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red))
                    ]),
              )
            : null,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 18, horizontal: 17),
        hintStyle: hintStyle ?? context.theme.inputDecorationTheme.hintStyle,
        prefixIcon: prefixIcon,
        // fillColor: context.theme.disabledColor.withOpacity(0.1),
        filled: isFilled,
        fillColor: fillColor ?? context.theme.colorScheme.surface,
        hintText: hintText,
        errorStyle: errorStyle,
        border: border(context),
        disabledBorder: border(context),
        enabledBorder: border(context),
        errorBorder: border(context, error: true),
        focusedErrorBorder: border(context, error: true),
        focusedBorder: isBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                    color: context.theme.colorScheme.primary, width: 2),
              )
            : InputBorder.none,
        isDense: isDense ?? true,
        // labelText: label,
        // labelStyle:
        //     const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        suffixIcon: suffixIcon,
        suffixIconColor: context.theme.primaryColor,
        prefixIconColor: context.theme.primaryColor,
        // prefixIcon: Icon(icon, color: context.theme.colorScheme.secondary),
      ),
    );
  }

  OutlineInputBorder border(BuildContext context, {bool error = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: isBorder
            ? (error
                ? context.theme.colorScheme.error
                : borderColor ?? AppColors.borderColor(context))
            : Colors.transparent,
      ),
    );
  }
}

class TitleTextField extends StatelessWidget {
  final String name;
  final String hintText;
  final bool isRequired;
  final bool? enabled;
  final bool readOnly;
  final TextEditingController? controller;

  // final Widget? widget;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final void Function(String)? onFieldSubmitted;
  final Color? fillColor;
  final bool? isDense;
  final Color? borderColor;
  final bool isAuthFocusBorder;
  final bool isBorder;
  final void Function(String)? onChanged;
  final EdgeInsets? contentPadding;
  final Iterable<String>? autofillHints;

  const TitleTextField({
    super.key,
    required this.name,
    this.isRequired = false,
    this.controller,
    // this.widget,
    this.minLines,
    this.maxLines,
    this.enabled,
    this.validator,
    this.onTap,
    this.suffixIcon,
    this.maxLength,
    this.readOnly = false,
    this.inputFormatters,
    this.hintText = '',
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.autofocus = false,
    this.fillColor,
    this.onFieldSubmitted,
    this.isDense,
    this.borderColor,
    this.isAuthFocusBorder = false,
    this.isBorder = true,
    this.onChanged,
    this.contentPadding,
    this.autofillHints,
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
              TextSpan(text: name),
              TextSpan(
                text: isRequired ? '*' : "",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        CustomTextField(
          onChanged: onChanged,
          radius: 12,
          contentPadding: contentPadding,
          borderColor: borderColor ?? AppColors.borderColor(context),
          isAuthFocusBorder: isAuthFocusBorder,
          autofocus: autofocus,
          obscureText: obscureText,
          isDense: isDense,
          isFilled: true,
          onFieldSubmitted: onFieldSubmitted,
          isBorder: isBorder,
          hintText: hintText,
          fillColor: fillColor ?? context.theme.colorScheme.surface,
          controller: controller,
          prefixIcon: prefixIcon,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          hintStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
          minLines: minLines,
          maxLines: maxLines,
          onTap: onTap,
          validator: validator,
          enabled: enabled,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          suffixIcon: suffixIcon,
          autofillHints: autofillHints,
        ),
      ],
    );
  }
}

class SearchBarTextField extends StatelessWidget {
  final void Function(String)? onChanged;
  final String? hintText;
  final double? radius;
  final FocusNode? focusNode;
  final bool readOnly;
  final void Function()? onTap;

  const SearchBarTextField(
      {super.key,
      this.onChanged,
      this.hintText,
      this.radius,
      this.focusNode,
      this.readOnly = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      readOnly: readOnly,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
          vertical: context.isPhone ? 15 : 22, horizontal: 30),
      radius: radius ?? 12,
      isBorder: true,
      hintStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      hintText: hintText ?? "Search Company",
      prefixIcon: const Icon(Icons.search, size: 25),
      borderColor: AppColors.borderColor(context),
      focusNode: focusNode,
      onChanged: onChanged,
    );
  }
}

class CReadingOrderTraversalPolicy extends OrderedTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(
      Iterable<FocusNode> descendants, FocusNode currentNode) {
    return descendants;
  }
}

class IntegerSpinnerField extends StatelessWidget {
  const IntegerSpinnerField({
    super.key,
    required this.value,
    this.autofocus = false,
    this.delta = 1,
    this.onChanged,
  });

  final int value;
  final bool autofocus;
  final int delta;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SpinnerField<int>(
      value: value,
      onChanged: onChanged,
      autofocus: autofocus,
      fromString: (String stringValue) => int.tryParse(stringValue) ?? value,
      increment: (int i) => i + delta,
      decrement: (int i) => i - delta,
      // Add a text formatter that only allows integer values and a leading
      // minus sign.
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction(
          (TextEditingValue oldValue, TextEditingValue newValue) {
            String newString;
            if (newValue.text.startsWith('-')) {
              newString = '-${newValue.text.replaceAll(RegExp(r'\D'), '')}';
            } else {
              newString = newValue.text.replaceAll(RegExp(r'\D'), '');
            }
            return newValue.copyWith(
              text: newString,
              selection: newValue.selection.copyWith(
                baseOffset:
                    newValue.selection.baseOffset.clamp(0, newString.length),
                extentOffset:
                    newValue.selection.extentOffset.clamp(0, newString.length),
              ),
            );
          },
        )
      ],
    );
  }
}

class SpinnerField<T> extends StatefulWidget {
  SpinnerField({
    super.key,
    required this.value,
    required this.fromString,
    this.autofocus = false,
    String Function(T value)? asString,
    this.increment,
    this.decrement,
    this.onChanged,
    this.isRequired = false,
    this.isIncrementDecrement = true,
    this.name = '',
    this.inputFormatters = const <TextInputFormatter>[],
  }) : asString = asString ?? ((T value) => value.toString());

  final T value;
  final T Function(T value)? increment;
  final T Function(T value)? decrement;
  final String Function(T value) asString;
  final T Function(String value) fromString;
  final ValueChanged<T>? onChanged;
  final List<TextInputFormatter> inputFormatters;
  final bool autofocus;
  final String name;
  final bool isRequired;
  final bool isIncrementDecrement;

  @override
  State<SpinnerField<T>> createState() => _SpinnerFieldState<T>();
}

class _SpinnerFieldState<T> extends State<SpinnerField<T>> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateText(widget.asString(widget.value));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpinnerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asString != widget.asString ||
        oldWidget.value != widget.value) {
      final String newText = widget.asString(widget.value);
      _updateText(newText);
    }
  }

  void _updateText(String text, {bool collapsed = true}) {
    if (text != controller.text) {
      controller.value = TextEditingValue(
        text: text,
        selection: collapsed
            ? TextSelection.collapsed(offset: text.length)
            : TextSelection(baseOffset: 0, extentOffset: text.length),
      );
    }
  }

  void _spin(T Function(T value)? spinFunction) {
    if (spinFunction == null) {
      return;
    }
    final T newValue = spinFunction(widget.value);
    widget.onChanged?.call(newValue);
    _updateText(widget.asString(newValue), collapsed: false);
  }

  void _increment() {
    _spin(widget.increment);
  }

  void _decrement() {
    _spin(widget.decrement);
  }

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
              TextSpan(text: widget.name),
              TextSpan(
                text: widget.isRequired ? '*' : "",
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        CallbackShortcuts(
          bindings: widget.isIncrementDecrement
              ? <ShortcutActivator, VoidCallback>{
                  const SingleActivator(LogicalKeyboardKey.arrowUp): _increment,
                  const SingleActivator(LogicalKeyboardKey.arrowDown):
                      _decrement,
                }
              : {},
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor(context)),
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                end: Alignment.centerRight,
                begin: Alignment.centerLeft,
                colors: [
                  context.isDarkMode ? Color(0xff242424) : Colors.grey.shade400,
                  context.theme.scaffoldBackgroundColor,
                  context.theme.scaffoldBackgroundColor,
                  context.theme.scaffoldBackgroundColor,
                  context.isDarkMode ? Color(0xff242424) : Colors.grey.shade400,
                ],
              ),
            ),
            child: Row(
              children: <Widget>[
                Visibility(
                  visible: widget.isIncrementDecrement,
                  child: TextFieldTapRegion(
                    child: IconButton.outlined(
                      onPressed: _decrement,
                      icon: const Icon(Icons.remove),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: CustomTextField(
                    isFilled: false,
                    isBorder: false,
                    readOnly: true,
                    // contentPadding: EdgeInsets.all(10),
                    radius: 4,

                    autofocus: widget.autofocus,
                    inputFormatters: widget.inputFormatters,
                    onChanged: (String value) =>
                        widget.onChanged?.call(widget.fromString(value)),
                    controller: controller,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 5),
                // Without this TextFieldTapRegion, tapping on the buttons below would
                // increment the value, but it would cause the text field to be
                // unfocused, since tapping outside of a text field should unfocus it
                // on non-mobile platforms.
                Visibility(
                  visible: widget.isIncrementDecrement,
                  child: TextFieldTapRegion(
                    child: IconButton.outlined(
                      onPressed: _increment,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
