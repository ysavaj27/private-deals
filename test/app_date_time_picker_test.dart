import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page_ctrl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DateTime? dateResult;
  TimeOfDay? timeResult;

  Future<void> show(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    bool dark = false,
    double scale = 1,
    DateTime? initialDate,
    DatePickerEntryMode dateMode = DatePickerEntryMode.calendar,
    TimePickerEntryMode? timeMode,
    TimeOfDay initialTime = const TimeOfDay(hour: 14, minute: 30),
    bool use24HourFormat = true,
  }) async {
    dateResult = null;
    timeResult = null;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey('capture'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: Wrap(
                  spacing: 16,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        dateResult = await AppDateTimePicker.date(
                          context: context,
                          firstDate: DateTime(2026, 10, 1),
                          lastDate: DateTime(2026, 10, 31),
                          initialDate: initialDate ?? DateTime(2026, 10, 9),
                          currentDate: DateTime(2026, 10, 9),
                          title: 'Investment date',
                          initialEntryMode: dateMode,
                        );
                      },
                      child: const Text('Open date'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        timeResult = await AppDateTimePicker.time(
                          context: context,
                          initialTime: initialTime,
                          title: 'Expiry time · IST',
                          use24HourFormat: use24HourFormat,
                          initialEntryMode: timeMode,
                        );
                      },
                      child: const Text('Open time'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(TextButton, label));
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester, String kind) async {
    await tester.tap(find.text('Open $kind'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Dates clamp stale selections, preserve bounds and cancel without a value',
    (tester) async {
      for (final initial in [DateTime(2020), DateTime(2030)]) {
        await show(tester, initialDate: initial);
        await open(tester, 'date');
        final dialog = tester.widget<DatePickerDialog>(
          find.byType(DatePickerDialog),
        );
        expect(
          dialog.initialDate,
          initial.year == 2020 ? DateTime(2026, 10, 1) : DateTime(2026, 10, 31),
        );
        expect(dialog.firstDate, DateTime(2026, 10, 1));
        expect(dialog.lastDate, DateTime(2026, 10, 31));
        await tap(tester, 'Cancel');
        expect(dateResult, isNull);
      }
      await show(tester);
      await open(tester, 'date');
      await tester.tap(find.text('20'));
      await tap(tester, 'Apply');
      expect(dateResult, DateTime(2026, 10, 20));
    },
  );

  testWidgets('Manual date input validates format and range', (tester) async {
    await show(tester, dateMode: DatePickerEntryMode.input);
    await open(tester, 'date');
    await tester.enterText(find.byType(TextFormField), 'invalid');
    await tap(tester, 'Apply');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(dateResult, isNull);
    await tester.enterText(find.byType(TextFormField), '11/01/2026');
    await tap(tester, 'Apply');
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '10/18/2026');
    await tap(tester, 'Apply');
    expect(dateResult, DateTime(2026, 10, 18));
  });

  testWidgets('Time supports keyboard entry, 24-hour values and cancellation', (
    tester,
  ) async {
    await show(tester, initialTime: const TimeOfDay(hour: 0, minute: 5));
    await open(tester, 'time');
    expect(
      tester
          .widget<TimePickerDialog>(find.byType(TimePickerDialog))
          .initialEntryMode,
      TimePickerEntryMode.input,
    );
    await tester.enterText(find.byType(TextFormField).at(0), '23');
    await tester.enterText(find.byType(TextFormField).at(1), '59');
    await tap(tester, 'Apply');
    expect(timeResult, const TimeOfDay(hour: 23, minute: 59));
    await open(tester, 'time');
    await tap(tester, 'Cancel');
    expect(timeResult, isNull);
  });

  testWidgets('Midnight, noon and afternoon survive 12-hour input', (
    tester,
  ) async {
    for (final hour in [0, 12, 15]) {
      await show(
        tester,
        initialTime: TimeOfDay(hour: hour, minute: 5),
        use24HourFormat: false,
      );
      await open(tester, 'time');
      await tap(tester, 'Apply');
      expect(timeResult, TimeOfDay(hour: hour, minute: 5));
    }
  });

  testWidgets('Mobile starts with the clock and permits keyboard mode', (
    tester,
  ) async {
    await show(tester, size: const Size(390, 844));
    await open(tester, 'time');
    expect(
      tester
          .widget<TimePickerDialog>(find.byType(TimePickerDialog))
          .initialEntryMode,
      TimePickerEntryMode.dial,
    );
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), '09');
    await tester.enterText(find.byType(TextFormField).at(1), '45');
    await tap(tester, 'Apply');
    expect(timeResult, const TimeOfDay(hour: 9, minute: 45));
  });

  testWidgets(
    'Pickers fit small screens, landscape and enlarged text in both themes',
    (tester) async {
      for (final size in [
        const Size(320, 640),
        const Size(844, 390),
        const Size(1280, 900),
      ]) {
        for (final dark in [false, true]) {
          await show(tester, size: size, dark: dark, scale: 1.5);
          for (final kind in ['date', 'time']) {
            await open(tester, kind);
            expect(
              tester.takeException(),
              isNull,
              reason: '$kind $size dark=$dark',
            );
            await tap(tester, 'Cancel');
          }
        }
      }
    },
  );

  testWidgets(
    'Deal expiry uses the common pickers and keeps its IST date boundary',
    (tester) async {
      await show(tester);
      final controller = CreateDealPageCtrl();
      addTearDown(controller.onClose);
      controller.expiryDate(DateTime(2020));
      final now = DateTime.now().toUtc().add(CreateDealPageCtrl.istOffset);
      final today = DateTime(now.year, now.month, now.day);
      final dateRequest = controller.pickExpiryDate(
        tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();
      final dialog = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(dialog.helpText, 'Expiry date · IST');
      expect(dialog.firstDate, today);
      expect(dialog.currentDate, today);
      await tap(tester, 'Apply');
      await dateRequest;
      expect(controller.expiryDate(), today);

      controller.expiryTime(const TimeOfDay(hour: 15, minute: 30));
      final timeRequest = controller.pickExpiryTime(
        tester.element(find.byType(Scaffold)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Expiry time · IST'), findsOneWidget);
      expect(
        MediaQuery.alwaysUse24HourFormatOf(
          tester.element(find.byType(TimePickerDialog)),
        ),
        isTrue,
      );
      await tap(tester, 'Apply');
      await timeRequest;
      expect(controller.expiryTime(), const TimeOfDay(hour: 15, minute: 30));
      expect(controller.expiryTimeLabel, '15:30 IST');
    },
  );

  testWidgets('Capture shared picker previews when requested', (tester) async {
    if (!const bool.fromEnvironment('PICKER_PREVIEWS')) return;
    await tester.runAsync(() async {
      for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        await (FontLoader(
          'inter',
        )..addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'))).load();
      }
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    for (final size in [const Size(390, 844), const Size(900, 760)]) {
      for (final dark in [false, true]) {
        await show(tester, size: size, dark: dark);
        for (final kind in ['date', 'time']) {
          await open(tester, kind);
          await tester.runAsync(() async {
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('capture')),
            );
            final image = await boundary.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = Directory('build/picker-previews')
              ..createSync(recursive: true);
            File(
              '${directory.path}/$kind-${size.width.toInt()}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
          await tap(tester, 'Cancel');
        }
      }
    }
  });
}
