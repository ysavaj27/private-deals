import 'package:private_deals/src/features/wealth_manager/data/models/3ed_party/pincode_model.dart';

import 'package:private_deals/src/shared/app_exports.dart';

class AddressApi {
  static Future<PinCodeModel> pinCodeToAddress(int pinCode) async {
    try {
      var response = await dioConfig.post(AppUrl.pinCodeToAddress(pinCode), {});
      return PinCodeModel.fromJson(response.data);
    } catch (e, t) {
      logger.e("Error on Resend Otp", error: e, stackTrace: t);
      return PinCodeModel.fromError(e.toString());
    }
  }
}
