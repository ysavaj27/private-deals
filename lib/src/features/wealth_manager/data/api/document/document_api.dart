import 'package:private_deals/src/shared/app_exports.dart';

class DocumentApi {
  static Future<BaseModel> sendDocument(
      int transactionId, String docType) async {
    try {
      Map<String, dynamic> body = {
        "transaction_id": transactionId,
        "document_type": docType,
      };

      var res = await dioConfig.post(AppUrl.wSendDocument, body);
      return BaseModel.fromMessage(res.data);
    } catch (e, t) {
      logger.e("Error on sendDocument", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
