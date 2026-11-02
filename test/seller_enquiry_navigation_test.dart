import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/core/permissions/access_policy.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_quote_dialog.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart'
    as seller;
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/desktop_sidebar.dart'
    as partner;
import 'package:private_deals/src/shared/app_exports.dart';

import 'enquiry_flow_test.dart'
    show inquiry, quotePayload, seedSettlementConfig;
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

Map<String, dynamic> entry(String uuid, String side, int owner) =>
    inquiry('open', side: side)
      ..['uuid'] = uuid
      ..['company'] = {'brand_name': uuid}
      ..['partner'] = {'id': owner, 'name': 'Partner $owner'};

void main() {
  late HttpClientAdapter originalAdapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity());
    seedSettlementConfig();
    originalAdapter = dioConfig.dio.httpClientAdapter;
  });

  tearDown(() async {
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  Future<void> mount(WidgetTester tester, String path, double width) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(initialRoute: path, getPages: Pages.pages),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, path);
    expect(find.byType(partner.DSideBarWidget), findsNothing);
    if (width >= 1024) {
      expect(find.byType(seller.DSideBarWidget), findsOneWidget);
    }
  }

  Future<void> select(WidgetTester tester, String label) async {
    // Desktop sidebar and compact sub-tabs precede the page title.
    final target = find.text(label).first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  test(
    'shared My Inquiry URL grants only the intended workspace access',
    () async {
      expect(SessionNavigation.check(Routes.myInquiries), AccessResult.allowed);
      expect(
        SessionNavigation.destination(Routes.myInquiries),
        Routes.myInquiries,
      );
      expect(
        SessionNavigation.check('/wealth-manager/investors'),
        AccessResult.forbidden,
      );
      expect(
        SessionNavigation.check('/institution/sell-enquiries'),
        AccessResult.allowed,
      );
      for (final role in ['Wealth Manager', 'Distributor', 'Retailer']) {
        await app.setUser(prefUser: identity(role));
        expect(
          SessionNavigation.check(Routes.myInquiries),
          AccessResult.allowed,
        );
        expect(
          SessionNavigation.check('/institution/sell-enquiries'),
          AccessResult.forbidden,
        );
      }
      await app.setUser(prefUser: identity('Relation Manager'));
      expect(
        SessionNavigation.check(Routes.myInquiries),
        AccessResult.forbidden,
      );
    },
  );

  for (final width in [390.0, 1440.0]) {
    for (final initialPath in [
      Routes.myInquiries,
      '/institution/sell-enquiries',
    ]) {
      testWidgets(
        'seller enquiry sections isolate lists and navigation from $initialPath at $width',
        (tester) async {
          final adapter = FakeAdapter(
            (_) async => response({
              'status': 1,
              'data': [
                entry('Own buy', 'buy', 7),
                entry('Own sell', 'sell', 7),
                entry('Incoming buy', 'buy', 9),
                entry('Incoming sell', 'sell', 9),
              ],
            }),
          );
          dioConfig.dio.httpClientAdapter = adapter;
          await mount(tester, initialPath, width);
          expect(Get.find<SellerHomePageCtrl>().isEnquiriesSection, isTrue);
          expect(
            Get.find<SellerHomePageCtrl>().enquiriesExpanded.value,
            isTrue,
          );
          expect(Get.find<SellerHomePageCtrl>().phoneNavIndex, 3);
          expect(
            adapter.requests
                .where(
                  (r) =>
                      r.path == EnquiryApi.partnerPath ||
                      r.path == EnquiryApi.institutionPath,
                )
                .single
                .path,
            initialPath == Routes.myInquiries
                ? EnquiryApi.partnerPath
                : EnquiryApi.institutionPath,
          );

          if (initialPath != Routes.myInquiries) {
            await select(tester, 'My Inquiry');
          }
          expect(find.text('Own buy'), findsOneWidget);
          expect(find.text('Incoming buy'), findsNothing);
          expect(find.text('Incoming sell'), findsNothing);
          expect(find.text('All (2)'), findsOneWidget);
          expect(find.text('Buy (1)'), findsOneWidget);
          expect(find.text('Sell (1)'), findsOneWidget);
          expect(find.text('Accept & buy'), findsNothing);
          expect(find.text('Approve'), findsNothing);
          await tester.tap(find.byKey(const ValueKey('inquiry-type-sell')));
          await tester.pumpAndSettle();
          expect(find.text('Own buy'), findsNothing);
          expect(find.text('Own sell'), findsOneWidget);

          await select(tester, 'All Enquiries');
          expect(Get.currentRoute, '/institution/sell-enquiries');
          expect(find.text('Incoming buy'), findsOneWidget);
          expect(find.text('Own buy'), findsNothing);
          expect(find.text('Own sell'), findsNothing);
          expect(find.text('All (2)'), findsOneWidget);
          for (final side in ['buy', 'sell']) {
            await tester.tap(find.byKey(ValueKey('inquiry-type-$side')));
            await tester.pumpAndSettle();
            expect(find.text('Incoming $side'), findsOneWidget);
            expect(find.text('Approve'), findsOneWidget);
            expect(find.text('Reject'), findsOneWidget);
            expect(find.text('Send quote'), findsOneWidget);
          }
          expect(find.text('Withdraw'), findsNothing);
          expect(adapter.requests.last.path, EnquiryApi.institutionPath);

          await select(tester, 'My Inquiry');
          expect(Get.currentRoute, Routes.myInquiries);
          expect(find.text('Own buy'), findsOneWidget);
          expect(find.text('Incoming buy'), findsNothing);
          expect(adapter.requests.last.path, EnquiryApi.partnerPath);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets('Partner My Enquiries still resolves its tab and Partner shell', (
    tester,
  ) async {
    await app.setUser(prefUser: identity('Wealth Manager'));
    final adapter = FakeAdapter(
      (request) async => response({
        'status': 1,
        'data': request.path == EnquiryApi.partnerPath
            ? [entry('Own buy', 'buy', 7), entry('Other sell', 'sell', 9)]
            : [],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    tester.view.physicalSize = const Size(1440, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(initialRoute: Routes.myInquiries, getPages: Pages.pages),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, Routes.myInquiries);
    expect(find.byType(partner.DSideBarWidget), findsOneWidget);
    expect(find.byType(seller.DSideBarWidget), findsNothing);
    expect(find.text('Own buy'), findsOneWidget);
    expect(find.text('Other sell'), findsOneWidget);
    expect(find.text('Accept & buy'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  for (final side in ['buy', 'sell']) {
    for (final action in ['accept', 'reject', 'quote']) {
      testWidgets(
        'All Enquiries $side $action uses Institution payload and refreshes',
        (tester) async {
          var submitted = false;
          final adapter = FakeAdapter((request) async {
            if (request.method == 'POST') {
              submitted = true;
              return response({'status': 1, 'message': 'Request saved.'});
            }
            final item = entry('Incoming $side', side, 9);
            if (submitted) {
              if (action == 'quote') {
                item['my_quote'] = quotePayload();
              } else {
                item['enquiry_status'] = action == 'accept'
                    ? 'locked'
                    : 'rejected';
              }
            }
            return response({
              'status': 1,
              'data': [item],
            });
          });
          dioConfig.dio.httpClientAdapter = adapter;
          await mount(tester, '/institution/sell-enquiries', 1440);
          final label = action == 'quote'
              ? 'Send quote'
              : action == 'accept'
              ? 'Approve'
              : 'Reject';
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
          expect(find.text('Select the investor'), findsNothing);
          final dialog = find.byType(
            action == 'quote' ? EnquiryQuoteDialog : EnquiryDecisionDialog,
          );
          await tester.tap(
            find.descendant(
              of: dialog,
              matching: find.widgetWithText(FilledButton, label),
            ),
          );
          await tester.pumpAndSettle();
          final post = adapter.requests.where((r) => r.method == 'POST').single;
          expect(post.path, '${EnquiryApi.institutionPath}/$action');
          expect(post.data, {
            'uuid': 'Incoming $side',
            if (action == 'reject') 'reason': null,
            if (action == 'quote') ...{
              'quantity': 10,
              'share_price': 100.0,
              'settlement_days': 1,
            },
          });
          expect(
            adapter.requests
                .where((r) => r.path == EnquiryApi.institutionPath)
                .length,
            2,
          );
          expect(find.text('Approve'), findsNothing);
          if (action == 'quote') {
            expect(find.text('Replace quote'), findsOneWidget);
          }
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
