import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/transaction/pre_ipo_transaction_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';

class PreIPOTransactionApi {
  static Future<BaseModel<List<PreIPOTransactionModel>>> getTransactions({
    required String status,
    String company = '',
    required int skip,
    int take = 20,
  }) async {
    try {
      final res = await dioConfig.get(AppUrl.preIPOTransactions, {
        'status': status,
        if (company.trim().isNotEmpty) 'company': company.trim(),
        'skip': skip,
        'take': take,
      });
      return BaseModel.fromListJson(
        res.data,
        (data) => data
            .map(
              (e) =>
                  PreIPOTransactionModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
    } catch (e, t) {
      logger.e('Unable to load unlisted transactions', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
