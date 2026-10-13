import 'package:private_deals/src/shared/app_exports.dart';

class WSecondaryTransactionApi {
  static Future<BaseModel<List<SecondaryTransactionListModel>>>
      secondaryTransactionList() async {
    try {
      var res = await dioConfig.get(AppUrl.wSecondaryTransaction, {});
      BaseModel<List<SecondaryTransactionListModel>> baseModel =
          BaseModel.fromListJson(
              res.data,
              (p0) => p0
                  .map((e) => SecondaryTransactionListModel.fromJson(e))
                  .toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Secondary Transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> opportunitiesStatus({
    required int itemId,
    required int status,
  }) async {
    try {
      Map<String, dynamic> body = {
        'item_id': itemId,
        'status': status,
      };
      var res = await dioConfig.post(AppUrl.wOpportunitiesStatus, body);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on opportunities Status", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> receiptUpload(
      {required int transactionId,
      required MediaModel receipt,
      required int status}) async {
    try {
      Map<String, dynamic> body = {'transaction_id': transactionId};
      body.addAll(await dioConfig.createMedia(receipt, "receipt"));
      var res = await dioConfig.post(
          status == 2
              ? AppUrl.wPaymentReceiptUpload
              : AppUrl.wShareReceiptUpload,
          body,
          false);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> shareReceiptApprove({
    required int transactionId,
    required int shareReceiptId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'transaction_id': transactionId,
        'share_receipt_id': shareReceiptId,
      };
      var res = await dioConfig.post(AppUrl.wShareReceiptApprove, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
