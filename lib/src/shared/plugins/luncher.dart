import 'package:private_deals/src/shared/plugins/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  static void launchURL(String url) async {
    var uri = Uri.parse(url.toLowerCase().trim());
    try {
      // logger.d("Url :$uri");
      await launchUrl(uri);
      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri);
      // } else {
      //   logger.e(uri);
      //   toast("Unable to lunch $uri");
      // }
    } catch (e) {
      logger.e("Error: $e");
    }
  }

  static Future<void> openNewTab(String url) async {
    await launchUrl(
      Uri.parse(url),
      webOnlyWindowName: '_blank',
    );
  }
}
