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
    expect(offer.dealId, 42);
    expect(offer.sellerId, 18);
    expect(offer.name, 'Test/Person Account');
    expect(offer.price, 40);
    expect(offer.minimumQty, 300);
    expect(
      PreIPOOffer.fromDeal(deal.copyWith(dealType: 'buy')).canBuy,
      isFalse,
    );
  });

  test('empty deal_type is treated as sell when deal id exists', () {
    final offer = PreIPOOffer.fromDeal(deal.copyWith(dealType: ''));
    expect(offer.isSellDeal, isTrue);
    expect(offer.canBuy, isTrue);
    expect(offer.buyBlockedReason, isNull);
  });

  test('company detail deals with uuid + partner are buyable', () {
    final parsed = DealModel.fromJson({
      'uuid': '36340f5d-bd7d-4b34-8f21-f54ad8e7a18f',
      'available_quantity': 20000,
      'share_price': 22.73,
      'base_price': 22.5,
      'minimum_qty': 2000,
      'processing_fee_percentage': 1,
      'status': 'available',
      'deal_type': 'sell',
      'expired_at': null,
      'is_hot_deal': true,
      'seller': null,
      'partner': {
        'id': 102,
        'uuid': 'e0940de7-824d-4e88-a9a3-d5527d0819e9',
        'name': 'SOHAM ROY CHOWDHURY',
        'profile_photo':
            'https://www.privatedeals.in/core/placeholders/male_user.svg',
        'profile': {
          'years_of_experience': '12',
          'total_trades_executed': '340',
          'total_investor_base': '1200',
          'verified_status': 'Verified Seller',
          'companies_previously_listed': 'Oyo, NSE',
          'geographic_presence': 'Mumbai, Delhi',
          'approach':
              'We source unlisted shares and settle in the agreed window.',
        },
      },
    });
    expect(parsed.id, 0);
    expect(parsed.uuid, '36340f5d-bd7d-4b34-8f21-f54ad8e7a18f');
    expect(parsed.seller.id, 102);
    expect(parsed.seller.companyName, 'SOHAM ROY CHOWDHURY');
    expect(parsed.seller.logo.contains('male_user.svg'), isTrue);
    expect(parsed.seller.profile.yearsOfExperience, '12');
    expect(parsed.seller.profile.verifiedStatus, 'Verified Seller');
    expect(parsed.seller.profile.approach.contains('settle'), isTrue);
    final offer = PreIPOOffer.fromDeal(parsed);
    expect(offer.canBuy, isTrue);
    expect(offer.dealUuid, parsed.uuid);
    expect(offer.buyBlockedReason, isNull);
  });

  test('blank partner profile strings stay empty and are not numbers', () {
    final parsed = DealModel.fromJson({
      'uuid': 'deal-blank-profile',
      'status': 'available',
      'deal_type': 'sell',
      'share_price': 10,
      'minimum_qty': 1,
      'seller': null,
      'partner': {
        'id': 9,
        'name': 'Alpha Capital',
        'profile': {
          'years_of_experience': '',
          'total_trades_executed': '  ',
          'total_investor_base': '',
          'verified_status': '',
          'companies_previously_listed': '',
          'geographic_presence': '',
          'approach': '',
        },
      },
    });
    expect(parsed.seller.profile.isEmpty, isTrue);
    expect(parsed.seller.profile.totalTradesExecuted, '');
  });

  test('empty seller map falls back to partner profile', () {
    final parsed = DealModel.fromJson({
      'uuid': 'deal-1',
      'status': 'available',
      'deal_type': 'sell',
      'share_price': 10,
      'minimum_qty': 1,
      'seller': <String, dynamic>{},
      'partner': {
        'id': 55,
        'name': 'Partner Firm',
        'profile_photo': 'https://example.com/partner.png',
      },
    });
    expect(parsed.seller.id, 55);
    expect(parsed.seller.companyName, 'Partner Firm');
    expect(parsed.seller.logo, 'https://example.com/partner.png');
  });

  test('relative seller logo is kept resolvable via resolveLogo', () {
    expect(
      SharePriceSellerModel.resolveLogo('https://cdn.example/a.png'),
      'https://cdn.example/a.png',
    );
    expect(SharePriceSellerModel.resolveLogo(''), '');
  });

  test('deal_id json alias populates DealModel.id', () {
    final parsed = DealModel.fromJson({
      'deal_id': 77,
      'deal_type': 'sell',
      'status': 'available',
      'share_price': 10,
      'minimum_qty': 1,
      'seller': {'id': 1},
    });
    expect(parsed.id, 77);
    expect(PreIPOOffer.fromDeal(parsed).canBuy, isTrue);
  });

  test('seller offers cannot place the new deal-based buy order', () {
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
    expect(offer.dealId, 0);
    expect(offer.canBuy, isFalse);
    expect(offer.buyBlockedReason, isNotNull);
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

  test('nested sell groups are buyable and buy groups offer selling', () {
    Map<String, dynamic> entry(int id) => {
      ...deal.toJson(),
      'id': id,
      'uuid': 'grouped-$id',
      // The grouping supplies these fields in the new response.
      'deal_type': null,
      'is_hot_deal': null,
    };
    final company = CompanyModel.fromJson({
      'deals': {
        'sell': {
          'hot': [entry(1)],
          'normal': [entry(2), entry(3), entry(4)],
        },
        'buy': {
          'hot': [entry(5)],
          'normal': [
            entry(6),
            {...entry(7), 'status': 'sold'},
          ],
        },
      },
    });

    // Serialization and copying must retain the normalized direction and tier.
    final restored = CompanyModel.fromJson(company.toJson());
    final available = availablePreIPODeals(restored);
    final buyable = available.where((d) => PreIPOOffer.fromDeal(d).canBuy);
    final sellable = available.where(
      (d) => !PreIPOOffer.fromDeal(d).isSellDeal,
    );
    expect(buyable.map((d) => d.id), [1, 2, 3, 4]);
    expect(sellable.map((d) => d.id), [5, 6]);
    expect(available.where((d) => d.isHotDeal).map((d) => d.id), [1, 5]);
    expect(buyable.first.seller.id, deal.seller.id);
    expect(PreIPOOffer.fromDeal(buyable.first).dealUuid, 'grouped-1');
    expect(sellable.every((d) => !PreIPOOffer.fromDeal(d).canBuy), isTrue);
  });

  test('empty and partial grouped responses remain valid', () {
    for (final groups in [
      <String, dynamic>{},
      {'sell': null, 'buy': null},
      {'sell': <String, dynamic>{}},
      {
        'buy': {'hot': null, 'normal': []},
      },
    ]) {
      expect(CompanyModel.fromJson({'deals': groups}).deals, isEmpty);
    }
    final company = CompanyModel.fromJson({
      'deals': {
        'buy': {
          'normal': [deal.toJson()],
        },
      },
    });
    expect(company.deals.single.dealType, 'buy');
    expect(company.deals.single.isHotDeal, isFalse);
    expect(PreIPOOffer.fromDeal(company.deals.single).canBuy, isFalse);
  });
}
