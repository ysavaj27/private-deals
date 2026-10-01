import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/institution/data/deal_payloads.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/features/institution/companies/presentation/create_company/create_company_page_ctrl.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';

void main() {
  test('Institution endpoint versions and deal paths match handoff', () {
    expect(
      InstitutionEndpoints.createDeal,
      'v2/business/institution/company/deals',
    );
    expect(InstitutionEndpoints.dealList, InstitutionEndpoints.createDeal);
    expect(
      InstitutionEndpoints.bulkDeals,
      'v2/business/institution/company/deals/bulk',
    );
  });
  test('Company financial inputs exclude server-managed fees', () {
    final fields = [
      ...CreateCompanyCtrl.financialFields,
      ...CreateCompanyCtrl.additionalFields,
    ].map((e) => e.key);
    expect(fields.contains('commission'), false);
    expect(fields.contains('processing_fee_percentage'), false);
    expect(CreateCompanyCtrl().validateLogo(), true);
  });
  test('Institution direct links preserve company and deal type', () {
    expect(
      CompanyRouteContext.fromPath(
        '/institution/companies/secondary/create',
      ).type,
      CompanyType.secondary,
    );
    expect(
      DealRouteContext.fromPath('/institution/deals/unlisted/create').type,
      CompanyType.unlisted,
    );
    expect(
      () => CompanyRouteContext.fromPath('/wealth-manager/dashboard'),
      throwsStateError,
    );
    expect(
      () => DealRouteContext.fromPath('/institution/deals/invalid'),
      throwsStateError,
    );
  });
  test('Returned base and final prices stay separate', () {
    final deal = DealModel.fromJson({
      'base_price': 100,
      'share_price': 101,
      'company': {},
    });
    expect(deal.basePrice, 100);
    expect(deal.sharePrice, 101);
    final update = DealPayloads.update(
      uuid: 'owned',
      finalPrice: '105',
      minimumQuantity: '1',
    );
    expect(update['share_price'], 105);
    expect(update.containsKey('base_price'), false);
    expect(update.containsKey('company_id'), false);
  });
  test(
    'Bulk creates exact buy/sell contracts and skips blank or zero rows',
    () {
      final data = DealPayloads.bulk([
        const BulkDealRow(
          companyId: 12,
          type: 'sell',
          price: '20',
          minimum: '1000',
        ),
        const BulkDealRow(
          companyId: 12,
          type: 'buy',
          price: '18',
          minimum: '500',
          total: '1000',
        ),
        const BulkDealRow(type: 'buy', price: '0', minimum: '0'),
        const BulkDealRow(type: 'sell', price: '', minimum: ''),
      ]);
      expect(data, {
        'sell': [
          {
            'company_id': 12,
            'sell_price': 20,
            'min_qty': 1000,
            'total_qty': null,
          },
        ],
        'buy': [
          {
            'company_id': 12,
            'buy_price': 18,
            'min_qty': 500,
            'total_qty': 1000,
          },
        ],
      });
    },
  );
  test('A single invalid priced row rejects the whole bulk payload', () {
    expect(
      () => DealPayloads.bulk([
        const BulkDealRow(
          companyId: 12,
          type: 'sell',
          price: '20',
          minimum: '1',
        ),
        const BulkDealRow(
          companyId: 12,
          type: 'buy',
          price: '10',
          minimum: '0',
        ),
      ]),
      throwsFormatException,
    );
    expect(() => DealPayloads.bulk([]), throwsFormatException);
    expect(() => DealPayloads.price('NaN'), throwsFormatException);
    expect(() => DealPayloads.price('Infinity'), throwsFormatException);
  });
  test('CML validates actual PDF content and the 10 MB limit', () {
    CmlDocument(
      'client.PDF',
      Uint8List.fromList('%PDF-1.7'.codeUnits),
    ).validate();
    expect(
      () => CmlDocument(
        'client.doc',
        Uint8List.fromList('%PDF-1.7'.codeUnits),
      ).validate(),
      throwsFormatException,
    );
    expect(
      () => CmlDocument(
        'client.pdf',
        Uint8List.fromList('not a pdf'.codeUnits),
      ).validate(),
      throwsFormatException,
    );
    final huge = Uint8List(10 * 1024 * 1024 + 1)
      ..setRange(0, 5, '%PDF-'.codeUnits);
    expect(
      () => CmlDocument('client.pdf', huge).validate(),
      throwsFormatException,
    );
  });
}
