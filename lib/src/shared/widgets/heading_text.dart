import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeadingText extends StatelessWidget {
  final String title;

  const HeadingText(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleMedium?.copyWith(
        color: context.theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
