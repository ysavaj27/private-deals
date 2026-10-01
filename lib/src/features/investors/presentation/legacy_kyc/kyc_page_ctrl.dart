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

  // Future<void> updateKyc() async {
  //   isLoading(true);
  //   var res = await InvestorKycApi.eKycToken();
  //   isLoading(false);
  //   if (res.status.success) {
  //     logger.d(model.toJson());
  //     model = res;
  //     await kyc();
  //   }
  // }

  Future<void> kyc() async {
    // digioConfig.theme.primaryColor = "#EB1D23";
    // digioConfig.logo = "https://www.shuruup.com/weba/assets/images/logo.png";
    // digioConfig.environment = Environment.PRODUCTION;

    // try {
    //   final _kycWorkflowPlugin = KycWorkflow(digioConfig);
    //   _kycWorkflowPlugin.setGatewayEventListener((GatewayEvent? gatewayEvent) {
    //     logger.d("gateway event : " + gatewayEvent.toString());
    //   });
    //   var workflowResult = await _kycWorkflowPlugin.start(
    //       model.entityId, "${model.mobile}", model.token, null);
    //   /*  var workflowResult = await _kycWorkflowPlugin.start(
    //       "KID240802171902449YPTENX549VCD7H",
    //       "7984718397",
    //       "GWT2408021719024644I1VDQFHGNGD1U",
    //       null);*/
    //   if (workflowResult.code == 1001) {
    //     var res =
    //         await InvestorKycApi.updateEKyc(workflowResult.documentId ?? "");
    //     if (res.isSuccess) {
    //       status(KycStatusEnum.approvalPending);
    //     }
    //   } else {
    //     toast(workflowResult.message ?? "");
    //   }
    //   logger.d('workflowResult : ${workflowResult.documentId}');
    // } on Exception catch (e) {
    //   logger.e(e);
    // }
  }

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
