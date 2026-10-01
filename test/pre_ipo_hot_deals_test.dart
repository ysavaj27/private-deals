import 'package:private_deals/src/shared/app_exports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/pre_ipo_landing_page_ctrl.dart';

void main() {
  test('Hot Deals tab selects companies from the landing response', () {
    final model = PreIPOLandingPageModel.fromJson({
      'hot_deals': [
        {
          'id': 8,
          'slug': 'oyo',
          'brand_name': 'OYO',
          'deals': [
            {
              'seller': {'id': 18},
              'deal_type': 'sell',
              'share_price': 40,
            },
          ],
        },
      ],
      'trending': [
        {'id': 1, 'brand_name': 'NSE'},
      ],
    });
    final controller = PreIPOLandingPageCtrl();
    controller.model(model);
    controller.changeTab(UnListedShareTabEnum.hotDeals);
    expect(controller.currentCompanies.single.slug, 'oyo');
    expect(controller.currentCompanies.single.deals.single.seller.id, 18);
    controller.changeTab(UnListedShareTabEnum.trending);
    expect(controller.currentCompanies.single.id, 1);
    expect(model.copyWith().hotDeals.single.id, 8);
    expect(
      PreIPOLandingPageModel.fromJson(model.toJson()).hotDeals.single.id,
      8,
    );
    expect(
      UnListedShareTabEnumX.fromRoute('hot-deals'),
      UnListedShareTabEnum.hotDeals,
    );
  });

  test('missing and null hot deals default to empty lists', () {
    expect(PreIPOLandingPageModel.fromJson({}).hotDeals, isEmpty);
    expect(
      PreIPOLandingPageModel.fromJson({'hot_deals': null}).hotDeals,
      isEmpty,
    );
  });
}
