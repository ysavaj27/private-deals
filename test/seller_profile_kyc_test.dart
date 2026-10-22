import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page_ctrl.dart';
import 'package:private_deals/src/shared/models/config_model.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    app.configModel(ConfigModel.fromJson({}));
  });

  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('pending self investor opens Complete KYC at $width', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        width: width,
        user: identity(),
        investors: [
          {'id': 70, 'name': 'Seller', 'is_self': 1, 'preipo_kyc_status': 0},
        ],
      );
      expect(find.text('KYC pending'), findsOneWidget);
      await tester.ensureVisible(find.text('Complete KYC'));
      await tester.tap(find.text('Complete KYC'));
      await tester.pumpAndSettle();
      expect(find.text('Investor KYC'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('completed self investor stays closed at $width', (
      tester,
    ) async {
      await _pumpProfile(
        tester,
        width: width,
        user: identity(),
        investors: [
          {'id': 70, 'name': 'Seller', 'is_self': 1, 'preipo_kyc_status': 1},
        ],
      );
      expect(find.text('KYC complete'), findsOneWidget);
      expect(find.text('Complete KYC'), findsNothing);
      expect(find.text('Investor KYC'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('missing self investor explains that KYC cannot start', (
    tester,
  ) async {
    final user = identity()..remove('self_investor_id');
    await _pumpProfile(tester, width: 1280, user: user, investors: const []);
    expect(
      find.text(SellerProfilePageCtrl.selfInvestorMissingMessage),
      findsOneWidget,
    );
    expect(find.text('Complete KYC'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  required double width,
  required Map<String, dynamic> user,
  required List<Map<String, dynamic>> investors,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await app.setUser(prefUser: user);
  dioConfig.dio.httpClientAdapter = FakeAdapter((request) async {
    if (request.path == 'v2/business/investor') {
      return response({'status': 1, 'data': investors});
    }
    if (request.path == 'v2/business/profile') {
      return response({'status': 1, 'data': user});
    }
    return response({'status': 1, 'data': {}});
  });
  await tester.pumpWidget(const GetMaterialApp(home: ProfilePageView()));
  await tester.pumpAndSettle();
}
