import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/auth/presentation/aif_onboarding/aif_onboarding_page_ctrl.dart';

class DesktopAifOnboardingView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  DesktopAifOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AIF Onboard')),
      body: Obx(() {
        if (c.isLoading.isFalse) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Track your progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Obx(
                  () => FlutterStepIndicator(
                    list: const [0, 1, 2, 3],
                    onChange: (v) {
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => c.step(v));
                    },
                    page: c.step(),
                    height: 20,
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(child: MainView()),
              ],
            ),
          );
        } else {
          return const Loader();
        }
      }),
    );
  }
}

class MainView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        switch (c.step()) {
          case 0:
            return UploadDocumentView();
          case 1:
            return PendingRejectView();
          case 2:
            return SignPendingView();
          case 3:
          case 4:
            return CompleteView();
          default:
            return const ErrorView(
              title: 'Unknown onboarding step',
              message: 'Please restart onboarding or contact support.',
            );
        }
      },
    );
  }
}

class CompleteView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  CompleteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomCardWidget(
        width: context.width,
        padding: const EdgeInsets.all(15),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(Icons.check_circle, color: Colors.green, size: 30),
            LottieImage(
              path: AppAssets.success,
              repeat: false,
              width: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Onboarding Completed',
              style: TextStyle(
                color: Color(0xff008064),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Your onboarding has been completed successfully",
              style: TextStyle(color: Color(0xff9CBED9), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SignPendingView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  SignPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomCardWidget(
        width: context.width,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Signature pending',
              style: TextStyle(
                color: Color(0xff008064),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              c.model().message,
              style: TextStyle(color: Color(0xff9CBED9), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PendingRejectView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  PendingRejectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomCardWidget(
        width: context.width,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Documents generation in process',
              style: const TextStyle(
                color: Color(0xff008064),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
               "PPM and CA document will send you soon",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff9CBED9), fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class UploadDocumentView extends StatelessWidget {
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  UploadDocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 300,
            child: Obx(() {
              return CustomElevatedButton(
                text: "Apply for AIF Onboarding",
                onPressed: c.onPress,
                isLoading: c.isUploading.value,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class DocumentCard extends StatelessWidget {
  final Rx<MediaModel> model;
  final String title;
  final String image;
  final AifOnboardingPageCtrl c = Get.find<AifOnboardingPageCtrl>();

  DocumentCard(
      {super.key,
      required this.model,
      required this.title,
      required this.image});

  @override
  Widget build(BuildContext context) {
    // logger.d("Model IMage :${model().url}");
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
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
                                url: model().url, fit: BoxFit.cover);
                          case FileDataType.filePath:
                            return Image.file(
                              File(model().path),
                              height: context.height,
                              width: context.width,
                              fit: BoxFit.cover,
                            );
                          case FileDataType.bytes:
                            return Image.memory(model().uint8list!,
                                fit: BoxFit.cover);
                          case FileDataType.none:
                            return SVGImage(
                              image,
                              fit: BoxFit.contain,
                            );
                        }
                      }),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Obx(() {
                      return Visibility(
                        visible: model().path.isNotEmpty ||
                            model().dataType == FileDataType.url,
                        child: InkWell(
                          mouseCursor: SystemMouseCursors.click,
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
