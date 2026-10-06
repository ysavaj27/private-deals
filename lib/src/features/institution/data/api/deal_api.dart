import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/support/extensions/num_extensions.dart';

import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

class DealApi {
  static Future<BaseModel<List<DealModel>>> getDealList({
    String search = '',
    CompanyType type = CompanyType.all,
    int companyId = 0,
    required int skip,
    required bool isHotDeal,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "skip": skip,
        "take": 20,
        "type": type.value,
        "is_hot_deal": isHotDeal ? 1 : 0,
      };
      body.addAllIf(search.isNotEmpty, {"search": search});
      body.addAllIf(companyId.isNotEmpty, {"company_id": companyId});

      final res = await dioConfig.get(InstitutionEndpoints.dealList, body);

      return BaseModel.fromListJson(
        res.data,
        // This endpoint returns only the authenticated Institution's deals.
        (data) =>
            data.map((e) => DealModel.fromJson(e)..isMine = true).toList(),
      );
    } catch (e, t) {
      logger.e("Error on Company List", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<DealModel>> createDeal(
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await dioConfig.post(
        InstitutionEndpoints.createDeal,
        payload,
      );
      return BaseModel<DealModel>.fromJson(
        res.data,
        (data) => DealModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Error on Create Deal API', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<DealModel>> deleteDeal(String uuid) async {
    try {
      final res = await dioConfig.post(InstitutionEndpoints.deleteDeal, {
        "uuid": uuid,
      });
      return BaseModel<DealModel>.fromMessage(res.data);
    } catch (e, t) {
      logger.e('Error on Delete Deal API', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> updateDeal(Map<String, dynamic> payload) async {
    try {
      final res = await dioConfig.post(
        InstitutionEndpoints.updateDeal,
        payload,
      );
      return BaseModel.fromMessage(res.data);
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> bulkDeals(Map<String, dynamic> payload) async {
    try {
      final res = await dioConfig.post(InstitutionEndpoints.bulkDeals, payload);
      return BaseModel.fromMessage(res.data);
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }
}
