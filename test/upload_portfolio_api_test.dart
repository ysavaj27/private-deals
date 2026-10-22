import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/core/config/app_key.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'session_and_api_test.dart' show FakeAdapter, identity, response;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final originalAdapter = dioConfig.dio.httpClientAdapter;
  late FakeAdapter adapter;

  setUp(() async {
    Get.testMode = true;
    app.persist = false;
    app.userType = UserType.distributor;
    await app.clear();
    await app.setUser(prefUser: identity('Wealth Manager'));
    adapter = FakeAdapter(
      (_) async => response({'status': 1, 'message': 'Holding added.'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;
  });

  tearDown(() async {
    app.userType = UserType.distributor;
    dioConfig.dio.httpClientAdapter = originalAdapter;
    await app.clear();
    Get.reset();
  });

  Future<BaseModel<void>> upload({
    int investorId = 12,
    int? companyId = 31,
    String otherName = 'Summit Consumer Brands',
    int shares = 1000,
    double sharePrice = 125.5,
    String date = '24-01-2025',
  }) => PortfolioApi.wAddPortfolioApi(
    investorId: investorId,
    companyId: companyId,
    otherName: otherName,
    shares: shares,
    sharePrice: sharePrice,
    date: date,
  );

  test('known company upload posts only the v2 company fields', () async {
    final result = await upload();

    expect(result.isSuccess, isTrue);
    expect(result.m, 'Holding added.');
    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, AppUrl.wAddPortfolio);
    expect(request.path, 'v2/business/portfolio/upload');
    expect(request.data, {
      'investor_id': 12,
      'type': 'company',
      'company_id': 31,
      'shares': 1000,
      'share_price': 125.5,
      'date': '24-01-2025',
    });
    expect(request.headers['content-type'], 'application/json');
    expect(request.headers[AppKey.appKeys], AppKey.appKeyValue);
    expect(request.headers['Authorization'], 'Bearer test-token-7');
  });

  test('custom company omits company id and an empty date', () async {
    final result = await upload(
      companyId: null,
      otherName: '  Another Private Business  ',
      date: '   ',
    );

    expect(result.isSuccess, isTrue);
    expect(adapter.requests.single.data, {
      'investor_id': 12,
      'type': 'company',
      'other_name': 'Another Private Business',
      'shares': 1000,
      'share_price': 125.5,
    });
  });

  test(
    'invalid holdings and investor sessions never call the endpoint',
    () async {
      expect((await upload(shares: 0)).m, 'Enter at least 1 share');
      expect(
        (await upload(sharePrice: 0.009)).m,
        'Enter a price of at least 0.01',
      );
      expect((await upload(sharePrice: 0.01)).isSuccess, isTrue);
      expect(
        (await upload(companyId: 0, otherName: '  ')).m,
        'Enter a company name',
      );
      expect(
        (await upload(date: '2025-01-24')).m,
        'Enter the date as DD-MM-YYYY',
      );
      expect((await upload(investorId: 0)).m, 'Select an investor');

      app.userType = UserType.investor;
      expect(
        (await upload()).m,
        'Portfolio upload is only available in the partner portal.',
      );
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.data['type'], 'company');
    },
  );

  test('a failed upload returns the API message', () async {
    adapter = FakeAdapter(
      (_) async =>
          response({'status': 0, 'message': 'Investor is not eligible'}),
    );
    dioConfig.dio.httpClientAdapter = adapter;

    final result = await upload();

    expect(result.isSuccess, isFalse);
    expect(result.m, 'Investor is not eligible');
  });

  test('an institution session cannot upload a portfolio', () async {
    await app.setUser(prefUser: identity());

    final result = await upload();

    expect(result.isSuccess, isFalse);
    expect(adapter.requests, isEmpty);
  });

  test('upload messages prefer the API text and explain an empty success', () {
    expect(
      portfolioUploadMessage(
        success: true,
        apiMessage: ' Holding added. ',
        knownCompany: true,
      ),
      'Holding added.',
    );
    expect(
      portfolioUploadMessage(
        success: false,
        apiMessage: 'Investor is not eligible',
        knownCompany: false,
      ),
      'Investor is not eligible',
    );
    expect(
      portfolioUploadMessage(success: true, apiMessage: '', knownCompany: true),
      'This holding is available in the portfolio.',
    );
    expect(
      portfolioUploadMessage(
        success: true,
        apiMessage: ' ',
        knownCompany: false,
      ),
      'This holding may take up to 48 hours to appear in the portfolio.',
    );
    expect(
      portfolioUploadMessage(
        success: false,
        apiMessage: '',
        knownCompany: true,
      ),
      'Unable to add this holding.',
    );
  });

  test(
    'success clears the form and failure keeps the entered holding',
    () async {
      final controller = UploadPortfolioCtrl();
      addTearDown(controller.onDelete);
      controller.selectedInvestor(InvestorModel.fromJson({'id': 12}));
      controller.selectedCompany(
        CompanyStartup.fromJson({
          'id': 31,
          'brand_name': 'Summit Consumer Brands',
        }),
      );
      controller.qtyCTRL.text = '1000';
      controller.sharePriceCTRL.text = '125.50';
      controller.purchaseDateCTRL.text = '24-01-2025';
      controller.companyCTRL.text = 'Summit Consumer Brands';

      await controller.addData();

      expect(controller.qtyCTRL.text, isEmpty);
      expect(adapter.requests.single.data['company_id'], 31);
      expect(adapter.requests.single.data.containsKey('other_name'), isFalse);

      adapter = FakeAdapter(
        (_) async =>
            response({'status': 0, 'message': 'Investor is not eligible'}),
      );
      dioConfig.dio.httpClientAdapter = adapter;
      controller.selectedInvestor(InvestorModel.fromJson({'id': 12}));
      controller.selectedCompany(CompanyStartup.fromJson({}));
      controller.companyCTRL.text = 'Another Private Business';
      controller.qtyCTRL.text = '4';
      controller.sharePriceCTRL.text = '10';

      await controller.addData();

      expect(controller.companyCTRL.text, 'Another Private Business');
      expect(controller.qtyCTRL.text, '4');
      expect(adapter.requests.single.data, {
        'investor_id': 12,
        'type': 'company',
        'other_name': 'Another Private Business',
        'shares': 4,
        'share_price': 10.0,
      });
    },
  );
}
