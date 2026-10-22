import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/institution/legacy/features/sell_enquiries/sell_enquiries_page.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'enquiry_flow_test.dart' show inquiry, quotePayload;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  late HttpClientAdapter originalAdapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.setUser(prefUser: identity());
    originalAdapter = dioConfig.dio.httpClientAdapter;
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('seller accepts quotes only on own open enquiries at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [
            inquiry('open', quotes: [quotePayload(uuid: 'other-quote')])
              ..['uuid'] = 'other-enquiry'
              ..['partner'] = {'id': 8, 'name': 'Another partner'},
            inquiry('open', quotes: [quotePayload(uuid: 'own-quote')]),
          ],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SellEnquiriesPage())),
      );
      await tester.pumpAndSettle();
      expect(adapter.requests.single.path, EnquiryApi.partnerPath);
      expect(
        find.byKey(const ValueKey('enquiry-accept-quote-other-quote')),
        findsNothing,
      );
      final ownQuote = find.byKey(
        const ValueKey('enquiry-accept-quote-own-quote'),
      );
      await tester.scrollUntilVisible(
        ownQuote,
        250,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ).first,
      );
      expect(ownQuote, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final state in ['locked', 'converted', 'rejected', 'withdrawn']) {
    testWidgets('incoming $state enquiry ignores a stale pending quote', (
      tester,
    ) async {
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [inquiry(state, myQuote: quotePayload())],
        }),
      );
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(body: EnquiriesPage(institution: true)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.widgetWithText(OutlinedButton, 'Reject'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      expect(find.text('Replace quote'), findsNothing);
      expect(find.text('Withdraw quote'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'failed seller decision refreshes state and recovers after list failure',
    (tester) async {
      var lists = 0;
      final adapter = FakeAdapter((request) async {
        if (request.method == 'POST') {
          return response({'status': 0, 'message': 'Already converted.'});
        }
        lists++;
        if (lists == 2) {
          return response({'status': 0, 'message': 'Connection unavailable.'});
        }
        return response({
          'status': 1,
          'data': [inquiry(lists == 1 ? 'open' : 'converted')],
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SellEnquiriesPage())),
      );
      await tester.pumpAndSettle();
      final withdraw = find.widgetWithText(OutlinedButton, 'Withdraw');
      await tester.ensureVisible(withdraw);
      await tester.pumpAndSettle();
      await tester.tap(withdraw);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Withdraw'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load enquiries'), findsOneWidget);
      expect(withdraw, findsNothing);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Converted to transaction'), findsOneWidget);
      expect(withdraw, findsNothing);
      expect(
        adapter.requests.where((r) => r.method == 'POST').single.path,
        '${EnquiryApi.partnerPath}/withdraw',
      );
      expect(lists, 3);
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'seller rejection requires reason and submits once while pending',
    (tester) async {
      final pending = Completer<ResponseBody>();
      final started = Completer<void>();
      var rejected = false;
      final adapter = FakeAdapter((request) async {
        if (request.method == 'POST') {
          started.complete();
          final result = await pending.future;
          rejected = true;
          return result;
        }
        return response({
          'status': 1,
          'data': [inquiry(rejected ? 'rejected' : 'locked', side: 'sell')],
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: SellEnquiriesPage())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Reject'));
      await tester.pumpAndSettle();
      final confirm = find.descendant(
        of: find.byType(EnquiryDecisionDialog),
        matching: find.widgetWithText(FilledButton, 'Reject'),
      );
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(find.text('Enter a rejection reason'), findsOneWidget);
      expect(adapter.requests.where((r) => r.method == 'POST'), isEmpty);
      await tester.enterText(find.byType(TextFormField), '  Terms changed  ');
      await tester.tap(confirm);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => started.future);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Reject'),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'))
            .onPressed,
        isNull,
      );
      pending.complete(response({'status': 1, 'message': 'Enquiry rejected.'}));
      await tester.pumpAndSettle();
      final post = adapter.requests.where((r) => r.method == 'POST').single;
      expect(post.path, '${EnquiryApi.partnerPath}/reject');
      expect(post.data, {'uuid': 'inquiry-1', 'reason': 'Terms changed'});
      expect(find.widgetWithText(FilledButton, 'Approve'), findsNothing);
      Get.closeAllSnackbars();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
