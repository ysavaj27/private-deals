import 'package:private_deals/src/shared/app_exports.dart';

class MyEarningPageCtrl extends GetxController {
  final currentIndex = MyEarningTypeEnum.investor.obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final investor = InvestorEarningModel.fromJson({}).obs;
  final partner = PartnerEarningModel.fromJson({}).obs;
  int _request = 0;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> selectType(MyEarningTypeEnum type) async {
    if (currentIndex() == type) return;
    currentIndex(type);
    await refreshData();
  }

  Future<void> refreshData() async {
    final request = ++_request;
    isLoading(true);
    error('');
    try {
      if (currentIndex() == MyEarningTypeEnum.investor) {
        final res = await MyEarningApi.wInvestorEarningList();
        if (request != _request || isClosed) return;
        if (res.isSuccess && res.r != null) {
          investor(res.r);
        } else {
          error('Unable to load investor earnings. Please try again.');
        }
      } else {
        final res = await MyEarningApi.wPartnerEarningList();
        if (request != _request || isClosed) return;
        if (res.isSuccess && res.r != null) {
          partner(res.r);
        } else {
          error('Unable to load channel partner earnings. Please try again.');
        }
      }
    } catch (_) {
      if (request == _request && !isClosed) {
        error('Unable to load earnings. Please try again.');
      }
    } finally {
      if (request == _request && !isClosed) isLoading(false);
    }
  }
}
