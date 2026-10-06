import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'seller slots preserve seller identity and default null numbers to zero',
    () {
      final json = <String, dynamic>{
        'date': '2026-09-13',
        'sell_price': 2074,
        'buy_price': null,
        'min_qty': 10,
        'total_qty': null,
        'seller': {
          'id': 18,
          'uuid': '72e4584f-a58a-4bbc-89cb-a07ae35db05d',
          'company_name': 'Test/Person Account',
          'logo': 'https://ui-avatars.com/api/?name=Test',
        },
      };
      final company = CompanyModel.fromJson({
        'seller_share_prices': [json],
      });
      final slot = company.sellerSharePrices.single;
      expect(slot.sellPrice, 2074);
      expect(slot.minQty, 10);
      expect(slot.buyPrice, 0.0);
      expect(slot.totalQty, 0);
      expect(slot.seller.id, 18);
      expect(slot.seller.companyName, 'Test/Person Account');
      final normalized = {
        ...json,
        'buy_price': 0.0,
        'total_qty': 0,
        'seller': {
          ...json['seller'] as Map<String, dynamic>,
          'profile': {
            'years_of_experience': '',
            'total_trades_executed': '',
            'total_investor_base': '',
            'verified_status': '',
            'companies_previously_listed': '',
            'geographic_presence': '',
            'approach': '',
          },
        },
      };
      expect(slot.toJson(), normalized);
      expect(company.toJson()['seller_share_prices'], [normalized]);
      expect(slot.seller.profile.isEmpty, isTrue);
    },
  );

  test('older company responses default to an empty seller list', () {
    expect(CompanyModel.fromJson({}).sellerSharePrices, isEmpty);
    expect(
      CompanyModel.fromJson({'seller_share_prices': null}).sellerSharePrices,
      isEmpty,
    );
  });
}
