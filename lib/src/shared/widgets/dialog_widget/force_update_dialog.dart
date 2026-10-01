import 'package:private_deals/src/shared/app_exports.dart';

class ForceUpdateDialog extends StatelessWidget {
  const ForceUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              app.config.version.title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              app.config.version.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: !app.config.version.forceUpdate,
                  child: TextButton(
                    onPressed: Get.back,
                    child: const Text("Later"),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                TextButton(
                  child: const Text("Update Now"),
                  onPressed: () {
                    Launcher.launchURL(AppKey.updateUrl);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
