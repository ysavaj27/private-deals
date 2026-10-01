import 'package:private_deals/src/shared/functions/parse.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/mis/mis_list_model.dart';

class WMisModel {
  final int startupId;
  final String startupName;
  final String startupLogo;
  final List<MisListModel> misList;

  WMisModel({
    this.startupId = 0,
    this.startupName = '',
    this.startupLogo = '',
    this.misList = const [],
  });

  factory WMisModel.fromJson(Map<String, dynamic> json) {
    return WMisModel(
      startupId: Parse.toInt(json['startup_id']),
      startupName: Parse.toStrings(json['startup_name']),
      startupLogo: Parse.parseUrl(json['logo']),
      misList: (json['approved_mis'] as List<dynamic>?)
              ?.map((item) => MisListModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startup_id': startupId,
      'startup_name': startupName,
      'logo': startupLogo,
      'approved_mis': misList.map((mis) => mis.toJson()).toList(),
    };
  }
}
