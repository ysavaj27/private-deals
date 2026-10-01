import 'package:private_deals/src/shared/functions/parse.dart';

class MasterTypeModel {
  int id;
  int countryId;
  int stateId;
  String name;
  // DateTime createdAt;
  // DateTime updatedAt;

  MasterTypeModel({
    this.id = 0,
    this.countryId = 0,
    this.stateId = 0,
    this.name = '',
    // required this.createdAt,
    // required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MasterTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory MasterTypeModel.fromJson(Map<String, dynamic> json) =>
      MasterTypeModel(
        id: Parse.toInt(json["id"]),
        countryId: Parse.toInt(json["country_id"]),
        stateId: Parse.toInt(json["state_id"]),
        name: Parse.toStrings(json["name"]),
        // createdAt: Parse.toDateTime(json["created_at"]),
        // updatedAt: Parse.toDateTime(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "country_id": countryId,
        "state_id": stateId,
        "name": name,
        // "created_at": createdAt.toIso8601String(),
        // "updated_at": updatedAt.toIso8601String(),
      };
}


class CityStateCountryModel {
  MasterTypeModel city;
  MasterTypeModel state;
  MasterTypeModel country;

  CityStateCountryModel({
    required this.city,
    required this.state,
    required this.country,
  });

  factory CityStateCountryModel.fromJson(Map<String, dynamic> json) => CityStateCountryModel(
    city: MasterTypeModel.fromJson(json["city"]),
    state: MasterTypeModel.fromJson(json["state"]),
    country: MasterTypeModel.fromJson(json["country"]),
  );

  Map<String, dynamic> toJson() => {
    "city": city.toJson(),
    "state": state.toJson(),
    "country": country.toJson(),
  };
}
