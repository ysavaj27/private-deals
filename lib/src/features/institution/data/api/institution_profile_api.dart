import 'package:private_deals/src/features/account/data/additional_profile_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

/// Delegates to [AdditionalProfileApi] (preferred `additional-profile` path).
class InstitutionProfileApi {
  static Future<BaseModel<PartnerPublicProfile>> getProfile() =>
      AdditionalProfileApi.getProfile();

  static Future<BaseModel<PartnerPublicProfile>> saveProfile(
    Map<String, dynamic> payload,
  ) => AdditionalProfileApi.saveProfile(payload);
}
