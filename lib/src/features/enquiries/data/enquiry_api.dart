import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_model.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';

class EnquiryApi {
  static const partnerPath = 'v2/business/enquiries/deals';
  static const institutionPath = 'v2/business/institution/enquiries';

  static Future<BaseModel<List<EnquiryModel>>> list({
    required bool institution,
  }) async {
    try {
      final response = await dioConfig.get(
        institution ? institutionPath : partnerPath,
        {},
      );
      return BaseModel.fromListJson(
        response.data,
        (items) => items
            .map(
              (item) => EnquiryModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel> respond({
    required bool institution,
    required String uuid,
    required String action,
    String? reason,
  }) async {
    if (uuid.isEmpty ||
        !(institution ? ['accept', 'reject'] : ['withdraw', 'reject']).contains(
          action,
        )) {
      return BaseModel.fromError('This enquiry action is not available.');
    }
    final trimmedReason = reason?.trim() ?? '';
    if (action == 'reject' &&
        ((!institution && trimmedReason.isEmpty) ||
            trimmedReason.length > 1000)) {
      return BaseModel.fromError(
        'Enter a rejection reason of up to 1000 characters.',
      );
    }
    try {
      final response = await dioConfig.post(
        '${institution ? institutionPath : partnerPath}/$action',
        {
          'uuid': uuid,
          if (action == 'reject')
            'reason': trimmedReason.isEmpty ? null : trimmedReason,
        },
      );
      // Institution rejection intentionally has no data object.
      return BaseModel.fromMessage(response.data);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel> sendQuote({
    required String uuid,
    required int quantity,
    required double sharePrice,
    required int settlementDays,
  }) async {
    if (uuid.isEmpty) {
      return BaseModel.fromError('This enquiry is not available.');
    }
    if (quantity < 1) {
      return BaseModel.fromError('Quantity must be at least 1.');
    }
    if (!sharePrice.isFinite || sharePrice < 0.01) {
      return BaseModel.fromError('Offer price must be greater than 0.');
    }
    if (settlementDays < 1 || settlementDays > 30) {
      return BaseModel.fromError('Select a settlement cycle from T+1 to T+30.');
    }
    try {
      final response = await dioConfig.post('$institutionPath/quote', {
        'uuid': uuid,
        'quantity': quantity,
        'share_price': sharePrice,
        'settlement_days': settlementDays,
      });
      return BaseModel.fromMessage(response.data);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel> withdrawQuote({required String uuid}) async {
    if (uuid.isEmpty) {
      return BaseModel.fromError('This enquiry is not available.');
    }
    try {
      final response = await dioConfig.post('$institutionPath/quote/withdraw', {
        'uuid': uuid,
      });
      return BaseModel.fromMessage(response.data);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> acceptQuote({
    required String uuid,
    required String quoteUuid,
    required int investorId,
  }) async {
    if (uuid.isEmpty || quoteUuid.isEmpty) {
      return BaseModel.fromError('This quote is not available.');
    }
    if (investorId <= 0) {
      return BaseModel.fromError('Select an investor.');
    }
    final kycError = await WInvestorsApi.transactionKycError([investorId]);
    if (kycError != null) return BaseModel.fromError(kycError);
    try {
      final response = await dioConfig.post('$partnerPath/quotes/accept', {
        'uuid': uuid,
        'quote_uuid': quoteUuid,
        'investor_id': investorId,
      });
      return BaseModel.fromJson(response.data, PreIpoOrderModel.fromJson);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> accept({
    required String uuid,
    required int investorId,
  }) => _acceptWithInvestor('accept', uuid: uuid, investorId: investorId);

  /// A different partner takes the other side of someone else's open enquiry.
  static Future<BaseModel<PreIpoOrderModel>> acceptCounterparty({
    required String uuid,
    required int investorId,
  }) => _acceptWithInvestor(
    'accept-counterparty',
    uuid: uuid,
    investorId: investorId,
  );

  static Future<BaseModel<PreIpoOrderModel>> _acceptWithInvestor(
    String action, {
    required String uuid,
    required int investorId,
  }) async {
    if (uuid.isEmpty || investorId <= 0) {
      return BaseModel.fromError('Select an investor.');
    }
    final kycError = await WInvestorsApi.transactionKycError([investorId]);
    if (kycError != null) return BaseModel.fromError(kycError);
    try {
      final response = await dioConfig.post('$partnerPath/$action', {
        'uuid': uuid,
        'investor_id': investorId,
      });
      return BaseModel.fromJson(response.data, PreIpoOrderModel.fromJson);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }
}
