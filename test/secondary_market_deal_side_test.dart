import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/models/enums.dart';

Map<String, dynamic> _deal(String type) => {
      'id': type == 'buy' ? 2 : 1,
      'uuid': 'deal-$type',
      'share_price': 100,
      'minimum_qty': 10,
      'available_quantity': 500,
      'status': 'available',
      'deal_type': type,
      'is_hot_deal': false,
    };

void main() {
  test('secondary inquiry type follows counterparty perspective', () {
    final sellCtrl = SecondaryTransactionDialogCtrl(
      DealModel.fromJson(_deal('sell')),
    );
    expect(sellCtrl.inquiryType, InvestmentTypeEnum.buy);
    expect(sellCtrl.actionLabel, 'Buy');

    final buyCtrl = SecondaryTransactionDialogCtrl(
      DealModel.fromJson(_deal('buy')),
    );
    expect(buyCtrl.inquiryType, InvestmentTypeEnum.sell);
    expect(buyCtrl.actionLabel, 'Sell');
  });
}
