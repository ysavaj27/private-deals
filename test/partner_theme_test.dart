import 'dart:io';

import 'package:private_deals/src/shared/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/brand_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:private_deals/src/shared/widgets/custom_text_field.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';
import 'package:private_deals/src/shared/widgets/buttons/custom_elevated_button.dart';
import 'package:private_deals/src/shared/widgets/buttons/custom_outlined_button.dart';

void main() {
  test('rounded corners across the app use the common radius scale', () {
    final hardcoded = RegExp(r'(?:BorderRadius|Radius)\.circular\(\s*[1-9]');
    final violations = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => hardcoded.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();
    expect(
      violations,
      isEmpty,
      reason: 'Use AppRadii instead of local corner values.',
    );
  });

  test('both themes share card, dialog, sheet and control corner shapes', () {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      final cards =
          (theme.cardTheme.shape! as RoundedRectangleBorder).borderRadius;
      final dialogs =
          (theme.dialogTheme.shape! as RoundedRectangleBorder).borderRadius;
      final sheets = (theme.bottomSheetTheme.shape! as RoundedRectangleBorder)
          .borderRadius;
      expect(cards, BorderRadius.circular(AppRadii.card));
      expect(dialogs, cards);
      expect(
        sheets,
        const BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      );
      expect(
        (theme.inputDecorationTheme.border! as OutlineInputBorder).borderRadius,
        BorderRadius.circular(AppRadii.control),
      );
      for (final style in [
        theme.elevatedButtonTheme.style!,
        theme.filledButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
        theme.textButtonTheme.style!,
        theme.iconButtonTheme.style!,
      ]) {
        for (final states in <Set<WidgetState>>[
          {},
          {WidgetState.disabled},
          {WidgetState.pressed},
        ]) {
          final shape = style.shape!.resolve(states)! as RoundedRectangleBorder;
          expect(shape.borderRadius, BorderRadius.circular(AppRadii.button));
        }
      }
      expect(
        (theme.segmentedButtonTheme.style!.shape!.resolve({})!
                as RoundedRectangleBorder)
            .borderRadius,
        AppRadii.tabAll,
      );
      expect(
        (theme.chipTheme.shape! as RoundedRectangleBorder).borderRadius,
        AppRadii.tabAll,
      );
      expect(
        (theme.floatingActionButtonTheme.shape! as RoundedRectangleBorder)
            .borderRadius,
        AppRadii.buttonAll,
      );
    }
  });

  test('Partner navy actions retain readable text and dark focus accents', () {
    final theme = AppTheme.darkTheme;
    final style = theme.elevatedButtonTheme.style!;
    final background = style.backgroundColor!.resolve({})!;
    final foreground = style.foregroundColor!.resolve({})!;
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
    }

    expect(background, BrandColors.navyLight);
    expect(contrast(background, foreground), greaterThanOrEqualTo(4.5));
    expect(
      contrast(theme.colorScheme.primary, theme.colorScheme.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(style.elevation!.resolve({}), 0);
    expect(theme.dialogTheme.elevation, 0);
    expect(theme.scaffoldBackgroundColor.computeLuminance(), lessThan(.01));
  });

  test('Section changes always retain the common dark theme', () async {
    for (final index in [0, 1, 2, 999]) {
      await AppTheme.setTheme(index: index);
      expect(AppTheme.theme.value, same(AppTheme.darkTheme));
      expect(AppTheme.theme.value.brightness, Brightness.dark);
    }
  });

  for (final dark in [false, true]) {
    for (final width in [390.0, 1280.0]) {
      testWidgets('Form interaction at $width, dark=$dark', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final form = GlobalKey<FormState>();
        var submits = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: CustomCardWidget(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Welcome to Private Deals'),
                          const SizedBox(height: 24),
                          TitleTextField(
                            name: 'Mobile number',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter your mobile number'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          CustomElevatedButton(
                            text: 'Continue',
                            onPressed: () {
                              if (form.currentState!.validate()) submits++;
                            },
                          ),
                          const SizedBox(height: 12),
                          const CustomOutlinedButton(
                            text: 'Unavailable',
                            onPressed: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Enter your mobile number'), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), '9876543210');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(submits, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
