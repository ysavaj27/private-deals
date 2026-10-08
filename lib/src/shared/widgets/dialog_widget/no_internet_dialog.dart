import 'dart:io';

import 'package:private_deals/src/shared/app_exports.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.dialogBackgroundColor,
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "No Internet Connection".tr,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            "Wifi or cellular network is required. Please check your network",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14.0),
          ),
          const SizedBox(height: 15.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Obx(() {
                  if (connectivity.isLoading.isFalse) {
                    return Text(
                      "Check Again".tr,
                      style: TextStyle(color: AppColors.green(context)),
                    );
                  } else {
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    );
                  }
                }),
                onPressed: () async {
                  if (await connectivity.check()) {
                    await ConfigApi.config();
                    Get.offAllNamed('/init');
                    // Get.back();
                  } else {
                    toast('No internet connection found');
                  }
                },
              ),
              const SizedBox(width: 5.0),
              TextButton(
                child: Text("Exit", style: const TextStyle(color: Colors.red)),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
