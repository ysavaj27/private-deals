import 'package:private_deals/src/shared/functions/parse.dart';

class MasterTypeModel {
  int id;
  String name;

  MasterTypeModel({
    this.id = 0,
    this.name = '',
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
        name: Parse.toStrings(json["name"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
