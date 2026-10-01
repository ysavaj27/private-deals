import 'package:private_deals/src/shared/app_exports.dart';

class WPreIpoTransactionApi {
  static Future<BaseModel<List<PreIPOTransactionModel>>>
      transactionList() async {
    try {
      var res = await dioConfig.get(AppUrl.wNewPreIpoTransaction, {});
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
      var res = await dioConfig.get(AppUrl.wPreIpoSellTransaction, {});
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
      var res = await dioConfig.post(AppUrl.wPreIPOSellNow, body, false);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on Sell Request", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> buy({
    required List<SelectInvestorModel> list,
    required int companyId,
    required double distributorPrice,
    int sellerId = 0,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (sellerId.isNotEmpty) {
        body["seller_id"] = List.generate(list.length, (_) => sellerId);
      }
      body.addAll({"company_id": List.generate(list.length, (i) => companyId)});
      body.addAll({"investor_id": list.map((e) => e.investorId).toList()});
      body.addAll({"shares": list.map((e) => e.quantity()).toList()});
      body.addAll({"share_price": list.map((e) => e.price()).toList()});
      body.addAll({
        "distributer_price": List.generate(list.length, (i) => distributorPrice)
      });
      body.addAll({"is_distributer": List.generate(list.length, (i) => true)});
      body.addAll({
        "payment_mode": List.generate(list.length,
            (i) => app.config.enumValues.primaryTransactionPaymentMode.rtgs)
      });

      var res = await dioConfig.post(AppUrl.wPreIpoBuy, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on buy", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> inquiry({
    required InvestmentTypeEnum type,
    required String companySlug,
    String dealUUID = '',
    String notes = '',
    required int quantity,
    required double offerPrice,
    required DateTime offerValidTill,
  }) async {
    try {
      Map<String, dynamic> body = {
        // "investor_id": app.wUser.id,
        "enquiry_type": type.name,
        "company_slug": companySlug,
        "quantity": quantity,
        "offer_price": offerPrice,
        "offer_valid_till": offerValidTill.serverDate,
      };
      body.addAllIf(dealUUID.isNotEmpty, {"deal_uuid": dealUUID});
      body.addAllIf(notes.isNotEmpty, {"notes": notes});

      var res = await dioConfig.post(AppUrl.wEnquiry, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on buy", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
