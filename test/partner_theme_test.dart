import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/theme/brand_colors.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:private_deals/src/shared/widgets/custom_text_field.dart';
import 'package:private_deals/src/shared/widgets/custom_card_widget.dart';
import 'package:private_deals/src/shared/widgets/buttons/custom_elevated_button.dart';
import 'package:private_deals/src/shared/widgets/buttons/custom_outlined_button.dart';

void main() {
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
