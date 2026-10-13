// import 'package:kyc_workflow/digio_config.dart';
// import 'package:kyc_workflow/environment.dart';
// import 'package:kyc_workflow/gateway_event.dart';
// import 'package:kyc_workflow/kyc_workflow.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class KYCPageCtrl extends GetxController {
  Rx<MediaModel> aadharFront = MediaModel().obs;
  Rx<MediaModel> aadharBack = MediaModel().obs;
  Rx<MediaModel> panCard = MediaModel().obs;
  Rx<MediaModel> cheque = MediaModel().obs;
  Rx<MediaModel> cml = MediaModel().obs;
  Rx<AifModel> model = AifModel.fromJson({}).obs;
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;

  // var kycType = Rxn<KycTypeEnum>(null);
  RxInt step = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  Rx<KycStatusEnum> status = KycStatusEnum.approve.obs;

  // var kycType = Rxn<KycTypeEnum>(null);
  // final TextEditingController aadharCTRL = TextEditingController();
  // final TextEditingController aadharBackCTRL = TextEditingController();
  // final TextEditingController panCardCTRL = TextEditingController();

  final GlobalKey<FormState> desktopFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  // DigioConfig digioConfig = DigioConfig();
  // EKycModel model = EKycModel();

  Future<void> kyc() async {}

  Future<void> setData() async {
    var user = Get.arguments;
    if (user != null && user is InvestorModel) {
      investor(user);
      status(user.status);
    }
  }

  Future<void> onPress() async {
    if (aadharFront().isEmpty) {
      toast('Upload aadhar front side image');
      return;
    }
    if (aadharBack().isEmpty) {
      toast('Upload aadhar back side image');
      return;
    }
    if (panCard().isEmpty) {
      toast('Upload pan card image');
      return;
    }
    if (cheque().isEmpty) {
      toast('Upload cancel check image');
      return;
    }
    if (cml().isEmpty) {
      toast('Upload CML or CMR image');
      return;
    }

    isUploading(true);
    var res = await WealthManagerKycApi.kycUpdate(
      aadharFront: aadharFront(),
      aadharBack: aadharBack(),
      panCard: panCard(),
      cheque: cheque(),
      cml: cml(),
      investorId: investor().id,
    );
    isUploading(false);
    if (res.isSuccess) {
      toast(res.m);
      status(KycStatusEnum.approvalPending);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onInit() {
    setData();
    super.onInit();
  }
}
