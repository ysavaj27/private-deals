import 'package:private_deals/src/shared/app_exports.dart';

class AddInvestorPageCtrl extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isObscure = true.obs;
  RxList<MasterTypeModel> countryList = <MasterTypeModel>[].obs;
  RxList<MasterTypeModel> stateList = <MasterTypeModel>[].obs;
  RxList<MasterTypeModel> cityList = <MasterTypeModel>[].obs;
  var accountVisibility = Rxn<String>();
  var country = Rxn<MasterTypeModel>();
  var state = Rxn<MasterTypeModel>();
  var city = Rxn<MasterTypeModel>();
  var gender = Rxn<String>();
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;
  var investorType = Rxn<String>();

  // RxBool isPreIpo = false.obs;
  // RxBool isSecondary = true.obs;
  // RxBool isPrimary = true.obs;
  final GlobalKey<FormState> desktopFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();
  final TextEditingController nameCTRL = TextEditingController();
  final TextEditingController emailCTRL = TextEditingController();
  final TextEditingController phoneNoCTRL = TextEditingController();
  final TextEditingController addressCTRL = TextEditingController();
  final TextEditingController passwordCTRL = TextEditingController();
  final TextEditingController cityCTRL = TextEditingController();
  final TextEditingController pinCodeCTRL = TextEditingController();
  final TextEditingController aadharCTRL = TextEditingController();
  final TextEditingController aadharBackCTRL = TextEditingController();
  final TextEditingController panCardCTRL = TextEditingController();
  Rx<MediaModel> aadhar = MediaModel().obs;
  Rx<MediaModel> aadharBack = MediaModel().obs;
  Rx<MediaModel> panCard = MediaModel().obs;

  @override
  void onInit() {
    setData();
    getCountry();
    super.onInit();
  }

  void setData() {
    var user = Get.arguments;
    if (user != null && user is InvestorModel) {
      logger.d(user.toJson());
      investor(user);
      investorType.value = user.investorType;
      nameCTRL.text = user.name;
      phoneNoCTRL.text = user.mobileNumber.toString();
      emailCTRL.text = user.email;
      addressCTRL.text = user.address;
      pinCodeCTRL.text = user.pincode.toString();
      gender.value = user.gender;
      // isPrimary(user.isPrimaryAccess);
      // isSecondary(user.isSecondaryAccess);
      // isPreIpo(user.isPreIpoAccess);
      if (user.countryId.isNotEmpty) {
        country(user.country);
      }
      // getCountry();
      if (user.stateId.isNotEmpty) {
        state(user.state);
        getState(user.countryId);
      }
      if (user.cityId.isNotEmpty) {
        city(user.city);
        getCity(user.stateId);
      }
    } else {
      investorType.value = app.config.enumValues.investorType.individual;
    }
  }

  Future<void> onPress() async {
    isLoading(true);
    var res = await WInvestorsApi.addInvestor(
      id: investor().id,
      investorType: investorType()!,
      name: nameCTRL.text,
      mobileNumber: phoneNoCTRL.text,
      email: emailCTRL.text.toLowerCase(),
      address: addressCTRL.text,
      cityId: city()?.id ?? 0,
      pincode: pinCodeCTRL.text,
      gender: gender() ?? "",
      password: passwordCTRL.text,
      // isPreIPOAccess: isPreIpo(),
      // isPrimaryAccess: isPrimary(),
      // isSecondaryAccess: isSecondary(),
    );
    isLoading(false);
    if (res.isSuccess) {
      if (investor().id.isEmpty && res.r != null) {
        Get.offNamed(Routes.kycPath(Get.currentRoute, res.r?.uuid ?? ""));
      } else {
        Get.back(result: true);
        toast(res.m, MessageEnum.success);
      }
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  Future<void> getCountry() async {
    var res = await MasterApi.countryList();
    if (res.isSuccess) {
      countryList(res.r);
      state(null);
      city(null);
    }
  }

  Future<void> getState(int countryId) async {
    var res = await MasterApi.stateList(countryId);
    if (res.isSuccess) {
      stateList(res.r);
      city(null);
    }
  }

  Future<void> getCity(int stateId) async {
    var res = await MasterApi.cityList(stateId);
    if (res.isSuccess) {
      cityList(res.r);
    }
  }
}
