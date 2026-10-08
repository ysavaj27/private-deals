import 'package:private_deals/src/shared/app_exports.dart';

class WInvestorsApi {
  /// Recheck server-owned KYC immediately before creating a transaction.
  /// Missing investors and failed lookups must never permit an order.
  static Future<String?> transactionKycError(Iterable<int> investorIds) async {
    final ids = investorIds.toSet();
    if (ids.isEmpty || ids.any((id) => id <= 0)) {
      return 'Select an investor with completed KYC.';
    }
    final response = await investorsList(
      isKyc: 'All',
      isActive: 'All',
      isAif: 'All',
    );
    if (!response.isSuccess || response.r == null) {
      return 'Unable to verify investor KYC. Please retry.';
    }
    for (final id in ids) {
      final investor = response.r!.firstWhereOrNull((item) => item.id == id);
      if (investor == null) {
        return 'Unable to verify investor KYC. Please retry.';
      }
      if (!investor.isPreIpoKycComplete) {
        return 'Complete KYC for ${investor.displayName} before making a transaction.';
      }
    }
    return null;
  }

  static Future<BaseModel<List<InvestorModel>>> investorsList({
    required String isKyc,
    required String isActive,
    required String isAif,
    List<PartnerUser> relationManagerList = const [],
  }) async {
    try {
      Map<String, dynamic> body = {
        "is_kyc": isKyc,
        "is_active": isActive,
        "is_aif": isAif,
      };
      if (relationManagerList.isNotEmpty) {
        body.addAll({
          'relation_manager_ids': relationManagerList
              .map((manager) => manager.id.toString())
              .join(','),
        });
      }
      var res = await dioConfig.get(AppUrl.wInvestorList, body);
      BaseModel<List<InvestorModel>> baseModel = BaseModel.fromListJson(
        res.data,
        (p0) => p0.map((e) => InvestorModel.fromJson(e)).toList(),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Investors List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  /// POST `v2/business/investor` create body:
  /// required: investor_type, name, mobile_number
  /// optional: email, gender
  static Future<BaseModel<InvestorModel>> addInvestor({
    required int id,
    required String investorType,
    required String name,
    required String mobileNumber,
    String email = '',
    String gender = '',
  }) async {
    try {
      final Map<String, dynamic> body = {
        "investor_type": investorType,
        "name": name,
        "mobile_number": mobileNumber,
      };
      final trimmedEmail = email.trim();
      if (trimmedEmail.isNotEmpty) {
        body['email'] = trimmedEmail.toLowerCase();
      }
      final trimmedGender = gender.trim();
      if (trimmedGender.isNotEmpty) {
        body['gender'] = trimmedGender;
      }
      if (id != 0) {
        body['investor_id'] = id;
      }
      var response = await dioConfig.post(
        id != 0 ? AppUrl.wUpdateInvestor : AppUrl.wAddInvestor,
        body,
      );
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (p0) => InvestorModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<InvestorModel>> getInvestor({
    required String uuid,
  }) async {
    try {
      Map<String, dynamic> body = {"uuid": uuid};
      var response = await dioConfig.get(AppUrl.wInvestorDetail, body);
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (p0) => InvestorModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
