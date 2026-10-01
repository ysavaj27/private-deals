import 'package:private_deals/src/shared/app_exports.dart';

class DocumentApi {
  static Future<BaseModel<List<DocumentModel>>> iDocumentList() async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.iDocument, body);
      BaseModel<List<DocumentModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => DocumentModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on iDocumentList", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<DocumentModel>>> wDocumentList() async {
    try {
      Map<String, dynamic> body = {};
      var res = await dioConfig.get(AppUrl.wDocument, body);
      BaseModel<List<DocumentModel>> baseModel = BaseModel.fromListJson(
          res.data, (p0) => p0.map((e) => DocumentModel.fromJson(e)).toList());
      return baseModel;
    } catch (e, t) {
      logger.e("Error on wDocumentList", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

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
      logger.e("Error on wDocumentList", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
