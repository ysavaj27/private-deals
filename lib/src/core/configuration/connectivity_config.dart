import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:private_deals/src/shared/functions/dialog.dart';
import 'package:private_deals/src/shared/plugins/logger.dart';
import 'package:private_deals/src/shared/widgets/dialog_widget/no_internet_dialog.dart';
import 'package:get/get.dart';

final ConnectivityConfig connectivity = ConnectivityConfig.instance;

class ConnectivityConfig extends GetxService {
  static final ConnectivityConfig instance = ConnectivityConfig();
  RxBool isLoading = false.obs;

  Future<bool> checkStatus() async {
    try {
      isLoading(true);
      final lookupResult = await InternetAddress.lookup('example.com');
      var res =
          lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty;
      isLoading(false);
      return res;
    } on SocketException catch (_) {
      isLoading(false);
      return false;
    }
  }

  Future<void> checkInternet() async {
    var isInternet = await check();
    logger.d("Internet is :$isInternet");
    if (!isInternet) {
      await showCustomDialog(const NoInternetDialog());
    }
  }

  Future<bool> check() async {
    var res = await Connectivity().checkConnectivity();
    if (res.isNotEmpty && (!res.contains(ConnectivityResult.none))) {
      return true;
    } else {
      return false;
    }
  }
}
