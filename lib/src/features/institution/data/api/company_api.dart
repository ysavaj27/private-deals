import 'package:get/get.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';

import 'package:private_deals/src/features/institution/support/plugins/logger.dart';

class CompanyApi {
  static Future<BaseModel<List<CompanyModel>>> getCompanyList({
    String search = '',
    bool mySubmissions = false,
    String sectorSlug = '',
    UnListedShareCategoryEnum? category,
    required int skip,
    CompanyType type = CompanyType.unlisted,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "skip": skip,
        "take": 20,
        "type": type.value,
      };
      body.addAllIf(category != null, {"category": category?.apiCategory});
      body.addAllIf(search.isNotEmpty, {"search": search});
      body.addAllIf(sectorSlug.isNotEmpty, {"sector": sectorSlug});

      final res = await dioConfig.get(
        mySubmissions
            ? InstitutionEndpoints.mySubmissions
            : InstitutionEndpoints.companyList,
        body,
      );

      return BaseModel.fromListJson(
        res.data,
        (data) => data.map((e) => CompanyModel.fromJson(e)).toList(),
      );
    } catch (e, t) {
      logger.e("Error on Company List", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<LiteCompanyModel>>> getCompanyListLite({
    String search = '',
    CompanyType? type,
  }) async {
    try {
      final res = await dioConfig.get(InstitutionEndpoints.companyListLite, {
        if (search.isNotEmpty) "search": search,
        if (type != null) "type": type.value,
      });

      return BaseModel.fromListJson(
        res.data,
        (data) => data.map((e) => LiteCompanyModel.fromJson(e)).toList(),
      );
    } catch (e, t) {
      logger.e("Error on Lite Company List", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<SectorModel>>> getSectorList() async {
    try {
      final res = await dioConfig.get(InstitutionEndpoints.sectors, {});

      return BaseModel.fromListJson(
        res.data,
        (data) => data.map((e) => SectorModel.fromJson(e)).toList(),
      );
    } catch (e, t) {
      logger.e("Error on Company List", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyDuplicateModel>> checkDuplicate({
    required String cin,
    required String companyName,
    required String type,
    int? excludeCompanyId,
  }) async {
    try {
      Map<String, dynamic> body = {
        if (cin.isNotEmpty) 'cin': cin,
        if (companyName.isNotEmpty) 'company_name': companyName,
        'type': type,
        if (excludeCompanyId != null && excludeCompanyId > 0)
          'exclude_company_id': excludeCompanyId,
      };
      final res = await dioConfig.post(
        InstitutionEndpoints.checkCompanyDuplicate,
        body,
      );
      return BaseModel.fromJson(
        res.data,
        (p0) => CompanyDuplicateModel.fromJson(p0),
      );
    } catch (e, t) {
      logger.e("Error on Company Duplicate API", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Map<String, dynamic> _sanitizeCompanyPayload(
    Map<String, dynamic> buildPayload,
  ) {
    return Map<String, dynamic>.from(buildPayload)
      ..remove('commission')
      ..remove('processing_fee_percentage')
      ..remove('approval_status')
      ..remove('status')
      ..remove('is_editable')
      ..remove('fifty_two_week_high')
      ..remove('fifty_two_week_low');
  }

  static Future<BaseModel<CompanyModel>> createCompany(
    Map<String, dynamic> buildPayload, {
    MediaModel? logo,
  }) async {
    try {
      buildPayload = _sanitizeCompanyPayload(buildPayload);
      final bytes = logo?.uint8list;
      if (bytes != null && bytes.isNotEmpty) {
        buildPayload.addAll(
          await dioConfig.createBytesImage(
            image: bytes,
            imageName: logo!.name,
            key: 'logo',
          ),
        );
      }
      var res = await dioConfig.post(
        InstitutionEndpoints.createCompany,
        buildPayload,
        false,
      );

      return BaseModel.fromJson(res.data, (p0) => CompanyModel.fromJson(p0));
    } catch (e, t) {
      logger.e("Error on Create Company API", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyModel>> updateCompany(
    Map<String, dynamic> buildPayload, {
    MediaModel? logo,
  }) async {
    try {
      buildPayload = _sanitizeCompanyPayload(buildPayload)
        ..remove('category');
      final bytes = logo?.uint8list;
      if (bytes != null && bytes.isNotEmpty) {
        buildPayload.addAll(
          await dioConfig.createBytesImage(
            image: bytes,
            imageName: logo!.name,
            key: 'logo',
          ),
        );
      }
      final res = await dioConfig.post(
        InstitutionEndpoints.updateCompany,
        buildPayload,
        false,
      );

      return BaseModel.fromJson(res.data, (p0) => CompanyModel.fromJson(p0));
    } catch (e, t) {
      logger.e("Error on Update Company API", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> savePromoters({
    required int companyId,
    required List<Map<String, dynamic>> promoters,
  }) async {
    try {
      var body = {'company_id': companyId, 'promoters': promoters};

      var res = await dioConfig.post(InstitutionEndpoints.addPromoters, body);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on Create Company API", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> saveShareholders({
    required int companyId,
    required List<Map<String, dynamic>> shareholders,
  }) async {
    try {
      final res = await dioConfig.post(InstitutionEndpoints.addShareHolders, {
        'company_id': companyId,
        'shareholders': shareholders,
      });
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e('Error saving shareholders', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyModel>> getCompanyDetail({
    required String slug,
  }) async {
    try {
      var body = {'slug': slug};

      final res = await dioConfig.get(InstitutionEndpoints.companyDetail, body);

      return BaseModel.fromJson(res.data, (p0) => CompanyModel.fromJson(p0));
    } catch (e, t) {
      logger.e("Error on Create Company API", error: e, stackTrace: t);

      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<CompanyEventModel>>> getCompanyEvents({
    required int companyId,
  }) async {
    try {
      final res = await dioConfig.get(InstitutionEndpoints.companyEvents, {
        'company_id': companyId,
      });
      return BaseModel.fromListJson(
        res.data,
        (data) => data.map((e) => CompanyEventModel.fromJson(e)).toList(),
      );
    } catch (e, t) {
      logger.e('Error on Company Events list', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyEventModel>> createCompanyEvent({
    required int companyId,
    required String date,
    required String title,
    required String description,
    MediaModel? file,
  }) async {
    try {
      final body = <String, dynamic>{
        'company_id': companyId,
        'date': date,
        'title': title,
        'description': description,
      };
      final bytes = file?.uint8list;
      if (bytes != null && bytes.isNotEmpty) {
        body.addAll(
          await dioConfig.createBytesImage(
            image: bytes,
            imageName: file!.name,
            key: 'file',
          ),
        );
      }
      final res = await dioConfig.post(
        InstitutionEndpoints.companyEvents,
        body,
        false,
      );
      return BaseModel.fromJson(
        res.data,
        (p0) => CompanyEventModel.fromJson(p0),
      );
    } catch (e, t) {
      logger.e('Error creating company event', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyEventModel>> updateCompanyEvent({
    required int id,
    required String date,
    required String title,
    required String description,
    MediaModel? file,
  }) async {
    try {
      final body = <String, dynamic>{
        'id': id,
        'date': date,
        'title': title,
        'description': description,
      };
      final bytes = file?.uint8list;
      if (bytes != null && bytes.isNotEmpty) {
        body.addAll(
          await dioConfig.createBytesImage(
            image: bytes,
            imageName: file!.name,
            key: 'file',
          ),
        );
      }
      final res = await dioConfig.post(
        InstitutionEndpoints.updateCompanyEvent,
        body,
        false,
      );
      return BaseModel.fromJson(
        res.data,
        (p0) => CompanyEventModel.fromJson(p0),
      );
    } catch (e, t) {
      logger.e('Error updating company event', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> deleteCompanyEvent({required int id}) async {
    try {
      final res = await dioConfig.post(InstitutionEndpoints.deleteCompanyEvent, {
        'id': id,
      });
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e('Error deleting company event', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
