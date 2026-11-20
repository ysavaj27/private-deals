import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/auth/presentation/change_password/required_password_dialog.dart';

import 'session_and_api_test.dart' show identity;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  testWidgets('admin-created account must set a password before continuing', (
    tester,
  ) async {
    await app.setUser(
      prefUser: {...identity('Wealth Manager'), 'ask_password_change': 1},
    );
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    await tester.pump();

    final shown = RequiredPasswordReset.maybeShow();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Set your password'), findsOneWidget);
    expect(find.textContaining('created by an administrator'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    final dialog = tester.element(find.text('Set your password'));
    final navigator = Navigator.of(dialog, rootNavigator: true);
    // maybePop returns true when the request is handled, including a veto.
    await navigator.maybePop();
    await tester.pump();
    expect(find.text('Set your password'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pump();
    expect(find.text('Set your password'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'abc');
    await tester.enterText(find.byType(EditableText).at(1), 'abc');
    await tester.tap(find.text('Save password'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.text('Set your password'), findsOneWidget);

    final route = ModalRoute.of(dialog);
    navigator.removeRoute(route!);
    await tester.pump();
    await shown.timeout(const Duration(seconds: 2));
  });

  testWidgets('dialog stays closed after the password flag is cleared', (
    tester,
  ) async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    await RequiredPasswordReset.maybeShow();
    await tester.pump();
    expect(find.text('Set your password'), findsNothing);
  });
}
