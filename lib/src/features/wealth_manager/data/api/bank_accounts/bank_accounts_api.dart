// import 'package:private_deals/src/shared/app_exports.dart';
//
// class BankAccountApi {
//   static Future<BaseModel<List<BankAccountModel>>> bankAccountList() async {
//     try {
//       var res = await dioConfig.get(AppUrl.iBankAccount, {});
//       BaseModel<List<BankAccountModel>> baseModel = BaseModel.fromListJson(
//           res.data,
//           (p0) => p0.map((e) => BankAccountModel.fromJson(e)).toList());
//       return baseModel;
//     } catch (e, t) {
//       logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
//       return BaseModel.fromError(e.toString());
//     }
//   }
//
//   static Future<BaseModel> addAccount({
//     required String accountName,
//     required String accountNumber,
//     required String bankName,
//     required String ifscCode,
//     required String bankAddress,
//   }) async {
//     try {
//       Map<String, dynamic> body = {
//         "account_name": accountName,
//         "account_number": accountNumber,
//         "bank_name": bankName,
//         "ifsc_code": ifscCode,
//         "bank_address": bankAddress,
//       };
//       var res = await dioConfig.post(AppUrl.iBankAccount, body);
//       BaseModel baseModel = BaseModel.fromMessage(res.data);
//       return baseModel;
//     } catch (e, t) {
//       logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
//       return BaseModel.fromError(e.toString());
//     }
//   }
//
//   static Future<BaseModel> defaultBankAccount({required int accountId}) async {
//     try {
//       var res = await dioConfig
//           .post(AppUrl.iDefaultBankAccount, {"account_id": accountId});
//       BaseModel baseModel = BaseModel.fromMessage(res.data);
//       return baseModel;
//     } catch (e, t) {
//       logger.e("Error on UpComingPitch List", error: e, stackTrace: t);
//       return BaseModel.fromError(e.toString());
//     }
//   }
// }
