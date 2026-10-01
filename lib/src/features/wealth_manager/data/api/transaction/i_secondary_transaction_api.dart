import 'package:private_deals/src/shared/app_exports.dart';

class InvestorSecondaryTransactionApi {
  static Future<BaseModel<List<StartupRoundModel>>> iHomePage() async {
    try {
      var res = await dioConfig.get(AppUrl.iSecondaryMarket, {});
      return BaseModel.fromListJson(res.data,
          (p0) => p0.map((e) => StartupRoundModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on Secondary HomePage", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> primarySellRequest({
    required int portfolioId,
    required int shares,
    required String price,
  }) async {
    try {
      Map<String, dynamic> body = {
        'portfolio_id': portfolioId,
        'shares': shares,
        'price': price,
      };

      var res = await dioConfig.post(AppUrl.iPrimarySellNow, body);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on Sell Request", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> buyRequest({
    required int sellRequestId,
    required int shares,
  }) async {
    try {
      Map<String, dynamic> body = {
        'sell_request_id': sellRequestId,
        'shares': shares,
      };

      var res = await dioConfig.post(AppUrl.iBuyNow, body);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on Buy Request", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<SellRequestModel>>> sellRequestList() async {
    try {
      var res = await dioConfig.get(AppUrl.iSellRequestList, {});
      BaseModel<List<SellRequestModel>> baseModel = BaseModel.fromListJson(
          res.data,
          (p0) => p0.map((e) => SellRequestModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Primary Transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<SecondaryTransactionListModel>>>
      secondaryTransactionList() async {
    try {
      var res = await dioConfig.get(AppUrl.iSecondaryTransaction, {});
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

  static Future<BaseModel<List<SecondaryOpportunitiesModel>>>
      opportunitiesList() async {
    try {
      var res = await dioConfig.get(AppUrl.iOpportunitiesList, {});
      BaseModel<List<SecondaryOpportunitiesModel>> baseModel =
          BaseModel.fromListJson(
              res.data,
              (p0) => p0
                  .map((e) => SecondaryOpportunitiesModel.fromJson(e))
                  .toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Primary Transaction List", error: e, stackTrace: t);
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
      var res = await dioConfig.post(AppUrl.iOpportunitiesStatus, body);
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
              ? AppUrl.iPaymentReceiptUpload
              : AppUrl.iShareReceiptUpload,
          body,
          false);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  // static Future<BaseModel> shareReceipt(
  //     {required int transactionId, required MediaModel receipt}) async {
  //   try {
  //     Map<String, dynamic> body = {'transaction_id': transactionId};
  //     if (receipt.dataType == FileDataType.filePath &&
  //         receipt.path.isNotEmpty) {
  //       body.addAll(await addFileImage(receipt.path, receipt.name, "receipt"));
  //     }
  //     var res = await dioConfig.post(AppUrl.iShareReceiptUpload, body, false);
  //     BaseModel baseModel = BaseModel.fromMessage(res.data);
  //     return baseModel;
  //   } catch (e, t) {
  //     logger.e("Error on transaction", error: e, stackTrace: t);
  //     return BaseModel.fromError(e.toString());
  //   }
  // }

  static Future<BaseModel> shareReceiptApprove({
    required int transactionId,
    required int shareReceiptId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'transaction_id': transactionId,
        'share_receipt_id': shareReceiptId,
      };
      var res = await dioConfig.post(AppUrl.iShareReceiptApprove, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
