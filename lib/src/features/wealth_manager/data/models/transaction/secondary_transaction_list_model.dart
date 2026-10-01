import 'package:private_deals/src/features/wealth_manager/data/models/transaction/sell_request_model.dart';
import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/transaction/secondary_transaction_model.dart';

class SecondaryTransactionListModel {
  String type;
  SellRequestModel sell;
  SecondaryTransactionModel buy;
  DateTime createdAt;

  SecondaryTransactionListModel({
    this.type = '',
    required this.sell,
    required this.buy,
    required this.createdAt,
  });

  bool get isSelling => type == 'sell';

  bool get isBuying => type == 'buy';

  factory SecondaryTransactionListModel.fromJson(Map<String, dynamic> json) {
    return SecondaryTransactionListModel(
      type: Parse.toStrings(json["type"]),
      sell: SellRequestModel.fromJson(json["sell"] ?? {}),
      buy: SecondaryTransactionModel.fromJson(json["buy"] ?? {}),
      createdAt: Parse.toDateTime(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "sell": sell.toJson(),
      "buy": buy.toJson(),
      "created_at": createdAt.toIso8601String(),
    };
  }
}
