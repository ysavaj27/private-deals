import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/inquiry/inquiry_page_ctrl.dart';

class DesktopInquiryView extends StatelessWidget {
  final InquiryPageCtrl c = Get.find<InquiryPageCtrl>();

  DesktopInquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5E2F2),
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AuthBackground(),
          Positioned(
            left: 65,
            top: 43,
            child: Image.asset(
              AppAssets.newLogo,
              height: 72,
            ),
          ),
          CustomCardWidget(
            borderColor: context.theme.dividerColor.withValues(alpha: 0.4),
            width: 564.66,
            radius: 16,
            color: context.theme.colorScheme.surface.withValues(alpha: 0.94),
            // margin: EdgeInsets.only(right: context.width * 0.13),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 50),
              child: Form(
                key: c.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Enquiry",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please fill in the details below, and our team will contact you shortly.",
                      style: TextStyle(
                        fontSize: 16,
                        color: context.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 45),
                    TitleTextField(
                      isDense: false,
                      isBorder: true,
                      borderColor: context.theme.dividerColor,
                      isAuthFocusBorder: true,
                      fillColor: Colors.transparent,
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
                    const SizedBox(height: 40),
                    TitleTextField(
                      isBorder: true,
                      isAuthFocusBorder: true,
                      fillColor: Colors.transparent,
                      borderColor: context.theme.dividerColor,
                      isDense: false,
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
                    const SizedBox(height: 40),
                    TitleTextField(
                      isBorder: true,
                      isAuthFocusBorder: true,
                      fillColor: Colors.transparent,
                      borderColor: context.theme.dividerColor,
                      isDense: false,
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
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(() {
                          return CustomElevatedButton(
                            radius: 22,
                            width: 222.25,
                            backgroundColor: context.theme.iconTheme.color,
                            color: context.theme.scaffoldBackgroundColor,
                            fontWeight: FontWeight.bold,
                            size: const Size(222.25, 50),
                            text: "Submit",
                            isLoading: c.isLoading.value,
                            onPressed: c.send,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
