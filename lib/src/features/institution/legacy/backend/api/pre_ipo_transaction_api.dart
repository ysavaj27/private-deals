import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/shared/models/media_model.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';

class PreIPOTransactionApi {
  static Future<BaseModel<List<PreIpoOrderModel>>> getTransactions() async {
    try {
      final res = await dioConfig.get(
        InstitutionEndpoints.preIpoTransaction,
        {},
      );
      return BaseModel.fromListJson(
        res.data,
        (data) => data
            .map((e) => PreIpoOrderModel.fromJson(Map<String, dynamic>.from(e)))
            .where(
              (order) =>
                  order.isNewFlow && order.orderStep != 'mandate_pending',
            )
            .toList(),
      );
    } catch (e, t) {
      logger.e('Unable to load unlisted transactions', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> detail({
    required int transactionId,
  }) async {
    try {
      final res = await dioConfig.get(
        InstitutionEndpoints.preIpoTransactionDetail,
        {'transaction_id': transactionId},
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Unable to load transaction detail', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> approve({
    required int transactionId,
  }) async {
    try {
      final res = await dioConfig.post(
        InstitutionEndpoints.preIpoTransactionApprove,
        {'transaction_id': transactionId},
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Unable to approve transaction', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> reject({
    required int transactionId,
    required String reason,
  }) async {
    try {
      final res = await dioConfig.post(
        InstitutionEndpoints.preIpoTransactionReject,
        {'transaction_id': transactionId, 'reason': reason},
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Unable to reject transaction', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> confirmPayment({
    required int transactionId,
  }) async {
    try {
      final res = await dioConfig.post(
        InstitutionEndpoints.preIpoConfirmPayment,
        {'transaction_id': transactionId},
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Unable to confirm payment', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> uploadShareTransferReceipt({
    required int transactionId,
    required MediaModel file,
  }) async {
    try {
      Map<String, dynamic> body = {'transaction_id': transactionId};
      body.addAll(await dioConfig.createMedia(file, 'file'));
      final res = await dioConfig.post(
        InstitutionEndpoints.preIpoShareTransferReceipt,
        body,
        false,
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e(
        'Unable to upload share-transfer receipt',
        error: e,
        stackTrace: t,
      );
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> uploadPaymentReceipt({
    required int transactionId,
    required MediaModel file,
  }) async {
    try {
      Map<String, dynamic> body = {'transaction_id': transactionId};
      body.addAll(await dioConfig.createMedia(file, 'file'));
      final res = await dioConfig.post(
        InstitutionEndpoints.preIpoPaymentReceipt,
        body,
        false,
      );
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e('Unable to upload payment receipt', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
