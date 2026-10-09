import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/channel_partner_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/channel_partner_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog_ctrl.dart';

import 'session_and_api_test.dart' show FakeAdapter, response, identity;

class _Controller extends ChannelPartnerPageCtrl {
  int refreshes = 0;
  @override
  Future<void> getData() async {
    refreshes++;
    error('');
  }
}

void main() {
  late _Controller c;
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    app.validated(true);
    app.configModel(
      ConfigModel.fromJson({
        'enum': {
          'partner_type': {
            'wealthmanager': 'Wealth Manager',
            'distributor': 'Distributor',
            'retailer': 'Retailer',
            'relationmanager': 'Relation Manager',
          },
          'gender': {'male': 'Male', 'female': 'Female', 'other': 'Other'},
        },
      }),
    );
    c = _Controller();
    Get.put<ChannelPartnerPageCtrl>(c);
    c.list.assignAll([
      PartnerUser.fromJson({
        'id': 1,
        'name': 'Aarav Shah',
        'email': 'aarav@example.com',
        'mobile_number': 9876543210,
        'type': 'Retailer',
        'total_invested': 2500000,
        'commission_earned': 50000,
        'investor_count': 12,
        'no_of_startups': 4,
        'is_preipo_access': 1,
      }),
      PartnerUser.fromJson({
        'id': 2,
        'name': 'Summit Wealth Partners',
        'email': 'partners@summit.example.com',
        'mobile_number': 9876543211,
        'type': 'Distributor',
        'total_invested': 7500000,
        'commission_earned': 150000,
        'investor_count': 28,
        'no_of_startups': 8,
        'is_primary_access': 1,
        'is_secondary_access': 1,
        'is_preipo_access': 1,
      }),
      PartnerUser.fromJson({
        'id': 3,
        'name': 'Priya Mehta',
        'email': 'priya@example.com',
        'type': 'Relation Manager',
        'is_blocked': 1,
        'is_preipo_access': 1,
      }),
    ]);
  });
  tearDown(() async {
    Get.reset();
    await app.clear();
  });

  Future<void> show(
    WidgetTester tester, {
    double width = 1280,
    double height = 1100,
    bool dark = true,
    double scale = 1,
    bool form = false,
    double keyboard = 0,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: RepaintBoundary(
          key: const ValueKey('capture'),
          child: form
              ? const Scaffold(body: AddChannelPartnerDialog())
              : const ChannelPartnerView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Search, partner type and sorting work together', (tester) async {
    await show(tester);
    expect(find.text('Showing 3 of 3 partners'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'SUMMIT');
    await tester.pumpAndSettle();
    expect(find.text('Summit Wealth Partners'), findsOneWidget);
    expect(find.text('Aarav Shah'), findsNothing);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Retailer'));
    await tester.pumpAndSettle();
    expect(find.text('Showing 1 of 3 partners'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '9876543211');
    await tester.pumpAndSettle();
    expect(find.text('No matching partners'), findsOneWidget);
    await tester.ensureVisible(find.text('Clear filters'));
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Highest investment').last);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Summit Wealth Partners')).dy,
      lessThan(tester.getTopLeft(find.text('Aarav Shah')).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Loading, retry and first partner empty state', (tester) async {
    c.error('Connection unavailable');
    await show(tester);
    expect(find.text('Connection unavailable'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(c.refreshes, 2);
    c.list.clear();
    await tester.pumpAndSettle();
    expect(find.text('Build your partner network'), findsOneWidget);
    c.isLoading(true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    c.isLoading(false);
    await tester.pumpAndSettle();
  });

  testWidgets('Create dialog clears its controller when reopened', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.text('Add partner'));
    await tester.pumpAndSettle();
    final first = Get.find<AddChannelPartnerDialogCtrl>();
    first.nameCTRL.text = 'Unsaved partner';
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(Get.isRegistered<AddChannelPartnerDialogCtrl>(), false);
    await tester.tap(find.text('Add partner'));
    await tester.pumpAndSettle();
    expect(Get.find<AddChannelPartnerDialogCtrl>().nameCTRL.text, isEmpty);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Create validates inputs and sends selected access once', (
    tester,
  ) async {
    final pending = Completer<void>();
    final adapter = FakeAdapter((_) async {
      await pending.future;
      return response({'status': 1, 'message': 'Partner added'});
    });
    dioConfig.dio.httpClientAdapter = adapter;
    await show(tester);
    await tester.tap(find.text('Add partner'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add partner').last);
    await tester.pumpAndSettle();
    expect(adapter.requests, isEmpty);
    final form = Get.find<AddChannelPartnerDialogCtrl>();
    form.nameCTRL.text = 'Test Partner';
    form.emailCTRL.text = 'partner@example.com';
    form.mobileCTRL.text = '9876543210';
    form.passwordCTRL.text = '12345';
    form.partnerType('Retailer');
    form.gender('Female');
    form.commissionCTRL.text = '2.5';
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add partner').last);
    await tester.pumpAndSettle();
    expect(find.text('Use at least 6 characters'), findsOneWidget);
    expect(adapter.requests, isEmpty);
    form.passwordCTRL.text = 'test-password';
    form.isPrimary(false);
    form.isSecondary(true);
    form.isPreIpo(false);
    await tester.tap(find.widgetWithText(FilledButton, 'Add partner').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(adapter.requests.length, 1);
    expect(adapter.requests.single.data, containsPair('is_primary_access', 0));
    expect(
      adapter.requests.single.data,
      containsPair('is_secondary_access', 1),
    );
    expect(adapter.requests.single.data, containsPair('is_preipo_access', 0));
    expect(
      tester
          .widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Cancel'))
          .onPressed,
      isNull,
    );
    pending.complete();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Add channel partner'), findsNothing);
    expect(c.refreshes, 2);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('Relation managers do not require commission', (tester) async {
    await show(tester, form: true);
    final form = Get.find<AddChannelPartnerDialogCtrl>();
    form.partnerType('Relation Manager');
    await tester.pumpAndSettle();
    expect(find.textContaining('Commission is not required'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is TitleTextField && w.controller == form.commissionCTRL,
      ),
      findsNothing,
    );
    final password = tester.widget<TextField>(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is TitleTextField && w.controller == form.passwordCTRL,
        ),
        matching: find.byType(TextField),
      ),
    );
    expect(password.obscureText, true);
  });

  testWidgets(
    'Directory and form fit narrow screens, large text and both themes',
    (tester) async {
      c.list.first.name = 'A very long channel partner organisation name for responsive layouts';
      c.list.first.email = 'a.long.partner.email.address@example.com';
      for (final width in [360.0, 768.0, 1280.0]) {
        for (final dark in [false, true]) {
          await show(tester, width: width, dark: dark, scale: 1.5);
          await tester.scrollUntilVisible(
            find.text(
              'A very long channel partner organisation name for responsive layouts',
            ),
            250,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'directory $width $dark',
          );
          await tester.scrollUntilVisible(
            find.text('Add partner'),
            -300,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(find.text('Add partner'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Add partner'));
          await tester.pumpAndSettle();
          expect(find.text('Add channel partner'), findsOneWidget);
          await tester.ensureVisible(
            find.widgetWithText(CheckboxListTile, 'Unlisted Shares'),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'form $width $dark');
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
        }
      }
    },
  );

  testWidgets('Creation failure preserves fields and permits retry', (
    tester,
  ) async {
    final adapter = FakeAdapter(
      (_) async =>
          response({'status': 0, 'message': 'Please check these details'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    await show(tester);
    await tester.tap(find.text('Add partner'));
    await tester.pumpAndSettle();
    final form = Get.find<AddChannelPartnerDialogCtrl>();
    form.nameCTRL.text = 'Test Partner';
    form.emailCTRL.text = 'partner@example.com';
    form.mobileCTRL.text = '9876543210';
    form.passwordCTRL.text = 'test-password';
    form.gender('Female');
    form.partnerType('Relation Manager');
    form.commissionCTRL.text = '5';
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Add partner').last);
    await tester.pumpAndSettle();
    expect(adapter.requests.single.data, isNot(contains('commission')));
    expect(form.isLoading(), false);
    expect(form.nameCTRL.text, 'Test Partner');
    expect(find.text('Add channel partner'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Retailers see only permitted role and products with keyboard open',
    (tester) async {
      await app.setUser(
        prefUser: {
          ...identity('Retailer'),
          'is_primary_access': 0,
          'is_secondary_access': 0,
        },
      );
      await show(
        tester,
        form: true,
        width: 390,
        height: 844,
        keyboard: 300,
        scale: 1.3,
      );
      // Open the role menu to verify that only Relation Manager is offered.
      await tester.ensureVisible(find.text('Select partner type'));
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      expect(find.text('Relation Manager').last, findsOneWidget);
      expect(find.text('Distributor'), findsNothing);
      expect(find.text('Retailer'), findsNothing);
      await tester.tap(find.text('Relation Manager').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(CheckboxListTile, 'Unlisted Shares'),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(CheckboxListTile, 'Private Equity'),
        findsNothing,
      );
      expect(
        find.widgetWithText(CheckboxListTile, 'LP Secondary'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Capture channel partner previews when requested', (
    tester,
  ) async {
    if (!const bool.fromEnvironment('PARTNER_PREVIEWS')) return;
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
    for (final form in [false, true]) {
      for (final width in [390.0, 1280.0]) {
        for (final dark in [false, true]) {
          await show(
            tester,
            width: width,
            height: form
                ? 1000
                : width == 390
                ? 1900
                : 1440,
            dark: dark,
            form: form,
          );
          await tester.runAsync(() async {
            final image = await tester
                .renderObject<RenderRepaintBoundary>(
                  find.byKey(const ValueKey('capture')),
                )
                .toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final dir = Directory('build/channel-partner-previews')
              ..createSync(recursive: true);
            File(
              '${dir.path}/${form ? 'form' : 'directory'}-${width.toInt()}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytesSync(bytes!.buffer.asUint8List());
            image.dispose();
          });
          expect(tester.takeException(), isNull);
        }
      }
    }
  });
}
