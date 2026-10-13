import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page.dart';
import 'package:private_deals/src/features/institution/deals/presentation/create_deal/create_deal_page_ctrl.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page_ctrl.dart';

class _FormController extends CreateDealPageCtrl {
  _FormController({required super.now});

  @override
  Future<void> fetchCompanies() async {
    companies.assignAll([
      LiteCompanyModel(id: 42, brandName: 'Sample company'),
    ]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CreateDealPageCtrl controllerAt(DateTime instant) {
    final controller = CreateDealPageCtrl(now: () => instant);
    addTearDown(controller.onClose);
    return controller;
  }

  test(
    'defaults to Today using the IST calendar date, with mandatory expiry',
    () {
      final controller = controllerAt(DateTime.utc(2026, 10, 12, 20));

      expect(controller.expiryPreset.value, DealExpiryPreset.today);
      expect(controller.expiryDateLabel, '13/10/2026');
      expect(controller.formattedExpiry, '2026-10-13 19:00:00');
      expect(controller.validateExpiry(), isTrue);
    },
  );

  for (final sample in [
    (DateTime.utc(2026, 10, 12), '2026-10-18 19:00:00'),
    (DateTime.utc(2026, 10, 18), '2026-10-18 19:00:00'),
    (DateTime.utc(2026, 12, 31), '2027-01-03 19:00:00'),
  ]) {
    test('This week ends on the current Sunday for ${sample.$1}', () {
      final controller = controllerAt(sample.$1);
      controller.selectExpiryPreset(DealExpiryPreset.thisWeek);

      expect(controller.formattedExpiry, sample.$2);
    });
  }

  for (final sample in [
    (DateTime.utc(2026, 2, 12), '2026-02-28 19:00:00'),
    (DateTime.utc(2028, 2, 12), '2028-02-29 19:00:00'),
    (DateTime.utc(2026, 4, 30), '2026-04-30 19:00:00'),
    (DateTime.utc(2026, 12, 31), '2026-12-31 19:00:00'),
  ]) {
    test('This month ends on the final calendar day for ${sample.$1}', () {
      final controller = controllerAt(sample.$1);
      controller.selectExpiryPreset(DealExpiryPreset.thisMonth);

      expect(controller.formattedExpiry, sample.$2);
    });
  }

  test(
    'rejects Today at and after 7 PM IST and recovers with a later date',
    () {
      var now = DateTime.utc(2026, 10, 12, 13, 29, 59);
      final controller = CreateDealPageCtrl(now: () => now);
      addTearDown(controller.onClose);

      expect(controller.validateExpiry(), isTrue);
      now = DateTime.utc(2026, 10, 12, 13, 30);
      expect(controller.validateExpiry(), isFalse);
      expect(controller.expiryError.value, contains('7:00 PM IST'));
      now = DateTime.utc(2026, 10, 12, 14);
      expect(controller.validateExpiry(), isFalse);
      expect(controller.expiryPreset.value, DealExpiryPreset.today);

      controller.selectExpiryPreset(DealExpiryPreset.thisWeek);
      expect(controller.expiryError.value, isEmpty);
      expect(controller.validateExpiry(), isTrue);
    },
  );

  test('week and month also reject their final day after the cutoff', () {
    // This Sunday is also the last day of the month.
    final controller = controllerAt(DateTime.utc(2027, 1, 31, 13, 30));
    for (final preset in [
      DealExpiryPreset.today,
      DealExpiryPreset.thisWeek,
      DealExpiryPreset.thisMonth,
    ]) {
      controller.selectExpiryPreset(preset);
      expect(controller.validateExpiry(), isFalse);
    }
  });

  test('an open form cannot submit a stale date after midnight', () {
    var now = DateTime.utc(2026, 10, 12, 10);
    final controller = CreateDealPageCtrl(now: () => now);
    addTearDown(controller.onClose);

    now = DateTime.utc(2026, 10, 12, 20);
    expect(controller.validateExpiry(), isFalse);
    controller.selectExpiryPreset(DealExpiryPreset.today);
    expect(controller.formattedExpiry, '2026-10-13 19:00:00');
    expect(controller.validateExpiry(), isTrue);
  });

  for (final type in ['unlisted', 'secondary']) {
    test('$type buy and sell payloads always include expiry at 19:00 IST', () {
      final controller = controllerAt(DateTime.utc(2026, 10, 12));
      controller.dealRoute = DealRouteContext.fromPath(
        '/institution/deals/hot/$type/create',
      );
      controller.selectedCompany.value = LiteCompanyModel(id: 42);
      controller.availableQuantityCtrl.text = '100';
      controller.sharePriceCtrl.text = '100';
      controller.minimumQuantityCtrl.text = '5';

      for (final dealType in ['buy', 'sell']) {
        controller.dealType.value = dealType;
        controller.selectExpiryPreset(DealExpiryPreset.today);
        expect(controller.buildPayload(), containsPair('is_hot_deal', 1));
        expect(
          controller.buildPayload(),
          containsPair('expired_at', '2026-10-12 19:00:00'),
        );
        controller.selectExpiryPreset(DealExpiryPreset.thisMonth);
        expect(
          controller.buildPayload(),
          containsPair('expired_at', '2026-10-31 19:00:00'),
        );
      }
    });
  }

  for (final route in [
    '/institution/deals/hot/unlisted/create',
    '/institution/deals/hot/secondary/create',
    '/institution/deals/manage/secondary/create',
  ]) {
    for (final phone in [true, false]) {
      testWidgets(
        '$route ${phone ? 'phone' : 'desktop'} expiry chip and custom flow',
        (tester) async {
          tester.view.physicalSize = Size(phone ? 390 : 1200, 1000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          addTearDown(Get.reset);
          Get.testMode = true;
          await tester.pumpWidget(
            GetMaterialApp(
              initialRoute: route,
              getPages: [
                GetPage(
                  name: route,
                  binding: BindingsBuilder(() {
                    Get.put<CreateDealPageCtrl>(
                      _FormController(
                        now: () => DateTime.utc(2026, 10, 12, 10),
                      ),
                    );
                  }),
                  page: () => CreateDealPage(),
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          expect(Get.currentRoute, route);
          final controller = Get.find<CreateDealPageCtrl>();

          Finder chip(String label) => find.widgetWithText(ChoiceChip, label);
          Future<void> tapChip(String label) async {
            await tester.ensureVisible(chip(label));
            await tester.tap(chip(label));
            await tester.pumpAndSettle();
          }

          expect(tester.widget<ChoiceChip>(chip('Today')).selected, isTrue);
          expect(find.text('Expiry date *'), findsOneWidget);
          expect(find.text('Select time'), findsNothing);
          expect(find.text('Clear expiry'), findsNothing);
          await tapChip('Today');
          expect(tester.widget<ChoiceChip>(chip('Today')).selected, isTrue);

          await tapChip('This week');
          expect(controller.formattedExpiry, '2026-10-18 19:00:00');
          expect(tester.widget<ChoiceChip>(chip('Today')).selected, isFalse);
          await tapChip('This month');
          expect(controller.formattedExpiry, '2026-10-31 19:00:00');

          await tapChip('Custom');
          expect(find.byType(DatePickerDialog), findsOneWidget);
          expect(find.byType(TimePickerDialog), findsNothing);
          await tester.tap(find.text('Cancel').last);
          await tester.pumpAndSettle();
          expect(controller.expiryPreset.value, DealExpiryPreset.thisMonth);
          expect(controller.formattedExpiry, '2026-10-31 19:00:00');

          await tapChip('Custom');
          await tester.tap(find.text('20'));
          await tester.tap(find.text('Apply'));
          await tester.pumpAndSettle();
          expect(tester.widget<ChoiceChip>(chip('Custom')).selected, isTrue);
          expect(controller.formattedExpiry, '2026-10-20 19:00:00');
          expect(
            find.text('Expires on 20/10/2026 at 7:00 PM IST'),
            findsOneWidget,
          );
          expect(find.byType(TimePickerDialog), findsNothing);

          await tapChip('Custom');
          await tester.tap(find.text('Cancel').last);
          await tester.pumpAndSettle();
          expect(controller.expiryPreset.value, DealExpiryPreset.custom);
          expect(controller.formattedExpiry, '2026-10-20 19:00:00');
          await tapChip('Today');
          expect(controller.formattedExpiry, '2026-10-12 19:00:00');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Custom starts tomorrow once today has reached 7 PM IST', (
    tester,
  ) async {
    final controller = controllerAt(DateTime.utc(2026, 10, 12, 13, 30));
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => controller.pickExpiryDate(context),
            child: const Text('Custom'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();
    final picker = tester.widget<DatePickerDialog>(
      find.byType(DatePickerDialog),
    );
    expect(picker.firstDate, DateTime(2026, 10, 13));
    expect(picker.initialDate, DateTime(2026, 10, 13));
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(controller.formattedExpiry, '2026-10-13 19:00:00');
    expect(controller.validateExpiry(), isTrue);
  });
}
