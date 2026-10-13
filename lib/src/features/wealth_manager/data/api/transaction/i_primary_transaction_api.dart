import 'package:private_deals/src/shared/app_exports.dart';

class InvestorPrimaryTransactionApi {
  static Future<BaseModel<PrimaryTransactionModel>> wealthManagerTransaction({
    required int startupId,
    required int roundId,
    required int investorId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'investor_id': investorId,
        'startup_id': startupId,
        "round_id": roundId,
      };
      var res = await dioConfig.get(AppUrl.wTransaction, body);
      BaseModel<PrimaryTransactionModel> baseModel = BaseModel.fromJson(
        res.data,
        (p0) => PrimaryTransactionModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PrimaryTransactionModel>> wealthManagerInvestment({
    required int investorId,
    required int startupId,
    required int roundId,
    required String instrument,
    required double shares,
    required double sharesPrice,
    required double investedAmount,
    required String paymentMode,
    required double fees,
    required double gst,
    required PrimaryInvestmentType type,
  }) async {
    final kycError = await WInvestorsApi.transactionKycError([investorId]);
    if (kycError != null) return BaseModel.fromError(kycError);
    try {
      Map<String, dynamic> body = {
        "investor_id": investorId,
        "startup_id": startupId,
        "round_id": roundId,
        "instrument": instrument, // equity,ccps,ccd
        "shares": shares,
        "share_price": sharesPrice,
        "investment_amount": investedAmount,
        "payment_mode": paymentMode, // Cheque,RTGS,Mandate
        "type": type.name,
        "fees": fees,
        "gst": gst,
      };

      var res = await dioConfig.post(AppUrl.wPrimaryInvestment, body);
      BaseModel<PrimaryTransactionModel> baseModel = BaseModel.fromJson(
        res.data,
        (p0) => PrimaryTransactionModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Wealth Manager Investment", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> paymentReceipt({
    required int transactionId,
    required MediaModel receipt,
  }) async {
    try {
      Map<String, dynamic> body = {'transaction_id': transactionId};
      body.addAll(await dioConfig.createMedia(receipt, "receipt"));
      var res = await dioConfig.post(AppUrl.iUploadPaymentReceipt, body, false);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on transaction", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
