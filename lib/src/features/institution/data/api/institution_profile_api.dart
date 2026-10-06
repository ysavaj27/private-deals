import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

class InstitutionProfileApi {
  static Future<BaseModel<PartnerPublicProfile>> getProfile() async {
    try {
      final res = await dioConfig.get(InstitutionEndpoints.profile, {});
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
      final res = await dioConfig.post(InstitutionEndpoints.profile, payload);
      return BaseModel<PartnerPublicProfile>.fromJson(
        res.data,
        (data) => PartnerPublicProfile.fromJson(data),
      );
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }
}
