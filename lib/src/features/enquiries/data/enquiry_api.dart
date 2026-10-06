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
    int? settlementDays,
  }) async {
    if (uuid.isEmpty ||
        !(institution ? ['accept', 'reject'] : ['withdraw', 'reject']).contains(
          action,
        )) {
      return BaseModel.fromError('This inquiry action is not available.');
    }
    final trimmedReason = reason?.trim() ?? '';
    if (action == 'reject' &&
        ((!institution && trimmedReason.isEmpty) ||
            trimmedReason.length > 1000)) {
      return BaseModel.fromError(
        'Enter a rejection reason of up to 1000 characters.',
      );
    }
    if (institution &&
        action == 'accept' &&
        settlementDays != null &&
        (settlementDays < 1 || settlementDays > 30)) {
      return BaseModel.fromError(
        'Select a settlement cycle from T+1 to T+30.',
      );
    }
    try {
      final response = await dioConfig
          .post('${institution ? institutionPath : partnerPath}/$action', {
            'uuid': uuid,
            if (action == 'reject')
              'reason': trimmedReason.isEmpty ? null : trimmedReason,
            if (institution && action == 'accept' && settlementDays != null)
              'settlement_days': settlementDays,
          });
      // Institution rejection intentionally has no data object.
      return BaseModel.fromMessage(response.data);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }

  static Future<BaseModel<PreIpoOrderModel>> accept({
    required String uuid,
    required int investorId,
  }) async {
    if (uuid.isEmpty || investorId <= 0) {
      return BaseModel.fromError('Select an investor.');
    }
    try {
      final response = await dioConfig.post('$partnerPath/accept', {
        'uuid': uuid,
        'investor_id': investorId,
      });
      return BaseModel.fromJson(response.data, PreIpoOrderModel.fromJson);
    } catch (error) {
      return BaseModel.fromError(error.toString());
    }
  }
}
