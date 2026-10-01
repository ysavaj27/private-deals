import 'package:private_deals/src/shared/app_exports.dart';

class AddChannelPartnerDialogCtrl extends GetxController {
  final TextEditingController nameCTRL = TextEditingController();
  final TextEditingController mobileCTRL = TextEditingController();
  final TextEditingController emailCTRL = TextEditingController();
  final TextEditingController passwordCTRL = TextEditingController();
  final TextEditingController commissionCTRL = TextEditingController();
  RxBool isLoading = false.obs;
  var gender = Rxn<String>();
  var partnerType = Rxn<String>();
  RxBool isPreIpo = false.obs;
  RxBool isSecondary = false.obs;
  RxBool isPrimary = false.obs;
  final PartnerUser? model;

  bool get isUpdate => model != null && model!.id != 0;

  AddChannelPartnerDialogCtrl(this.model);

  final GlobalKey<FormState> desktopFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  Future<void> onPress() async {
    isLoading(true);
    var res = await ChannelPartnerApi.addChannelPartner(
      name: nameCTRL.text.trim(),
      email: emailCTRL.text.toLowerCase().trim(),
      mobile: mobileCTRL.text.trim(),
      password: passwordCTRL.text.trim(),
      commission: commissionCTRL.text.trim(),
      partner: partnerType()!,
      gender: gender()!,
    );
    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m);
    }
  }

  @override
  void onInit() {
    // if (kDebugMode) {
    //   nameCTRL.text = 'Mehul';
    //   mobileCTRL.text = '9876543210';
    //   emailCTRL.text = 'mehulkava@gmail.com';
    //   passwordCTRL.text = 'Shuru@123';
    //   commissionCTRL.text = '5.2';
    //   partnerType.value = app.config.enumValues.partnerType.retailer;
    //   gender.value = app.config.enumValues.gender.male;
    //   isPrimary.value = app.wUser.isPrimaryAccess;
    //   isSecondary.value = app.wUser.isSecondaryAccess;
    //   isPreIpo.value = app.wUser.isPreIpoAccess;
    // }
    isPrimary.value = app.wUser.isPrimaryAccess;
    isSecondary.value = app.wUser.isSecondaryAccess;
    isPreIpo.value = app.wUser.isPreIpoAccess;

    if (model != null) {
      nameCTRL.text = model!.name;
      mobileCTRL.text = model!.mobileNumber.toString();
      emailCTRL.text = model!.email.toLowerCase();
      commissionCTRL.text = model!.commission.toString();
      partnerType.value = model!.type;
      gender.value = model!.gender;
      isPrimary.value = model!.isPrimaryAccess;
      isSecondary.value = model!.isSecondaryAccess;
      isPreIpo.value = model!.isPreIpoAccess;
    }
    super.onInit();
  }
}
