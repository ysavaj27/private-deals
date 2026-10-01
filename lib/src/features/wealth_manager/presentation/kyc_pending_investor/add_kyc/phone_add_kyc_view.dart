// import 'package:private_deals/src/shared/app_exports.dart';
//
// import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/add_kyc/add_kyc_dialog_ctrl.dart';
//
// class PhoneAddKycView extends StatelessWidget {
//   final AddKycDialogCtrl c = Get.find<AddKycDialogCtrl>();
//
//   PhoneAddKycView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 600,
//       decoration: BoxDecoration(
//         color: context.theme.scaffoldBackgroundColor,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       padding: EdgeInsets.symmetric(vertical: 22, horizontal: 15),
//       child: Form(
//         key: c.phoneFormKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Complete KYC",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: Get.back,
//                   splashRadius: 25,
//                   icon: const Icon(Icons.close),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Divider(color: context.theme.disabledColor.withValues(alpha: 0.2)),
//             const SizedBox(height: 20),
//             TitleTextField(
//               name: "Aadhar card front image",
//               isRequired: true,
//               controller: c.aadharCTRL,
//               readOnly: true,
//               validator: (p0) {
//                 if (p0 == null || p0.isEmpty) {
//                   return 'Select aadhar card front image';
//                 }
//                 return null;
//               },
//               onTap: () async {
//                 var res = await FilePickers().pickSingleImage();
//                 if (res != null) {
//                   c.aadhar(res);
//                   c.aadharCTRL.text = res.name;
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TitleTextField(
//               controller: c.aadharBackCTRL,
//               name: 'Aadhar card back image',
//               isRequired: true,
//               readOnly: true,
//               validator: (p0) {
//                 if (p0 == null || p0.isEmpty) {
//                   return 'Select aadhar card back image';
//                 }
//                 return null;
//               },
//               onTap: () async {
//                 var res = await FilePickers().pickSingleImage();
//                 if (res != null) {
//                   c.aadharBack(res);
//                   c.aadharBackCTRL.text = res.name;
//                 }
//               },
//             ),
//             const SizedBox(height: 20),
//             TitleTextField(
//               name: "Pan card image",
//               controller: c.panCardCTRL,
//               isRequired: true,
//               readOnly: true,
//               validator: (p0) {
//                 if (p0 == null || p0.isEmpty) {
//                   return 'Select pan card image';
//                 }
//                 return null;
//               },
//               onTap: () async {
//                 var res = await FilePickers().pickSingleImage();
//                 if (res != null) {
//                   c.panCard(res);
//                   c.panCardCTRL.text = res.name;
//                 }
//               },
//             ),
//             const SizedBox(height: 40),
//             Obx(() {
//               return CustomElevatedButton(
//                 fontSize: 16,
//                 isLoading: c.isLoading.value,
//                 onPressed: () {
//                   if (c.phoneFormKey.currentState?.validate() ?? false) {
//                     c.onPress();
//                   }
//                 },
//                 text: 'Submit',
//               );
//             }),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
