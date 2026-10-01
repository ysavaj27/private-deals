// import 'package:private_deals/src/shared/app_exports.dart';
//
// class AddKycDialogCtrl extends GetxController {
//   RxBool isLoading = false.obs;
//   late int investorId;
//
//   AddKycDialogCtrl(this.investorId);
//
//   final GlobalKey<FormState> desktopFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();
//
//   final TextEditingController aadharCTRL = TextEditingController();
//   final TextEditingController aadharBackCTRL = TextEditingController();
//   final TextEditingController panCardCTRL = TextEditingController();
//   Rx<MediaModel> aadhar = MediaModel().obs;
//   Rx<MediaModel> aadharBack = MediaModel().obs;
//   Rx<MediaModel> panCard = MediaModel().obs;
//   Rx<MediaModel> cheque = MediaModel().obs;
//   Rx<MediaModel> cml = MediaModel().obs;
//
//   Future<void> onPress() async {
//     isLoading(true);
//     var res = await WealthManagerKycApi.kycUpdate(
//       investorId: investorId,
//       aadharFront: aadhar(),
//       aadharBack: aadharBack(),
//       panCard: panCard(),
//       cheque: cheque(),
//       cml: cml(),
//     );
//     isLoading(false);
//     if (res.isSuccess) {
//       Get.back(result: true);
//       toast(res.m);
//     } else {
//       toast(res.m);
//     }
//   }
// }
