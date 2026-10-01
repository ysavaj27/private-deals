import 'package:private_deals/src/shared/app_exports.dart';

class TestPageCtrl extends GetxController {
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  Future<void> getData() async {
    // var res = await DashboardApi.wealthManagerDashboard();
  }
}
