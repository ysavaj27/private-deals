import 'package:private_deals/src/shared/app_exports.dart';

import 'investor_list_dialog/investor_list_dialog.dart';

class PrimaryDetailPageCtrl extends GetxController {
  final isLoading = false.obs;
  final loadError = ''.obs;
  final isOpeningInvestment = false.obs;
  final startupDetailModel = StartupModel.fromJson({}).obs;

  StartupModel get model => startupDetailModel();
  bool get canInvest =>
      !isClosed &&
      !isLoading.value &&
      loadError.value.isEmpty &&
      model.id > 0 &&
      model.raisingRound.id > 0 &&
      model.raisingRound.roundStatus.isNotEmpty &&
      model.isActiveRound;

  Future<void> getData() async {
    isLoading(true);
    loadError('');
    try {
      final startup = Get.parameters['slug'] ?? '';
      final res = await LandingPageApi.wStartupDetail(startup);
      if (isClosed) return;
      if (res.isSuccess && res.r != null) {
        startupDetailModel(res.r);
        final detail = res.r!;
        Analytics.primaryDetailView(
          companyId: detail.id,
          companySlug: detail.urlSlug,
          brandName: detail.brandName,
        );
      } else {
        loadError('We couldn’t load this startup. Please try again.');
      }
    } catch (_) {
      if (!isClosed) {
        loadError('We couldn’t load this startup. Please try again.');
      }
    } finally {
      if (!isClosed) isLoading(false);
    }
  }

  Future<void> startInvestment() async {
    if (!canInvest || isOpeningInvestment.value) return;
    isOpeningInvestment(true);
    final detailRoute = Get.currentRoute;
    final startupId = model.id;
    final roundId = model.raisingRound.id;
    try {
      final investor = await showCustomDialog(const InvestorListDialog());
      if (!canInvest ||
          investor is! InvestorModel ||
          investor.id <= 0 ||
          investor.uuid.isEmpty ||
          !investor.isPreIpoKycComplete ||
          model.id != startupId ||
          model.raisingRound.id != roundId) {
        return;
      }
      final result = await Get.toNamed(
        Routes.primaryInvestmentPath(detailRoute, investor.uuid),
      );
      if (!isClosed && result == true) await getData();
    } finally {
      if (!isClosed) isOpeningInvestment(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    getData();
  }
}
