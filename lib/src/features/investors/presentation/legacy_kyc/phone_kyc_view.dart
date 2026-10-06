import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy_kyc/kyc_page_ctrl.dart';

class PhoneKycView extends StatelessWidget {
  final KYCPageCtrl c = Get.find<KYCPageCtrl>();

  PhoneKycView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KYC")),
      body: MainWidget(),
    );
  }
}

class MainWidget extends StatelessWidget {
  final int firstExpand;
  final int secondExpand;

  MainWidget({super.key, this.firstExpand = 1, this.secondExpand = 1});

  final KYCPageCtrl c = Get.find<KYCPageCtrl>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (c.status()) {
        case KycStatusEnum.pending:
          return ManualKycView();
        case KycStatusEnum.approve:
          return FadeIn(
            child: CustomCardWidget(
              radius: 10,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 61,
                        width: 61,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: context.theme.disabledColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        child: CacheImage(
                          url: app.iUser.profile,
                          placeHolderImage: app.iUser.placeholderImage,
                          // url:
                          //     "https://s3-ap-south-1.amazonaws.com/shuruup-main/public/startup/banner/1667892234.6323.png",
                          height: 97,
                          width: 97,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.iUser.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "DOB ${app.iUser.kyc.dobAsAadhar.dateWithSortMonthYear}",
                            style: const TextStyle(
                              fontSize: 12,
                              // color: context.theme.disabledColor
                              //     .withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Account No :",
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.disabledColor.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            app.iUser.kyc.aadharNo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name as Aadhaar :",
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.disabledColor.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            app.iUser.kyc.nameAsAadhar,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Name as PAN",
                            style: TextStyle(
                              fontSize: 12,
                              color: context.theme.disabledColor.withValues(
                                alpha: 0.5,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            app.iUser.kyc.nameAsPan,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Email :${app.iUser.email.isEmpty ? '—' : app.iUser.email}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ],
              ),
            ),
          );
        case KycStatusEnum.approvalPending:
          return FadeIn(
            child: CustomCardWidget(
              radius: 10,
              width: context.width,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(vertical: 59, horizontal: 25),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SVGImage(AppAssets.approvalPending),
                  SizedBox(height: 56),
                  Text(
                    "Approval Pending Please wait",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          );
        case KycStatusEnum.rejected:
          return FadeIn(
            child: CustomCardWidget(
              radius: 10,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              child: SingleChildScrollView(
                child: Form(
                  key: c.phoneFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your KYC is Rejected",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        app.iUser.kyc.notes,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        runSpacing: 20,
                        children: [
                          DocumentCard(
                            model: c.aadharFront,
                            title: "Upload Front Side of Aadhaar Card",
                            image: AppAssets.aadhaarFront,
                          ),
                          DocumentCard(
                            model: c.aadharBack,
                            title: "Upload Back Side of Aadhaar Card",
                            image: AppAssets.aadhaarBack,
                          ),
                          DocumentCard(
                            model: c.panCard,
                            title: "Upload Your Pan Card",
                            image: AppAssets.panCard,
                          ),
                          DocumentCard(
                            model: c.cheque,
                            title: "Upload Your Cancel Cheque",
                            image: AppAssets.cancelCheque,
                          ),
                          DocumentCard(
                            model: c.cml,
                            title: "Upload Your CML or CMR",
                            image: AppAssets.cmlOrCmr,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Obx(() {
                        return CustomElevatedButton(
                          text: "Submit",
                          onPressed: c.onPress,
                          isLoading: c.isUploading.value,
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
      }
    });
  }
}

class DocumentCard extends StatelessWidget {
  final Rx<MediaModel> model;
  final String title;
  final String image;
  final KYCPageCtrl c = Get.find<KYCPageCtrl>();

  DocumentCard({
    super.key,
    required this.model,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // logger.d("Model IMage :${model().url}");
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        var res = await FilePickers().pickSingleImage();
        if (res != null) {
          model(res);
          model.refresh();
        }
      },
      child: CustomDottedBorder(
        radius: 16,
        padding: 15,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xff008064),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "The image must be in JPG or PNG format and not exceed 2 MB.",
                    style: TextStyle(fontSize: 12),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 85,
              height: 60,
              // padding: const EdgeInsets.all(13),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Obx(() {
                        switch (model().dataType) {
                          case FileDataType.url:
                            return CacheImage(
                              url: model().url,
                              fit: BoxFit.cover,
                            );
                          case FileDataType.filePath:
                            return Image.file(
                              File(model().path),
                              height: context.height,
                              width: context.width,
                              fit: BoxFit.cover,
                            );
                          case FileDataType.bytes:
                            return Image.memory(
                              model().uint8list!,
                              fit: BoxFit.cover,
                            );
                          case FileDataType.none:
                            return SVGImage(image, fit: BoxFit.contain);
                        }
                      }),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Obx(() {
                      return Visibility(
                        visible:
                            model().path.isNotEmpty ||
                            model().dataType == FileDataType.url,
                        child: InkWell(
                          onTap: () async {
                            model().path = "";
                            model().dataType = FileDataType.none;
                            model.refresh();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 18,
                            width: 18,
                            // padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.clear, size: 14),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManualKycView extends StatelessWidget {
  final KYCPageCtrl c = Get.find<KYCPageCtrl>();

  ManualKycView({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: c.phoneFormKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 20,
              children: [
                DocumentCard(
                  model: c.aadharFront,
                  title: "Upload Front Side of Aadhaar Card",
                  image: AppAssets.aadhaarFront,
                ),
                DocumentCard(
                  model: c.aadharBack,
                  title: "Upload Back Side of Aadhaar Card",
                  image: AppAssets.aadhaarBack,
                ),
                DocumentCard(
                  model: c.panCard,
                  title: "Upload Your Pan Card",
                  image: AppAssets.panCard,
                ),
                DocumentCard(
                  model: c.cheque,
                  title: "Upload Your Cancel Cheque",
                  image: AppAssets.cancelCheque,
                ),
                DocumentCard(
                  model: c.cml,
                  title: "Upload Your CML or CMR",
                  image: AppAssets.cmlOrCmr,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              return CustomElevatedButton(
                text: "Submit",
                onPressed: c.onPress,
                isLoading: c.isUploading.value,
              );
            }),
          ],
        ),
      ),
    );
  }
}
