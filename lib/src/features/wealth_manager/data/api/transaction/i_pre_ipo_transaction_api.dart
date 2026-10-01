import 'package:private_deals/src/shared/app_exports.dart';

class IPreIpoTransactionApi {
  static Future<BaseModel<List<PreIPOTransactionModel>>>
      transactionList() async {
    try {
      var res = await dioConfig.get(AppUrl.iPreIpoTransaction, {});
      return BaseModel.fromListJson(res.data,
          (p0) => p0.map((e) => PreIPOTransactionModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PreIpoSellTransactionModel>>>
      sellTransactionList() async {
    try {
      var res = await dioConfig.get(AppUrl.iPreIpoSellTransaction, {});
      return BaseModel.fromListJson(
          res.data,
          (p0) =>
              p0.map((e) => PreIpoSellTransactionModel.fromJson(e)).toList());
    } catch (e, t) {
      logger.e("Error on transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> preIPOSellRequest({
    required int portfolioId,
    required int shares,
    required String price,
    required MediaModel doc,
  }) async {
    try {
      Map<String, dynamic> body = {
        'portfolio_id': portfolioId,
        'shares': shares,
        'price': price,
      };
      body.addAll(await dioConfig.createMedia(doc, "cmr"));
      var res = await dioConfig.post(AppUrl.iPreIPOSellNow, body, false);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on Sell Request", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> buy(
    int companyId,
    int shares,
    String paymentMode,
    double sharePrice,
    double distributorPrice,
  ) async {
    var body = {
      "company_id": [companyId],
      "shares": [shares],
      "payment_mode": [paymentMode],
      "investor_id": [app.userId],
      "share_price": [sharePrice],
      "distributer_price": [distributorPrice],
      "is_distributer": [false],
    };
    try {
      var res = await dioConfig.post(AppUrl.iPreIpoBuy, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on buy", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
