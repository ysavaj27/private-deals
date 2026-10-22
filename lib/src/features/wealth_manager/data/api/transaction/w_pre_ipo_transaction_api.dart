import 'package:private_deals/src/shared/app_exports.dart';

class WPreIpoTransactionApi {
  static Future<BaseModel<List<PreIpoOrderModel>>> transactionList({
    int skip = 0,
    int take = 15,
  }) async {
    try {
      var res = await dioConfig.get(AppUrl.wNewPreIpoTransaction, {
        'skip': skip,
        'take': take,
      });
      return BaseModel.fromListJson(
        res.data,
        (p0) => p0
            .map((e) => PreIpoOrderModel.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.isNewFlow)
            .toList(),
      );
    } catch (e, t) {
      logger.e("Error on transaction List", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> detail({
    required int transactionId,
  }) async {
    try {
      var res = await dioConfig.get(AppUrl.wPreIpoTransactionDetail, {
        'transaction_id': transactionId,
      });
      return BaseModel.fromJson(
        res.data,
        (data) => PreIpoOrderModel.fromJson(data),
      );
    } catch (e, t) {
      logger.e("Error on transaction detail", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> preIPOSellRequest({
    required int portfolioId,
    required int shares,
    required String price,
    required MediaModel doc,
  }) => Analytics.trackRequest(
    'pre_ipo_sell_request',
    request: () async {
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
    },
  );

  /// Place Pre-IPO buy orders via v2 JSON body.
  /// Company detail returns deals with [uuid] (and sometimes numeric id).
  static Future<BaseModel<List<PreIpoOrderModel>>> buy({
    required List<SelectInvestorModel> list,
    int dealId = 0,
    String dealUuid = '',
    int? companyId,
  }) => Analytics.trackRequest(
    'pre_ipo_buy',
    params: {
      'company_id': companyId,
      'deal_id': dealId,
      'investor_count': list.length,
    },
    request: () async {
      try {
        if (dealId <= 0 && dealUuid.isEmpty) {
          return BaseModel.fromError('Deal id is required');
        }
        final kycError = await WInvestorsApi.transactionKycError(
          list.map((investor) => investor.investorId),
        );
        if (kycError != null) return BaseModel.fromError(kycError);
        final orders = list.map((e) {
          final order = <String, dynamic>{
            'investor_id': e.investorId,
            'shares': e.quantity(),
            'share_price': e.price(),
          };
          if (dealId > 0) order['deal_id'] = dealId;
          if (dealUuid.isNotEmpty) order['deal_uuid'] = dealUuid;
          return order;
        }).toList();
        final body = {'orders': orders};
        var res = await dioConfig.post(AppUrl.wPreIpoBuy, body);
        return BaseModel.fromListJson(
          res.data,
          (p0) => p0
              .map(
                (e) => PreIpoOrderModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
        );
      } catch (e, t) {
        logger.e("Error on buy", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel<PreIpoOrderModel>> cancel({
    required int transactionId,
    required String reason,
  }) => Analytics.trackRequest(
    'transaction_action',
    params: {'action': 'cancel', 'actor': 'partner'},
    request: () async {
      try {
        var res = await dioConfig.post(AppUrl.wPreIpoTransactionCancel, {
          'transaction_id': transactionId,
          'reason': reason,
        });
        return BaseModel.fromJson(
          res.data,
          (data) => PreIpoOrderModel.fromJson(data),
        );
      } catch (e, t) {
        logger.e("Error on cancel", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel<PreIpoOrderModel>> uploadPaymentReceipt({
    required int transactionId,
    required MediaModel file,
  }) => Analytics.trackRequest(
    'transaction_action',
    params: {'action': 'upload_payment_receipt', 'actor': 'partner'},
    request: () async {
      try {
        Map<String, dynamic> body = {'transaction_id': transactionId};
        body.addAll(await dioConfig.createMedia(file, 'file'));
        var res = await dioConfig.post(
          AppUrl.wPreIpoPaymentReceipt,
          body,
          false,
        );
        return BaseModel.fromJson(
          res.data,
          (data) => PreIpoOrderModel.fromJson(data),
        );
      } catch (e, t) {
        logger.e("Error on payment receipt", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel<PreIpoOrderModel>> confirmShareTransfer({
    required int transactionId,
  }) => Analytics.trackRequest(
    'transaction_action',
    params: {'action': 'confirm_share_transfer', 'actor': 'partner'},
    request: () async {
      try {
        var res = await dioConfig.post(AppUrl.wPreIpoConfirmShareTransfer, {
          'transaction_id': transactionId,
        });
        return BaseModel.fromJson(
          res.data,
          (data) => PreIpoOrderModel.fromJson(data),
        );
      } catch (e, t) {
        logger.e("Error on confirm share transfer", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel<PreIpoOrderModel>> uploadShareTransferReceipt({
    required int transactionId,
    required MediaModel file,
  }) => Analytics.trackRequest(
    'transaction_action',
    params: {'action': 'upload_share_transfer_receipt', 'actor': 'partner'},
    request: () async {
      try {
        Map<String, dynamic> body = {'transaction_id': transactionId};
        body.addAll(await dioConfig.createMedia(file, 'file'));
        var res = await dioConfig.post(
          'v2/business/pre-ipo/transaction/share-transfer-receipt',
          body,
          false,
        );
        return BaseModel.fromJson(
          res.data,
          (data) => PreIpoOrderModel.fromJson(data),
        );
      } catch (e, t) {
        logger.e("Error on share-transfer receipt", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel<PreIpoOrderModel>> confirmPayment({
    required int transactionId,
  }) => Analytics.trackRequest(
    'transaction_action',
    params: {'action': 'confirm_payment', 'actor': 'partner'},
    request: () async {
      try {
        var res = await dioConfig.post(
          'v2/business/pre-ipo/transaction/confirm-payment',
          {'transaction_id': transactionId},
        );
        return BaseModel.fromJson(
          res.data,
          (data) => PreIpoOrderModel.fromJson(data),
        );
      } catch (e, t) {
        logger.e("Error on confirm payment", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );

  static Future<BaseModel> inquiry({
    required InvestmentTypeEnum type,
    required String companySlug,
    String notes = '',
    required int quantity,
    required double offerPrice,
    int? settlementDays,
  }) => Analytics.trackRequest(
    'enquiry_submit',
    params: {'enquiry_type': type.name, 'company_slug': companySlug},
    request: () async {
      try {
        Map<String, dynamic> body = {
          "deal_type": type.name,
          "company_slug": companySlug,
          "quantity": quantity,
          "share_price": offerPrice,
          if (settlementDays != null) "settlement_days": settlementDays,
        };
        body.addAllIf(notes.isNotEmpty, {"notes": notes});

        var res = await dioConfig.post(AppUrl.wEnquiry, body);
        BaseModel baseModel = BaseModel.fromMessage(res.data);
        return baseModel;
      } catch (e, t) {
        logger.e("Error on buy", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );
}
