import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:private_deals/src/shared/widgets/detail_information_row.dart';

void main() {
  for (final dark in [false, true]) {
    for (final width in [320.0, 800.0]) {
      testWidgets('Company facts wrap at $width, dark=$dark', (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  DetailInformationRow(
                    label: 'Registrar and transfer agent',
                    value:
                        'A long company registrar name with multiple words and identifiers',
                  ),
                  DetailInformationRow(
                    label: 'CIN',
                    value: 'U12345MH2024PLC123456',
                  ),
                  DetailInformationRow(label: 'Depository', value: ''),
                ],
              ),
            ),
          ),
        );
        expect(find.text('—'), findsOneWidget);
        expect(find.byType(SelectableText), findsNWidgets(3));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
