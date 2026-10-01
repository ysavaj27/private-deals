import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class LastRoundModel {
  int id;
  int startupId;
  String name;
  String roundType;
  String roundStatus;
  double sharePrice;
  String instrument;

  LastRoundModel({
    this.id = 0,
    this.startupId = 0,
    this.name = '',
    this.roundType = '',
    this.roundStatus = '',
    this.sharePrice = 0.0,
    this.instrument = '',
  });

  factory LastRoundModel.fromJson(Map<String, dynamic> json) => LastRoundModel(
        id: Parse.toInt(json["id"]),
        startupId: Parse.toInt(json["startup_id"]),
        name: Parse.toStrings(json["name"]),
        roundType: Parse.toStrings(json["round_type"]),
        roundStatus: Parse.toStrings(json["round_status"]),
        sharePrice: Parse.toDouble(json["share_price"]),
        instrument: Parse.toStrings(
            json["instrument"], app.config.enumValues.instrumentType.equity),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "startup_id": startupId,
        "name": name,
        "round_type": roundType,
        "round_status": roundStatus,
        "share_price": sharePrice,
        "instrument": instrument,
      };
}
