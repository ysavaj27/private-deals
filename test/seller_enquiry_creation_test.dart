import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/desktop_enquiry_dialog_view.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/enquiry/enquiry_dialog_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

Future<void> _openDialog(
  WidgetTester tester,
  List<Object?> results, {
  double width = 390,
  int? settlementDays = 2,
}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: TextButton(
          onPressed: () async {
            results.add(
              await showCustomDialog(
                DesktopEnquiryDialogView(
                  'northstar',
                  initialType: InvestmentTypeEnum.sell,
                  initialQuantity: 100,
                  initialOfferPrice: 1240.5,
                  initialSettlementDays: settlementDays,
                ),
              ),
            );
          },
          child: const Text('Open enquiry'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open enquiry'));
  await tester.pumpAndSettle();
}

Future<void> Function() _submit(WidgetTester tester) =>
    tester
            .widget<CustomElevatedButton>(
              find.widgetWithText(CustomElevatedButton, 'Submit'),
            )
            .onPressed
        as Future<void> Function();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HttpClientAdapter originalAdapter;
  late ConfigModel originalConfig;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.setUser(prefUser: identity());
    originalAdapter = dioConfig.dio.httpClientAdapter;
    originalConfig = app.config;
    app.configModel(
      ConfigModel.fromJson({
        'settlement_days': [
          {'value': 2, 'label': 'T+2'},
        ],
      }),
    );
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    app.configModel(originalConfig);
    await app.clear();
    Get.reset();
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets(
      'pending seller creation prevents dismissal, edits, and duplicate POSTs at $width',
      (tester) async {
        late Completer<void> started;
        late Completer<ResponseBody> reply;
        await tester.runAsync(() async {
          started = Completer<void>();
          reply = Completer<ResponseBody>();
        });
        final adapter = FakeAdapter((_) {
          started.complete();
          return reply.future;
        });
        dioConfig.dio.httpClientAdapter = adapter;
        final results = <Object?>[];
        await _openDialog(tester, results, width: width);
        final submit = _submit(tester);
        late Future<void> pending;
        await tester.runAsync(() async {
          pending = submit();
          await started.future;
          await submit();
        });
        await tester.pump();

        expect(adapter.requests, hasLength(1));
        expect(
          tester
              .widget<CustomOutlinedButton>(
                find.widgetWithText(CustomOutlinedButton, 'Close'),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widgetList<TextFormField>(find.byType(TextFormField))
              .every((field) => field.enabled == false),
          isTrue,
        );
        expect(
          tester
              .widgetList<Radio<InvestmentTypeEnum>>(
                find.byType(Radio<InvestmentTypeEnum>),
              )
              .every((radio) => radio.enabled == false),
          isTrue,
        );
        expect(
          tester
              .widget<SettlementDaysDropdown>(
                find.byType(SettlementDaysDropdown),
              )
              .enabled,
          isFalse,
        );
        await tester.tapAt(const Offset(2, 2));
        await tester.pump();
        await Get.key.currentState!.maybePop();
        await tester.pump();
        expect(find.byType(DesktopEnquiryDialogView), findsOneWidget);
        expect(results, isEmpty);

        await tester.runAsync(() async {
          reply.complete(response({'status': 1, 'message': 'Enquiry created'}));
          await pending;
          // A queued click after success must not create another enquiry while
          // the dialog is still in its closing animation.
          await submit();
        });
        await tester.pumpAndSettle();
        expect(adapter.requests, hasLength(1));
        expect(adapter.requests.single.data, {
          'deal_type': 'sell',
          'company_slug': 'northstar',
          'quantity': 100,
          'share_price': 1240.5,
          'settlement_days': 2,
        });
        expect(results, [true]);
        expect(find.byType(DesktopEnquiryDialogView), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('failed creation preserves terms and allows retry', (
    tester,
  ) async {
    final adapter = FakeAdapter(
      (_) async => response({'status': 0, 'message': 'Please try again'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final results = <Object?>[];
    await _openDialog(tester, results);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      '  Seller terms  ',
    );
    await tester.runAsync(_submit(tester));
    await tester.pumpAndSettle();
    expect(results, isEmpty);
    expect(find.byType(DesktopEnquiryDialogView), findsOneWidget);
    expect(adapter.requests.single.data['notes'], 'Seller terms');
    expect(
      tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .every((field) => field.enabled != false),
      isTrue,
    );
    await tester.runAsync(_submit(tester));
    await tester.pumpAndSettle();
    expect(adapter.requests, hasLength(2));
    await tester.ensureVisible(find.text('Close'));
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(results, [null]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unsupported settlement and invalid terms do not create', (
    tester,
  ) async {
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    await _openDialog(tester, [], settlementDays: 99);
    await tester.enterText(find.byType(TextFormField).at(0), '1.5');
    await tester.enterText(find.byType(TextFormField).at(1), 'NaN');
    await tester.runAsync(_submit(tester));
    await tester.pumpAndSettle();
    expect(adapter.requests, isEmpty);
    expect(find.text('Quantity must be at least 1'), findsOneWidget);
    expect(find.text('Offer price must be greater than 0'), findsOneWidget);
    expect(find.text('Select a settlement cycle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('notes validation matches the text field character limit', () async {
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    final c = EnquiryDialogCtrl(slug: 'northstar', onCreated: () {});
    addTearDown(() => c.onDelete());
    c.quantityCtrl.text = '100';
    c.offerPriceCtrl.text = '1240.5';
    c.settlementDays.value = 2;
    c.notesCtrl.text = 'a' * 2001;
    await c.onPress();
    expect(adapter.requests, isEmpty);
    expect(c.notesError.value, 'Notes must be 2000 characters or fewer');
    c.quantityCtrl.text = '0';
    c.notesCtrl.text = '🙂' * 1500;
    await c.onPress();
    expect(adapter.requests, isEmpty);
    expect(c.notesError.value, isEmpty);
    expect(c.quantityError.value, isNotEmpty);
  });

  testWidgets(
    'late creation after logout cannot close the new account screen',
    (tester) async {
      late Completer<void> started;
      late Completer<ResponseBody> reply;
      await tester.runAsync(() async {
        started = Completer<void>();
        reply = Completer<ResponseBody>();
      });
      dioConfig.dio.httpClientAdapter = FakeAdapter((_) {
        started.complete();
        return reply.future;
      });
      final results = <Object?>[];
      await _openDialog(tester, results);
      final submit = _submit(tester);
      late Future<void> pending;
      await tester.runAsync(() async {
        pending = submit();
        await started.future;
        await app.setUser(prefUser: identity('Institution', 8));
      });
      Get.offAll(() => const Scaffold(body: Text('New account')));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        reply.complete(response({'status': 1}));
        await pending;
        await submit();
      });
      await tester.pumpAndSettle();
      expect(find.text('New account'), findsOneWidget);
      expect(results, [null]);
      expect(tester.takeException(), isNull);
    },
  );
}
