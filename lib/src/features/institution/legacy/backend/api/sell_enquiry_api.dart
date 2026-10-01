import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/deal/sell_enquiry_model.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';

class SellEnquiryApi {
  static Future<BaseModel<List<SellEnquiryModel>>> getList() async {
    try {
      final response = await dioConfig.get(AppUrl.sellEnquiriesList, {});
      List<SellEnquiryModel> parse(List<dynamic> items) =>
          items.map((item) => SellEnquiryModel.fromJson(item)).toList();
      final data = response.data;
      if (data is List) {
        return BaseModel(s: 1, r: parse(data));
      }
      return BaseModel<List<SellEnquiryModel>>.fromListJson(data, parse);
    } catch (error, stack) {
      logger.e('Error loading sell enquiries', error: error, stackTrace: stack);
      return BaseModel.fromError(error.toString());
    }
  }
}
