import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

/// Preferred endpoint for every partner type. Institution `/institution/profile`
/// remains a backend alias; the app always calls this path.
abstract final class AdditionalProfileEndpoints {
  static const profile = 'v2/business/additional-profile';
}

class AdditionalProfileApi {
  static Future<BaseModel<PartnerPublicProfile>> getProfile() async {
    try {
      final res = await dioConfig.get(AdditionalProfileEndpoints.profile, {});
      return BaseModel<PartnerPublicProfile>.fromJson(
        res.data,
        (data) => PartnerPublicProfile.fromJson(data),
      );
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PartnerPublicProfile>> saveProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await dioConfig.post(
        AdditionalProfileEndpoints.profile,
        payload,
      );
      return BaseModel<PartnerPublicProfile>.fromJson(
        res.data,
        (data) => PartnerPublicProfile.fromJson(data),
      );
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }
}
