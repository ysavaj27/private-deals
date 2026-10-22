import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart'
    as institution;
import 'package:private_deals/src/features/institution/support/plugins/toast.dart'
    as institution;
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/plugins/toast.dart';
import 'package:private_deals/src/shared/theme/partner_theme.dart';
import 'package:private_deals/src/shared/widgets/app_toast.dart';

void main() {
  tearDown(() => Get.reset());

  testWidgets('toast follows desktop and compact placement when resized', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('Workspace'))),
    );
    await tester.pumpAndSettle();
    showAppToast('Changes saved.', duration: const Duration(minutes: 1));
    await tester.pumpAndSettle();

    for (final width in [1440.0, 1200.0, 1199.0, 1024.0, 768.0, 390.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      final card = tester.getRect(find.byType(AppToastCard));
      expect(card.top, closeTo(16, 0.1));
      if (width >= 1200) {
        expect(card.right, closeTo(width - 16, 0.1));
      } else {
        expect(card.center.dx, closeTo(width / 2, 0.1));
      }
      expect(card.width, lessThanOrEqualTo(440));
      expect(card.left, greaterThanOrEqualTo(16));
      expect(card.right, lessThanOrEqualTo(width - 16));
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.byTooltip('Dismiss notification'));
    await tester.pumpAndSettle();
  });

  testWidgets('both workspaces use the same toast and dismiss only the toast', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: DarkTheme.theme,
        home: const Scaffold(body: Text('Workspace')),
      ),
    );
    await tester.pumpAndSettle();

    for (final show in <VoidCallback>[
      () => toast('Changes saved.', MessageEnum.success),
      () =>
          institution.toast('Changes saved.', institution.MessageEnum.success),
    ]) {
      show();
      await tester.pumpAndSettle();
      expect(find.byType(AppToastCard), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Changes saved.'), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss notification'));
      await tester.pumpAndSettle();
      expect(find.byType(AppToastCard), findsNothing);
      expect(find.text('Workspace'), findsOneWidget);
    }
  });

  testWidgets(
    'empty messages are ignored and an explicit duration is honored',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(home: const Scaffold(body: Text('Workspace'))),
      );
      await tester.pumpAndSettle();
      toast('   ');
      await tester.pumpAndSettle();
      expect(find.byType(AppToastCard), findsNothing);

      toast('Copied', MessageEnum.info, const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(AppToastCard), findsNothing);
    },
  );

  testWidgets(
    'compact cards accommodate long text and large accessibility text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final theme in [DarkTheme.theme, LightTheme.theme]) {
        for (final type in AppToastType.values) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: MediaQuery(
                data: const MediaQueryData(
                  size: Size(320, 568),
                  textScaler: TextScaler.linear(2),
                ),
                child: Scaffold(
                  body: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AppToastCard(
                        type: type,
                        message:
                            'Your request could not be completed. '
                                'Please review the details and try again. ' *
                            5,
                        onDismiss: () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.text(type.label), findsOneWidget);
          expect(find.byIcon(type.icon), findsOneWidget);
          final card = tester.getRect(find.byType(AppToastCard));
          expect(card.left, greaterThanOrEqualTo(16));
          expect(card.right, lessThanOrEqualTo(304));
          expect(card.bottom, lessThan(568));
          expect(
            find.byTooltip('Dismiss notification').hitTestable(),
            findsOneWidget,
          );
        }
      }
    },
  );

  testWidgets('accessible navigation keeps toast visible and reduces motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          accessibleNavigation: true,
          disableAnimations: true,
        );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: Text('Workspace'))),
    );
    await tester.pumpAndSettle();
    showAppToast('Review your details.', type: AppToastType.alert);
    await tester.pumpAndSettle();
    final snackbar = tester.widget<GetSnackBar>(find.byType(GetSnackBar));
    expect(snackbar.animationDuration, Duration.zero);
    await tester.pump(const Duration(seconds: 20));
    expect(find.text('Review your details.'), findsOneWidget);
    await tester.tap(find.byTooltip('Dismiss notification'));
    await tester.pumpAndSettle();
    expect(find.byType(AppToastCard), findsNothing);
  });
}
