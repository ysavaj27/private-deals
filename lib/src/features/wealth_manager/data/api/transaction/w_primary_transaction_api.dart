import 'package:private_deals/src/shared/app_exports.dart';

class WPrimaryTransactionApi {
  static Future<BaseModel<List<PrimaryTransactionModel>>> transactionList(
      {bool pendingDocSign = false, bool pendingPayment = false}) async {
    try {
      Map<String, dynamic> body = {};
      body.addIf(pendingDocSign, "pending_doc_sign", pendingDocSign);
      body.addIf(pendingPayment, "pending_payment", pendingPayment);
      var res = await dioConfig.get(AppUrl.wTransactions, body);
      BaseModel<List<PrimaryTransactionModel>> baseModel =
          BaseModel.fromListJson(
              res.data,
              (p0) =>
                  p0.map((e) => PrimaryTransactionModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Primary Transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
