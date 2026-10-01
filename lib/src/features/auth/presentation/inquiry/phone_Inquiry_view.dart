import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/inquiry/inquiry_page_ctrl.dart';

class PhoneInquiryView extends StatelessWidget {
  final InquiryPageCtrl c = Get.find<InquiryPageCtrl>();

  PhoneInquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Partner Inquiry")),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Form(
          key: c.formKey,
          child: Column(
            children: [
              FadeInRight(
                child: TitleTextField(
                  name: "Name",
                  controller: c.nameCTRL,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              FadeInRight(
                delay: const Duration(milliseconds: 200),
                child: TitleTextField(
                  name: "Email",
                  controller: c.emailCTRL,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Enter your email address';
                    } else if (!GetUtils.isEmail(p0.trim())) {
                      return 'Enter valid email address';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),
              FadeInRight(
                delay: const Duration(milliseconds: 400),
                child: TitleTextField(
                  name: "Mobile No",
                  controller: c.mobileNoCTRL,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  isRequired: true,
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Enter your mobile number';
                    } else if (!GetUtils.isPhoneNumber(p0)) {
                      return 'Enter valid phone number';
                    } else if (p0.trim().length != 10) {
                      return 'Phone number should be 10 digit only';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: CustomOutlinedButton(
                  width: 150,
                  onPressed: c.verifyPhoneNumber,
                  text: "Get OTP",
                ),
              ),
              Obx(() {
                return Visibility(
                  visible: c.isOtp.value,
                  child: const SizedBox(height: 15),
                );
              }),
              Obx(() {
                return Visibility(
                  visible: c.isOtp.value,
                  child: OtpTextField(
                    controller: c.otpCTRL,
                    validator: (p0) {
                      if (c.otp.isNotEmpty && p0 != c.otp.toString()) {
                        return 'Invalid Otp';
                      }
                      return null;
                    },
                    onCompleted: (p0) {
                      if (p0 == c.otp.toString()) {
                        c.isVerified(true);
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: 30),
              FadeInRight(
                delay: const Duration(milliseconds: 600),
                child: Obx(() {
                  return CustomElevatedButton(
                    text: "Submit",
                    isLoading: c.isLoading.value,
                    onPressed: c.send,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
