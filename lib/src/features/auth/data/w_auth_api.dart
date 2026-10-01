import 'package:private_deals/src/shared/app_exports.dart';

class WAuthApi {
  static Future<BaseModel<PartnerUser>> login({
    required String mobileNo,
    required String password,
  }) async {
    try {
      // var fcm = await NotificationServices.getToken();
      Map<String, dynamic> body = {
        'mobile_no': mobileNo,
        'password': password,
        'firebase_token': "N/A",
        'device_id': init.deviceId,
        'device': init.deviceOs,
      };
      var response = await dioConfig.post(AppUrl.wLogin, body);
      BaseModel<PartnerUser> baseModel = BaseModel.fromJson(
        response.data,
        (data) => PartnerUser.fromJson(data),
      );
      if (baseModel.isSuccess && baseModel.r != null) {
        await app.setUser(prefUser: baseModel.r!.toJson());
      }
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> logout() async {
    try {
      var response = await dioConfig.post(AppUrl.wLogout, {
        'device_id': init.deviceId,
        'device': init.deviceOs,
      });
      BaseModel baseModel = BaseModel.fromMessage(response.data);
      return baseModel;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PartnerUser>> profileGet() async {
    final requestRevision = app.revision;
    final sessionToken = app.token;
    try {
      var response = await dioConfig.get(AppUrl.wProfileGet, {});
      BaseModel<PartnerUser> baseModel = BaseModel.fromJson(
        response.data,
        (data) => PartnerUser.fromJson(data),
      );
      if (baseModel.isSuccess &&
          baseModel.r != null &&
          requestRevision == app.revision) {
        baseModel.r!.token = sessionToken;
        await app.setUser(prefUser: baseModel.r!.toJson());
      }
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> profileDetailUpdate({required String email}) async {
    try {
      Map<String, dynamic> body = {'email': email};
      var res = await dioConfig.post(AppUrl.wProfileSave, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      if (baseModel.isSuccess) {
        await profileGet();
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Profile Detail Update", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> deleteAccount() async {
    try {
      var response = await dioConfig.post(AppUrl.wDeleteAccount, {
        'device_id': init.deviceId,
        'device': init.deviceOs,
      });
      BaseModel baseModel = BaseModel.fromMessage(response.data);
      return baseModel;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PartnerUser>> changePassword(
    String password,
    String cPassword,
  ) async {
    try {
      Map<String, dynamic> body = {
        "password": password,
        "cpassword": cPassword,
      };
      var response = await dioConfig.post(AppUrl.wChangePassword, body);
      BaseModel<PartnerUser> baseModel = BaseModel.fromJson(
        response.data,
        (data) => PartnerUser.fromJson(data),
      );
      if (baseModel.isSuccess) {
        await profileGet();
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Change Password", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<PartnerUser>> forgotPassword({
    required String phoneNo,
  }) async {
    app.recoveryPartnerId = null;
    try {
      Map<String, dynamic> body = {'mobile_no': phoneNo};
      var res = await dioConfig.post(AppUrl.wForgot, body);
      BaseModel<PartnerUser> baseModel = BaseModel.fromJson(
        res.data,
        (p0) => PartnerUser.fromJson(p0),
      );
      if (baseModel.isSuccess && baseModel.r != null) {
        app.recoveryPartnerId = baseModel.r!.id;
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Verify User", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> resendOtp() async {
    try {
      Map<String, dynamic> body = {'partner_id': app.recoveryPartnerId};
      var res = await dioConfig.post(AppUrl.wResendOtp, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Resend Otp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> verifyOtp(String otp) async {
    try {
      Map<String, dynamic> body = {
        'partner_id': app.recoveryPartnerId,
        "otp": otp,
      };
      var res = await dioConfig.post(AppUrl.wVerifyOtp, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Verify Otp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> forgotChangePassword({
    required String password,
  }) async {
    try {
      Map<String, dynamic> body = {
        'partner_id': app.recoveryPartnerId,
        "password": password,
      };
      var res = await dioConfig.post(AppUrl.wForgotChangePass, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Forgot Change Password", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<AifModel>> aifGet(int investorId) async {
    try {
      var response = await dioConfig.get(AppUrl.wAifGet, {
        "investor_id": investorId,
      });
      BaseModel<AifModel> baseModel = BaseModel.fromJson(
        response.data,
        (data) => AifModel.fromJson(data),
      );
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> aifOnboarding({required int investorId}) async {
    try {
      Map<String, dynamic> body = {"investor_id": investorId};
      var response = await dioConfig.post(AppUrl.wAifSubmit, body);
      BaseModel baseModel = BaseModel.fromMessage(response.data);
      if (baseModel.isSuccess) {
        await profileGet();
      }
      return baseModel;
    } catch (e) {
      logger.e(e);
      return BaseModel.fromError(e.toString());
    }
  }
}
