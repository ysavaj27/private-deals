import 'package:private_deals/src/shared/app_exports.dart';

class InvestorSecondaryTransactionApi {
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
}
