import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:private_deals/src/app/routing/pages.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/presentation/investor_kyc_dialog.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investor_list_card.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'session_and_api_test.dart' show FakeAdapter, identity, response;

final _pdf = CmlDocument(
  'client.pdf',
  Uint8List.fromList('%PDF-1.4\n test'.codeUnits),
);
const _details = {
  'dp_id': 'IN300000',
  'client_id': '12345678',
  'pan_no': 'ABCDE1234F',
  'name': 'Parsed Investor',
  'account_number': '000123456789',
  'ifsc_code': 'HDFC0000001',
};

void main() {
  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
  });
  tearDown(() async {
    await app.clear();
    Get.reset();
  });

  test('legacy investor APIs and Institution KYC remain blocked', () async {
    final adapter = FakeAdapter((_) async => response({'status': 1}));
    dioConfig.dio.httpClientAdapter = adapter;
    await expectLater(
      dioConfig.post('v1/investor/kyc/save', {}),
      throwsA(isA<DioException>()),
    );
    await app.setUser(prefUser: identity('Institution'));
    expect((await CmlApi.read(88, _pdf)).isSuccess, isFalse);
    expect(
      (await CmlApi.save(InvestorModel(id: 88), _details, null)).isSuccess,
      isFalse,
    );
    expect(adapter.requests, isEmpty);
  });

  test('standalone investor and CML routes are removed', () {
    expect(
      Pages.pages.where((page) => page.name.startsWith('/investors')),
      isEmpty,
    );
  });

  test(
    'read and save send multipart PDFs with partner headers and exact fields',
    () async {
      final adapter = FakeAdapter(
        (request) async => response({
          'status': 1,
          if (request.path.endsWith('/read'))
            'data': {'account_holder_name': 'Parsed Investor'},
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final investor = InvestorModel.fromJson({'id': 70, 'is_self': 1});
      expect((await CmlApi.read(investor.id, _pdf)).isSuccess, isTrue);
      expect((await CmlApi.save(investor, _details, _pdf)).isSuccess, isTrue);
      expect(adapter.requests.map((r) => r.uri.path), [
        '/api/v2/business/investor/kyc/cml/read',
        '/api/v2/business/investor/kyc/cml/save',
      ]);
      for (final request in adapter.requests) {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer test-token-7');
        expect(request.headers['headtoken'], isNotEmpty);
        expect(request.data, isA<FormData>());
      }
      final read = adapter.requests.first.data as FormData;
      expect(Map.fromEntries(read.fields), {'investor_id': '70'});
      expect(read.files.single.key, 'cml');
      final save = adapter.requests.last.data as FormData;
      expect(Map.fromEntries(save.fields), {'investor_id': '70', ..._details});
      expect(save.files.single.key, 'cml_file');
      expect(save.files.single.value.filename, 'client.pdf');
      expect(save.files.single.value.contentType.toString(), 'application/pdf');
      expect(save.files.single.value.length, _pdf.bytes.length);
      // Only refreshed server data determines completion.
      expect(investor.isPreIpoKycComplete, isFalse);
    },
  );

  test(
    'bank account and IFSC are required before sending; manual save permits no PDF',
    () async {
      final adapter = FakeAdapter((_) async => response({'status': 1}));
      dioConfig.dio.httpClientAdapter = adapter;
      final investor = InvestorModel(id: 88);
      for (final field in ['account_number', 'ifsc_code']) {
        final fields = {..._details, field: '   '};
        expect((await CmlApi.save(investor, fields, null)).isSuccess, isFalse);
      }
      expect(adapter.requests, isEmpty);
      expect((await CmlApi.save(investor, _details, null)).isSuccess, isTrue);
      expect((adapter.requests.single.data as FormData).files, isEmpty);
    },
  );

  test(
    'business failure preserves pending status even with HTTP 200',
    () async {
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async =>
            response({'status': 0, 'message': 'Sent for manual verification'}),
      );
      final investor = InvestorModel(id: 88);
      final read = await CmlApi.read(investor.id, _pdf);
      expect(read.isSuccess, isFalse);
      expect(read.m, 'Sent for manual verification');
      expect((await CmlApi.save(investor, _details, _pdf)).isSuccess, isFalse);
      expect(investor.isPreIpoKycComplete, isFalse);
    },
  );

  test(
    'list filter uses preipo status and preserves search after refreshing',
    () async {
      var refreshed = false;
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [
            {
              'id': 88,
              'name': refreshed ? 'Changed name' : 'Alice',
              'preipo_kyc_status': 1,
              'kyc_status': 0,
            },
            {'id': 89, 'name': 'Bob', 'preipo_kyc_status': 0, 'kyc_status': 1},
          ],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final controller = InvestorsPageCtrl();
      controller.pendingKYC(FilterTypeEnum.Yes);
      await controller.getInvestorList();
      expect(controller.finalList.single.id, 88);
      expect(adapter.requests.last.queryParameters['is_kyc'], 'All');
      controller.search('Alice');
      refreshed = true;
      await controller.getInvestorList();
      expect(controller.finalList, isEmpty);
      controller.search('');
      controller.pendingKYC(FilterTypeEnum.No);
      await controller.getInvestorList();
      expect(controller.finalList.single.id, 89);
      controller.controller.dispose();
    },
  );

  for (final width in [390.0, 1280.0]) {
    testWidgets('PDF read, review and save in responsive dialog at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final investor = InvestorModel(id: 88, name: 'Original Investor');
      final adapter = FakeAdapter(
        (request) async => response({
          'status': 1,
          if (request.path.endsWith('/read'))
            'data': {
              ..._details,
              'account_holder_name': 'Name From PDF',
              'bank_name': null,
              'dob': '',
            },
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      bool? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  saved = await showDialog<bool>(
                    context: context,
                    builder: (_) => InvestorKycDialog(
                      investor: investor,
                      pickDocument: () async => _pdf,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload CML PDF'));
      await tester.pumpAndSettle();
      final name = tester.widget<TextFormField>(
        find.byKey(const ValueKey('kyc_name')),
      );
      expect(name.controller!.text, 'Name From PDF');
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('kyc_account_number')),
            )
            .controller!
            .text,
        '000123456789',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('kyc_bank_name')))
            .controller!
            .text,
        '',
      );
      expect(investor.isPreIpoKycComplete, isFalse);
      await tester.tap(find.text('Save KYC'));
      await tester.pumpAndSettle();
      expect(saved, isTrue);
      expect(find.byType(InvestorKycDialog), findsNothing);
      final fields = Map.fromEntries(
        (adapter.requests.last.data as FormData).fields,
      );
      expect(fields['name'], 'Name From PDF');
      expect(fields['account_number'], '000123456789');
      expect(fields.containsKey('dob'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('failed save keeps entered details and dialog open', (
    tester,
  ) async {
    dioConfig.dio.httpClientAdapter = FakeAdapter(
      (_) async => response({'status': 0, 'message': 'Investor not found'}),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InvestorKycDialog(investor: InvestorModel(id: 88)),
        ),
      ),
    );
    for (final field in _details.entries) {
      await tester.enterText(
        find.byKey(ValueKey('kyc_${field.key}')),
        field.value,
      );
    }
    await tester.tap(find.text('Save KYC'));
    await tester.pumpAndSettle();
    expect(find.text('Investor not found'), findsOneWidget);
    expect(find.byType(InvestorKycDialog), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('kyc_account_number')),
          )
          .controller!
          .text,
      '000123456789',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('KYC badge and action use preipo status rather than legacy KYC', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              InvestorListCard(
                investor: InvestorModel.fromJson({
                  'name': 'Complete',
                  'preipo_kyc_status': '1',
                  'kyc_status': 0,
                }),
                onOpenKyc: () {},
              ),
              InvestorListCard(
                investor: InvestorModel.fromJson({
                  'name': 'Pending',
                  'preipo_kyc_status': 0,
                  'kyc_status': 1,
                }),
                onOpenKyc: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('KYC complete'), findsOneWidget);
    expect(find.text('KYC pending'), findsOneWidget);
    expect(find.text('CML'), findsNothing);
    final buttons = tester
        .widgetList<TextButton>(find.byType(TextButton))
        .toList();
    expect(buttons[0].onPressed, isNull);
    expect(buttons[1].onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
