import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';

void main() {
  final deal = DealModel.fromJson({
    'id': 42,
    'uuid': 'deal-42',
    'share_price': 40,
    'minimum_qty': 300,
    'available_quantity': 20000,
    'status': 'available',
    'deal_type': 'sell',
    'expired_at': null,
    'is_hot_deal': true,
    'seller': {
      'id': 18,
      'uuid': 'seller-18',
      'company_name': 'Test/Person Account',
      'logo': 'https://example.com/logo.png',
    },
  });

  test('deal fields parse and survive copy and serialization', () {
    final copied = DealModel.fromJson(
      deal.copyWith(companySlug: 'oyo').toJson(),
    );
    expect(copied.id, 42);
    expect(copied.seller.toJson(), deal.seller.toJson());
    expect(DealModel.fromJson({}).seller.id, 0);
    expect(DealModel.fromJson({'seller': null}).seller.companyName, '');
    expect(copied.dealType, 'sell');
    expect(copied.isHotDeal, isTrue);
    expect(copied.expiredAt, '');
    expect(copied.companySlug, 'oyo');
    expect(DealModel.fromJson({}).id, 0);
  });

  test('seller perspective sell deals allow investment; buy deals do not', () {
    final offer = PreIPOOffer.fromDeal(deal);
    expect(offer.canBuy, isTrue);
    expect(offer.sellerId, 18);
    expect(offer.name, 'Test/Person Account');
    expect(offer.price, 40);
    expect(offer.minimumQty, 300);
    expect(
      PreIPOOffer.fromDeal(deal.copyWith(dealType: 'buy')).canBuy,
      isFalse,
    );
  });

  test('seller offers use nested seller id and their own minimums', () {
    final offer = PreIPOOffer.fromSeller(
      SellerSharePriceModel.fromJson({
        'sell_price': 19,
        'min_qty': 50000,
        'seller': {'id': 19, 'company_name': 'GSep Investments'},
      }),
    );
    expect(offer.sellerId, 19);
    expect(offer.price, 19);
    expect(offer.minimumQty, 50000);
    expect(offer.isDeal, isFalse);
  });

  test(
    'minimum quantity and price reject invalid input and accept boundaries',
    () {
      final offer = PreIPOOffer.fromDeal(deal);
      for (final value in ['', '299', '1.5', '-1', 'NaN']) {
        expect(offer.validateQuantity(value), isNotNull);
      }
      expect(offer.validateQuantity('300'), isNull);
      expect(offer.validateQuantity('301'), isNull);
      for (final value in ['', '39.99', '-1', 'NaN', 'Infinity']) {
        expect(offer.validatePrice(value), isNotNull);
      }
      expect(offer.validatePrice('40'), isNull);
      expect(offer.validatePrice('40.50'), isNull);
    },
  );

  test('only available deals take priority over seller prices', () {
    final company = CompanyModel.fromJson({});
    company.deals = [deal, deal.copyWith(status: 'sold')];
    expect(availablePreIPODeals(company), [deal]);
    company.deals = [deal.copyWith(status: 'sold')];
    expect(availablePreIPODeals(company), isEmpty);
    expect(
      availablePreIPODeals(CompanyModel.fromJson({'deals': null})),
      isEmpty,
    );
  });
}
