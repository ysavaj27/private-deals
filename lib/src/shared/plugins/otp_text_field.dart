import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

class OtpTextField extends StatelessWidget {
  final String? Function(String?)? validator;
  final void Function(String)? onCompleted;
  final TextEditingController? controller;

  const OtpTextField({
    super.key,
    this.validator,
    this.onCompleted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final defaultPinTheme = PinTheme(
      width: 45,
      height: 45,
      textStyle: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: scheme.surface,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: scheme.primary, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: scheme.primary),
      ),
    );

    return Pinput(
      length: 6,
      controller: controller,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      validator: validator,
      keyboardType: TextInputType.number,
      mouseCursor: SystemMouseCursors.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
      ],
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: onCompleted,
    );
  }
}
