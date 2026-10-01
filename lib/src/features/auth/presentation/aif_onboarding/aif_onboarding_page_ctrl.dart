import 'package:private_deals/src/shared/app_exports.dart';

class AifOnboardingPageCtrl extends GetxController {
  Rx<MediaModel> aadharFront = MediaModel().obs;
  Rx<MediaModel> aadharBack = MediaModel().obs;
  Rx<MediaModel> panCard = MediaModel().obs;
  Rx<MediaModel> cheque = MediaModel().obs;
  Rx<MediaModel> cml = MediaModel().obs;
  Rx<AifModel> model = AifModel.fromJson({}).obs;
  RxInt step = 0.obs;

  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;

  Future<void> onPress() async {
    if (!investor().isKycSuccess) {
      toast('Please complete your kyc first');
      return;
    }

    isUploading(true);
    var res = await WAuthApi.aifOnboarding(investorId: investor().id);
    isUploading(false);
    if (res.isSuccess) {
      step(1);
    } else {
      toast(res.m);
    }
  }

  Future<void> getData() async {
    isLoading(true);
    var user = Get.arguments;
    if (user != null && user is InvestorModel) {
      investor(user);
      var res = await WAuthApi.aifGet(user.id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading(false);
        if (res.isSuccess) {
          if (res.r != null) {
            model(res.r);
            step(1);
            setData();
          }
        } else {
          toast(res.m);
        }
      });
    }
  }

  Future<void> setData() async {
    if (model().status == 2) {
      step(2);
    } else if (model().status == 3) {
      step(4);
    }

    // aadharFront().name = model().aadharFront.displayName;
    // aadharFront().dataType = FileDataType.url;
    // aadharFront().url = model().aadharFront.signedPath;
    //
    // aadharBack().name = model().aadharBack.displayName;
    // aadharBack().dataType = FileDataType.url;
    // aadharBack().url = model().aadharBack.signedPath;
    //
    // panCard().name = model().panCard.displayName;
    // panCard().dataType = FileDataType.url;
    // panCard().url = model().panCard.signedPath;
    //
    // cheque().name = model().cheque.displayName;
    // cheque().dataType = FileDataType.url;
    // cheque().url = model().cheque.signedPath;
    //
    // cml().name = model().cml.displayName;
    // cml().dataType = FileDataType.url;
    // cml().url = model().cml.signedPath;
  }


  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
