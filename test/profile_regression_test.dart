import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' show FormData, ResponseBody;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/session/partner_user.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/shared/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart'
    as seller;
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart'
    as seller_image;
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page_ctrl.dart';
import 'package:private_deals/src/features/institution/legacy/features/auth/profile/profile_page.dart';
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    app.config.s3Baseurl = 'https://images.example.com/storage/';
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  for (final parse in [Parse.parseUrl, seller.Parse.parseUrl]) {
    test('image URLs survive normalization and model round trips', () {
      const full =
          'https://images.example.com/storage/avatar.png?signature=abc';
      expect(parse(full), full);
      expect(parse(parse(full)), full);
      expect(
        parse(' /avatar.png '),
        'https://images.example.com/storage/avatar.png',
      );
      expect(parse(null), '');
      expect(parse('  '), '');
      expect(
        parse('//cdn.example.com/avatar.png'),
        'https://cdn.example.com/avatar.png',
      );
      final user = PartnerUser.fromJson({...identity(), 'profile_photo': full});
      expect(PartnerUser.fromJson(user.toJson()).profile, full);
    });
  }

  test(
    'seller profile uses v2 business profile photo and institution text APIs',
    () async {
      await app.setUser(prefUser: identity());
      final adapter = FakeAdapter((request) async {
        if (request.path.contains('/seller/')) return response({}, 401);
        if (request.path.contains('/institution/profile')) {
          return response({
            'status': 1,
            'message': 'Profile',
            'data': {
              'years_of_experience': '12',
              'total_trades_executed': '340',
              'total_investor_base': '1200',
              'verified_status': 'Verified Seller',
              'companies_previously_listed': 'Oyo, NSE',
              'geographic_presence': 'Mumbai, Delhi',
              'approach': 'We source unlisted shares.',
            },
          });
        }
        return response({
          'status': 1,
          'data': {
            ...identity(),
            'name': 'Institution name',
            'profile_photo':
                'https://images.example.com/storage/avatar.png?sig=1',
          },
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      final controller = SellerProfilePageCtrl();
      expect(await controller.refreshProfile(), isTrue);
      expect(await controller.refreshPublicProfile(), isTrue);
      expect(
        adapter.requests.map((r) => r.uri.path),
        containsAll([
          '/api/v2/business/profile',
          '/api/v2/business/institution/profile',
        ]),
      );
      expect(app.token, 'test-token-7');
      expect(app.isUserLogin, isTrue);
      expect(controller.profile.value.companyName, 'Institution name');
      expect(
        controller.profile.value.logo,
        'https://images.example.com/storage/avatar.png?sig=1',
      );
      expect(controller.publicProfile.value.yearsOfExperience, '12');
      expect(controller.publicProfile.value.verifiedStatus, 'Verified Seller');
      controller.edit();
      expect(controller.editing.value, isTrue);
      // No logo selected yet — save must not hit the update endpoint.
      await controller.save();
      expect(adapter.requests.where((r) => r.method == 'POST').isEmpty, isTrue);
      controller.cancel();
      expect(controller.editing.value, isFalse);
    },
  );

  test('profile photo update posts only logo form field on v2', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter((request) async {
      if (request.path.contains('/institution/profile')) {
        return response({
          'status': 1,
          'message': 'Profile',
          'data': {
            'years_of_experience': '',
            'total_trades_executed': '',
            'total_investor_base': '',
            'verified_status': '',
            'companies_previously_listed': '',
            'geographic_presence': '',
            'approach': '',
          },
        });
      }
      if (request.method == 'POST' &&
          request.path.endsWith('/business/profile')) {
        return response({
          'status': 1,
          'message': 'Profile photo updated',
          'data': {
            ...identity(),
            'name': 'Institution name',
            'profile_photo': 'https://cdn.example.com/new-logo.png',
          },
        });
      }
      return response({
        'status': 1,
        'data': {
          ...identity(),
          'name': 'Institution name',
          'profile_photo': 'https://cdn.example.com/old-logo.png',
        },
      });
    });
    dioConfig.dio.httpClientAdapter = adapter;
    final controller = SellerProfilePageCtrl();
    await controller.refreshProfile();
    controller.edit();
    controller.logo.value = MediaModel(
      name: 'logo.png',
      dataType: FileDataType.bytes,
      uint8list: Uint8List.fromList([1, 2, 3, 4]),
    );
    await controller.save();
    expect(controller.editing.value, isFalse);
    expect(
      controller.profile.value.logo,
      'https://cdn.example.com/new-logo.png',
    );
    final post = adapter.requests.lastWhere(
      (r) => r.method == 'POST' && r.uri.path == '/api/v2/business/profile',
    );
    expect(post.data, isA<FormData>());
    final form = post.data as FormData;
    expect(form.files.single.key, 'logo');
    expect(app.wUser.profilePhoto, 'https://cdn.example.com/new-logo.png');
  });

  test('institution public profile save posts all seven fields', () async {
    await app.setUser(prefUser: identity());
    final adapter = FakeAdapter((request) async {
      if (request.path.contains('/institution/profile') &&
          request.method == 'POST') {
        return response({
          'status': 1,
          'message': 'Profile saved',
          'data': {
            'years_of_experience': '10',
            'total_trades_executed': '',
            'total_investor_base': '',
            'verified_status': '',
            'companies_previously_listed': '',
            'geographic_presence': '',
            'approach': '',
          },
        });
      }
      if (request.path.contains('/institution/profile')) {
        return response({
          'status': 1,
          'message': 'Profile',
          'data': {
            'years_of_experience': '',
            'total_trades_executed': '',
            'total_investor_base': '',
            'verified_status': '',
            'companies_previously_listed': '',
            'geographic_presence': '',
            'approach': '',
          },
        });
      }
      return response({
        'status': 1,
        'data': {...identity(), 'name': 'Institution name'},
      });
    });
    dioConfig.dio.httpClientAdapter = adapter;
    final controller = SellerProfilePageCtrl();
    await controller.refreshPublicProfile();
    controller.editPublicProfile();
    controller.yearsOfExperienceCtrl.text = ' 10 ';
    await controller.savePublicProfile();
    expect(controller.publicEditing.value, isFalse);
    expect(controller.publicProfile.value.yearsOfExperience, '10');
    final post = adapter.requests.lastWhere(
      (r) => r.method == 'POST' && r.uri.path.contains('/institution/profile'),
    );
    expect(post.data, {
      'years_of_experience': '10',
      'total_trades_executed': '',
      'total_investor_base': '',
      'verified_status': '',
      'companies_previously_listed': '',
      'geographic_presence': '',
      'approach': '',
    });
  });

  for (final width in [390.0, 1280.0]) {
    testWidgets('opening seller profile keeps login at $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await app.setUser(prefUser: {...identity(), 'name': 'Test institution'});
      final adapter = FakeAdapter((request) async {
        if (request.path.contains('/seller/')) return response({}, 401);
        if (request.path.contains('/institution/profile')) {
          return response({
            'status': 1,
            'message': 'Profile',
            'data': {
              'years_of_experience': '',
              'total_trades_executed': '',
              'total_investor_base': '',
              'verified_status': '',
              'companies_previously_listed': '',
              'geographic_presence': '',
              'approach': '',
            },
          });
        }
        return response({
          'status': 1,
          'data': {...identity(), 'name': 'Test institution'},
        });
      });
      dioConfig.dio.httpClientAdapter = adapter;
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: ProfilePageView())),
      );
      await tester.pumpAndSettle();
      expect(app.isUserLogin, isTrue);
      expect(app.token, 'test-token-7');
      expect(
        adapter.requests.map((r) => r.uri.path),
        containsAll([
          '/api/v2/business/profile',
          '/api/v2/business/institution/profile',
        ]),
      );
      expect(find.text('Test institution'), findsWidgets);
      if (width >= 1280) {
        expect(find.text('Seller profile'), findsOneWidget);
      } else {
        await tester.tap(find.text('View profile'));
        await tester.pumpAndSettle();
        expect(find.text('Seller profile'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  test('late seller profile cannot replace a newer session profile', () async {
    await app.setUser(prefUser: identity());
    final pending = Completer<ResponseBody>();
    final requested = Completer<void>();
    dioConfig.dio.httpClientAdapter = FakeAdapter((request) {
      if (request.path.contains('/institution/profile')) {
        return Future.value(
          response({
            'status': 1,
            'message': 'Profile',
            'data': {
              'years_of_experience': '',
              'total_trades_executed': '',
              'total_investor_base': '',
              'verified_status': '',
              'companies_previously_listed': '',
              'geographic_presence': '',
              'approach': '',
            },
          }),
        );
      }
      if (!requested.isCompleted) requested.complete();
      return pending.future;
    });
    final controller = SellerProfilePageCtrl();
    final refresh = controller.refreshProfile();
    await requested.future;
    await app.setUser(prefUser: identity('Institution', 8));
    pending.complete(response({'status': 1, 'data': identity()}));
    expect(await refresh, isFalse);
    expect(app.userId, 8);
    expect(app.token, 'test-token-8');
  });

  testWidgets('empty photo URLs immediately show a fallback on both sides', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            CacheImage(url: ''),
            seller_image.CacheImage(url: ' '),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_outline), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
