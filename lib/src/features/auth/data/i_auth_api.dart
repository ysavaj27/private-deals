import 'package:private_deals/src/shared/app_exports.dart';

class IAuthApi {
  static Future<BaseModel<InvestorModel>> login({
    required String mobileNo,
    required String password,
  }) async {
    try {
      var fcm = await NotificationServices.getToken();
      Map<String, dynamic> body = {
        'mobile_no': mobileNo,
        'password': password,
        'firebase_token': fcm,
        'device_id': init.deviceId,
        'device': init.deviceOs,
      };
      var response = await dioConfig.post(AppUrl.iLogin, body);
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (data) => InvestorModel.fromJson(data),
      );
      if (baseModel.r != null) {
        app.iUserModel(baseModel.r!);
      }
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<InvestorModel>> changePassword(
    String password,
    String cPassword,
  ) async {
    try {
      Map<String, dynamic> body = {
        'investor_id': app.iUser.id,
        "password": password,
        "cpassword": cPassword,
      };
      var response = await dioConfig.post(AppUrl.iForgotChangePass, body);
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (data) => InvestorModel.fromJson(data),
      );
      if (baseModel.r != null) {
        baseModel.r!.token = app.iUser.token;
        app.iUserModel(baseModel.r!);
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Change Password", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> verifyMobileNumber(String mobile) async {
    try {
      Map<String, dynamic> body = {"mobile_number": mobile};
      var res = await dioConfig.post(AppUrl.verifyMobileNumber, body);
      BaseModel baseModel = BaseModel.fromInt(res.data, (i) => i);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Add Remove", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> registerInquiry(
    String name,
    String email,
    String mobile,
  ) async {
    try {
      Map<String, dynamic> body = {
        "name": name,
        "email": email,
        "mobile_number": mobile,
        'device': init.deviceOs,
      };
      var res = await dioConfig.post(AppUrl.iRegisterInquiry, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Add Remove", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> deleteAccount() async {
    try {
      var response = await dioConfig.post(AppUrl.iDeleteAccount, {
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

  static Future<BaseModel> logout() async {
    try {
      var response = await dioConfig.post(AppUrl.iLogout, {
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

  static Future<BaseModel<InvestorModel>> forgotPassword({
    required String phoneNo,
  }) async {
    try {
      Map<String, dynamic> body = {'mobile_no': phoneNo};
      var res = await dioConfig.post(AppUrl.iForgot, body);
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        res.data,
        (p0) => InvestorModel.fromJson(p0),
      );
      if (baseModel.r != null) {
        app.iUserModel(baseModel.r!);
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Verify User", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> resendOtp() async {
    try {
      Map<String, dynamic> body = {'investor_id': app.iUser.id};
      var res = await dioConfig.post(AppUrl.iResendOtp, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Resend Otp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> verifyOtp(String otp) async {
    try {
      Map<String, dynamic> body = {'investor_id': app.iUser.id, "otp": otp};
      var res = await dioConfig.post(AppUrl.iVerifyOtp, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Verify Otp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> forgotChangePassword({
    required String password,
    required String cPassword,
  }) async {
    try {
      Map<String, dynamic> body = {
        'investor_id': app.iUser.id,
        "password": password,
        "cpassword": cPassword,
      };
      var res = await dioConfig.post(AppUrl.iForgotChangePass, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Forgot Change Password", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  // static Future<BaseModel<UserModel>> verifyPhoneNo(
  //     {required String phoneNo}) async {
  //   try {
  //     Map<String, dynamic> body = {'mobile_no': phoneNo};
  //     var res = await dioConfig.post(AppUrl.iVerifyOtp, body);
  //     BaseModel<UserModel> baseModel =
  //         BaseModel.fromJson(res.data, (p0) => UserModel.fromJson(p0));
  //     if (baseModel.r != null) {
  //       app.setUser(prefUser: baseModel.r!);
  //     }
  //     return baseModel;
  //   } catch (e, t) {
  //     logger.e("Error on Verify User", error: e, stackTrace: t);
  //     return BaseModel.fromError(e.toString());
  //   }
  // }

  /// PROFILE

  static Future<BaseModel<InvestorModel>> profileGet() async {
    try {
      var response = await dioConfig.get(AppUrl.iProfileGet, {});
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (data) => InvestorModel.fromJson(data),
      );
      if (baseModel.r != null) {
        baseModel.r!.token = app.iUser.token;
        app.iUserModel(baseModel.r!);
      }
      return baseModel;
    } catch (e, t) {
      logger.e(e, stackTrace: t);
      app.iUserModel(InvestorModel.fromJson({}));
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> profileDetailUpdate({
    required String visibility,
    required String companyName,
    required String companyPosition,
    required String shortBio,
    required String facebookLink,
    required String twitterLink,
    required String instagramLink,
    required String linkedInLink,
    required String websiteLink,
    required String dateOfBirth,
    required int countryId,
    required int stateId,
    required int cityId,
    required String address,
    required String gender,
    required String pincode,
  }) async {
    try {
      Map<String, dynamic> body = {
        'visibility': visibility,
        'twitter_link': twitterLink,
        'instagram_link': instagramLink,
        'linked_in_link': linkedInLink,
        'website_link': websiteLink,
        'date_of_birth': dateOfBirth,
        'country_id': countryId,
        'state_id': stateId,
        'city_id': cityId,
        'address': address,
        'gender': gender,
        'pincode': pincode,
      };
      body.addIf(companyName.isNotEmpty, "company_name", companyName);
      body.addIf(
        companyPosition.isNotEmpty,
        "company_position",
        companyPosition,
      );
      body.addIf(shortBio.isNotEmpty, "short_bio", shortBio);
      body.addIf(facebookLink.isNotEmpty, "facebook_link", facebookLink);
      var res = await dioConfig.post(AppUrl.iProfileSave, body);
      BaseModel baseModel = BaseModel.fromMessage(res.data);
      if (baseModel.isSuccess) {
        await profileGet();
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Resend Otp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> profileUpdate(MediaModel image) async {
    try {
      Map<String, dynamic> body = {};
      if (image.dataType == FileDataType.filePath && image.path.isNotEmpty) {
        body.addAll(
          await dioConfig.createFileImage(
            image.path,
            image.name,
            "profile_photo",
          ),
        );
      }
      var response = await dioConfig.post(
        AppUrl.iProfilePhotoUpdate,
        body,
        false,
      );
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

  static Future<BaseModel> profileRemove() async {
    try {
      var response = await dioConfig.post(AppUrl.iProfilePhotoRemove, {});
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

  static Future<BaseModel> aifOnboarding() async {
    try {
      Map<String, dynamic> body = {"investor_id": app.iUser.id};
      var response = await dioConfig.post(AppUrl.iAifSubmit, body);
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

  static Future<BaseModel<AifModel>> aifGet() async {
    try {
      var response = await dioConfig.get(AppUrl.iAifGet, {});
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

  static Future<BaseModel<InvestorModel>> switchProfile(int investorId) async {
    try {
      var response = await dioConfig.post(AppUrl.iSwitchProfile, {
        'investor_id': investorId,
      });
      BaseModel<InvestorModel> baseModel = BaseModel.fromJson(
        response.data,
        (data) => InvestorModel.fromJson(data),
      );
      if (baseModel.r != null) {
        app.iUserModel().activeInvestor = baseModel.r;
        app.iUserModel.refresh();
        app.iUserModel.refresh();
      }
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Switch profile", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
