import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:private_deals/src/core/analytics/analytics_service.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/data/models/deal/price_excel_review_model.dart';
import 'package:private_deals/src/features/institution/support/extensions/num_extensions.dart';

import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

class DealApi {
  static int _rowCount(Object? rows) => rows is List ? rows.length : 0;

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
  ) => Analytics.trackRequest(
    'deal_create',
    params: {
      'company_id': payload['company_id'],
      'deal_side': payload['deal_type'],
      'is_hot_deal': payload['is_hot_deal'],
    },
    request: () async {
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
    },
  );

  static Future<BaseModel<DealModel>> deleteDeal(String uuid) =>
      Analytics.trackRequest(
        'deal_delete',
        request: () async {
          try {
            final res = await dioConfig.post(InstitutionEndpoints.deleteDeal, {
              "uuid": uuid,
            });
            return BaseModel<DealModel>.fromMessage(res.data);
          } catch (e, t) {
            logger.e('Error on Delete Deal API', error: e, stackTrace: t);
            return BaseModel.fromError(e.toString());
          }
        },
      );

  static Future<BaseModel> updateDeal(Map<String, dynamic> payload) =>
      Analytics.trackRequest(
        'deal_update',
        params: {
          'deal_side': payload['deal_type'],
          'is_hot_deal': payload['is_hot_deal'],
        },
        request: () async {
          try {
            final res = await dioConfig.post(
              InstitutionEndpoints.updateDeal,
              payload,
            );
            return BaseModel.fromMessage(res.data);
          } catch (e) {
            return BaseModel.fromError(e.toString());
          }
        },
      );

  static Future<BaseModel> bulkDeals(Map<String, dynamic> payload) =>
      Analytics.trackRequest(
        'share_price_update',
        params: {
          'deal_side': _rowCount(payload['buy']) > 0
              ? (_rowCount(payload['sell']) > 0 ? 'both' : 'buy')
              : 'sell',
          'company_count':
              _rowCount(payload['buy']) + _rowCount(payload['sell']),
        },
        request: () async {
          try {
            final res = await dioConfig.post(
              InstitutionEndpoints.bulkDeals,
              payload,
            );
            return BaseModel.fromMessage(res.data);
          } catch (e) {
            return BaseModel.fromError(e.toString());
          }
        },
      );

  /// Downloads the Institution price workbook (xlsx bytes).
  /// Failure responses are JSON with `status` 0 even when using bytes mode.
  static Future<BaseModel<Uint8List>> downloadPriceExcel({
    CompanyType type = CompanyType.unlisted,
  }) => Analytics.trackRequest(
    'price_excel_download',
    params: {'company_type': type.name},
    request: () async {
      try {
        final res = await dioConfig.getBytes(
          InstitutionEndpoints.companyPricesExcel,
          {'type': type.value},
        );

        final raw = res.data;
        if (raw == null) {
          return BaseModel.fromError('Download failed. Try again.');
        }

        final bytes = raw is Uint8List
            ? raw
            : Uint8List.fromList(List<int>.from(raw as List));

        final contentType = (res.headers.value('content-type') ?? '')
            .toLowerCase();
        final looksLikeJson =
            contentType.contains('json') ||
            (bytes.isNotEmpty && bytes.first == 0x7B);

        if (looksLikeJson) {
          try {
            final decoded = jsonDecode(utf8.decode(bytes));
            if (decoded is Map<String, dynamic>) {
              final message = decoded['message']?.toString() ?? '';
              return BaseModel.fromError(
                message.isNotEmpty ? message : 'Download failed. Try again.',
              );
            }
          } catch (_) {
            return BaseModel.fromError('Download failed. Try again.');
          }
        }

        if (bytes.isEmpty) {
          return BaseModel.fromError('Download failed. Try again.');
        }

        return BaseModel(s: 1, m: '', r: bytes);
      } catch (e, t) {
        logger.e('Error downloading price excel', error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  /// Review (`confirm: false`) or save (`confirm: true`) an edited price sheet.
  /// Parses `data` even when `status` is 0 so review errors can be shown.
  static Future<BaseModel<PriceExcelReview>> uploadPriceExcel({
    required MediaModel file,
    required bool confirm,
  }) => Analytics.trackRequest(
    confirm ? 'price_excel_save' : 'price_excel_review',
    request: () async {
      try {
        final bytes = file.uint8list;
        if (bytes == null || bytes.isEmpty) {
          return BaseModel.fromError('Choose an .xlsx file to continue.');
        }

        final body = <String, dynamic>{
          'confirm': confirm ? '1' : '0',
          ...await dioConfig.createBytesImage(
            image: bytes,
            imageName: file.name.isNotEmpty
                ? file.name
                : 'institution-prices.xlsx',
            key: 'file',
          ),
        };

        final res = await dioConfig.post(
          InstitutionEndpoints.companyPricesExcel,
          body,
          false,
        );

        final json = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : <String, dynamic>{};

        final status = json['status'] ?? 0;
        final message = json['message']?.toString() ?? '';
        PriceExcelReview? review;
        final data = json['data'];
        if (data is Map<String, dynamic>) {
          review = PriceExcelReview.fromJson(data);
        } else if (data is Map) {
          review = PriceExcelReview.fromJson(Map<String, dynamic>.from(data));
        }

        return BaseModel<PriceExcelReview>(
          s: status is int ? status : int.tryParse(status.toString()) ?? 0,
          m: message,
          r: review,
        );
      } catch (e, t) {
        logger.e('Error uploading price excel', error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );
}
