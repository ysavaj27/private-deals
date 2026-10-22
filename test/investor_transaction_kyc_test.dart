import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:private_deals/src/features/investors/presentation/investor_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide FormData;
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/select_investor_dialog.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/investors/presentation/investor_kyc_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/transaction/w_pre_ipo_transaction_api.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

const details = {
  'dp_id': 'IN300000',
  'client_id': '12345678',
  'pan_no': 'ABCDE1234F',
  'name': 'Updated Investor',
  'account_number': '000123456789',
  'ifsc_code': 'HDFC0000001',
};

class _CmlPicker extends FilePickerPlatform {
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    expect(type, FileType.custom);
    expect(allowedExtensions, ['pdf']);
    return _CmlPdf();
  }
}

final class _CmlPdf extends PlatformFile {
  final _bytes = Uint8List.fromList('%PDF-1.7 test CML'.codeUnits);

  @override
  String get name => 'test-cml.pdf';
  @override
  Uri get uri => Uri.parse('blob:https://example.test/test-cml.pdf');
  @override
  get xFile => throw UnimplementedError();
  @override
  int? lengthSync() => _bytes.length;
  @override
  Future<int?> length() async => _bytes.length;
  @override
  Future<Uint8List> readAsBytes() async => _bytes;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}

Future<void> uploadCml(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Upload CML PDF'));
  await tester.tap(find.text('Upload CML PDF'));
  await tester.pumpAndSettle();
  expect(find.text('test-cml.pdf'), findsOneWidget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FilePickerPlatform originalPicker;
  late HttpClientAdapter originalAdapter;
  setUp(() async {
    originalPicker = FilePickerPlatform.instance;
    originalAdapter = dioConfig.dio.httpClientAdapter;
    FilePickerPlatform.instance = _CmlPicker();
    Get.testMode = true;
    app.persist = false;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
  });
  tearDown(() async {
    FilePickerPlatform.instance = originalPicker;
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  for (final status in [0, 2, null]) {
    test('buy and inquiry approval reject incomplete KYC ($status)', () async {
      final adapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [
            {'id': 1, 'name': 'Ready', 'preipo_kyc_status': 1},
            {
              'id': 2,
              'name': 'Pending',
              'preipo_kyc_status': status,
              'kyc_status': 1,
            },
          ],
        }),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      final buy = await WPreIpoTransactionApi.buy(
        list: [
          SelectInvestorModel(investorId: 1),
          SelectInvestorModel(investorId: 2),
        ],
        dealId: 5,
      );
      final accept = await EnquiryApi.accept(uuid: 'inquiry', investorId: 2);
      expect(buy.isSuccess, isFalse);
      expect(accept.isSuccess, isFalse);
      expect(buy.m, contains('Complete KYC for Pending'));
      expect(
        adapter.requests.where((request) => request.method == 'POST'),
        isEmpty,
      );
    });
  }

  test(
    'failed lookup, missing investor and empty orders fail closed',
    () async {
      for (final body in [
        {'status': 0, 'message': 'Unavailable'},
        {'status': 1, 'data': <dynamic>[]},
      ]) {
        final adapter = FakeAdapter((_) async => response(body));
        dioConfig.dio.httpClientAdapter = adapter;
        expect(await WInvestorsApi.transactionKycError([1]), isNotNull);
        expect(await WInvestorsApi.transactionKycError([]), isNotNull);
        expect(await WInvestorsApi.transactionKycError([0]), isNotNull);
        expect(
          adapter.requests.where((request) => request.method == 'POST'),
          isEmpty,
        );
      }
    },
  );

  test('KYC is checked again after it is revoked', () async {
    var complete = true;
    final adapter = FakeAdapter(
      (request) async => response({
        'status': 1,
        'data': request.method == 'GET'
            ? [
                {'id': 1, 'preipo_kyc_status': complete ? 1 : 0},
              ]
            : <dynamic>[],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    final investors = [
      SelectInvestorModel(investorId: 1, quantity: 10, price: 100),
    ];
    expect(
      (await WPreIpoTransactionApi.buy(list: investors, dealId: 5)).isSuccess,
      isTrue,
    );
    complete = false;
    expect(
      (await WPreIpoTransactionApi.buy(list: investors, dealId: 5)).isSuccess,
      isFalse,
    );
    expect(
      adapter.requests.where((request) => request.method == 'POST'),
      hasLength(1),
    );
  });

  for (final width in [320.0, 390.0, 1280.0]) {
    testWidgets(
      'picker disables pending investors and refreshes shared KYC dialog at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var complete = false;
        final adapter = FakeAdapter((request) async {
          if (request.path.endsWith('/read')) {
            return response({
              'status': 1,
              'data': {...details, 'account_holder_name': details['name']},
            });
          }
          if (request.path.endsWith('/save')) {
            complete = true;
            return response({'status': 1});
          }
          return response({
            'status': 1,
            'data': [
              {
                'id': 2,
                'name': complete ? 'Updated Investor' : 'Pending Investor',
                'is_preipo_access': 1,
                'preipo_kyc_status': complete ? 1 : 0,
              },
              {
                'id': 3,
                'name': 'Ready Investor',
                'is_preipo_access': 1,
                'preipo_kyc_status': 1,
              },
            ],
          });
        });
        dioConfig.dio.httpClientAdapter = adapter;
        await tester.pumpWidget(
          const GetMaterialApp(
            home: Scaffold(
              body: Center(
                child: SelectInvestorDialog(selectedInvestorIds: [2, 3]),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var rows = tester
            .widgetList<InvestorSelectionCard>(
              find.byType(InvestorSelectionCard),
            )
            .toList();
        expect(rows[0].onSelect, isNull);
        expect(rows[0].selected, isFalse);
        expect(rows[1].selected, isTrue);
        await tester.ensureVisible(find.text('Complete KYC'));
        await tester.tap(find.text('Complete KYC'));
        await tester.pumpAndSettle();
        expect(find.byType(InvestorKycDialog), findsOneWidget);
        await uploadCml(tester);
        expect(complete, isFalse);
        for (final field in details.entries) {
          await tester.enterText(
            find.byKey(ValueKey('kyc_${field.key}')),
            field.value,
          );
        }
        await tester.tap(find.text('Save KYC'));
        await tester.pumpAndSettle();
        expect(find.byType(InvestorKycDialog), findsNothing);
        final saved = adapter.requests.singleWhere(
          (request) => request.path.endsWith('/save'),
        );
        expect((saved.data as FormData).files.single.key, 'cml_file');
        expect(find.text('Updated Investor'), findsOneWidget);
        rows = tester
            .widgetList<InvestorSelectionCard>(
              find.byType(InvestorSelectionCard),
            )
            .toList();
        expect(rows[0].onSelect, isNotNull);
        expect(rows[0].selected, isFalse);
        expect(rows[1].selected, isTrue);
        expect(find.text('Complete KYC'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('save without server approval keeps investor disabled', (
    tester,
  ) async {
    final adapter = FakeAdapter(
      (request) async => response({
        'status': 1,
        if (request.path.endsWith('/read'))
          'data': {...details, 'account_holder_name': details['name']},
        if (request.method == 'GET')
          'data': [
            {
              'id': 2,
              'name': 'Pending',
              'is_preipo_access': 1,
              'preipo_kyc_status': 0,
            },
          ],
      }),
    );
    dioConfig.dio.httpClientAdapter = adapter;
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: Center(child: SelectInvestorDialog())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Complete KYC'));
    await tester.tap(find.text('Complete KYC'));
    await tester.pumpAndSettle();
    await uploadCml(tester);
    for (final field in details.entries) {
      await tester.enterText(
        find.byKey(ValueKey('kyc_${field.key}')),
        field.value,
      );
    }
    await tester.tap(find.text('Save KYC'));
    await tester.pumpAndSettle();
    expect(find.byType(InvestorKycDialog), findsNothing);
    expect(
      adapter.requests.where((request) => request.path.endsWith('/save')),
      hasLength(1),
    );
    expect(
      adapter.requests.where((request) => request.method == 'GET'),
      hasLength(2),
    );
    expect(
      tester
          .widget<InvestorSelectionCard>(find.byType(InvestorSelectionCard))
          .onSelect,
      isNull,
    );
    expect(find.text('Complete KYC'), findsOneWidget);
  });

  for (final sell in [false, true]) {
    testWidgets('inquiry $sell blocks approval and opens common KYC dialog', (
      tester,
    ) async {
      dioConfig.dio.httpClientAdapter = FakeAdapter(
        (_) async => response({
          'status': 1,
          'data': [
            {'id': 2, 'name': 'Pending', 'preipo_kyc_status': 0},
          ],
        }),
      );
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: EnquiryDecisionDialog(
              action: 'accept',
              institution: false,
              companyName: 'Company',
              sell: sell,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.text('Complete KYC'));
      await tester.tap(find.text('Complete KYC'));
      await tester.pumpAndSettle();
      expect(find.byType(InvestorKycDialog), findsOneWidget);
      await tester.tap(find.byTooltip('Close KYC'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Approve'))
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
