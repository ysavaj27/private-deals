import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

class PrimaryInvestmentPageCtrl extends GetxController {
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;
  int investorID = 0;
  Rxn<String> paymentMode = Rxn<String>();

  // Rx<PrimaryInvestmentType> type = PrimaryInvestmentType.Captable.obs;

  // bool get isCaptable => type() == PrimaryInvestmentType.Captable;
  RxBool isSelected = false.obs;
  Rx<StartupModel> model = StartupModel.fromJson({}).obs;
  Rx<PrimaryTransactionModel> transaction =
      PrimaryTransactionModel.fromJson({}).obs;
  RxBool isMixedAmount = false.obs;
  RxBool investing = false.obs;
  RxBool alreadyInvested = false.obs;
  RxBool isLoading = false.obs;
  RxDouble minAmount = 0.0.obs;
  RxDouble maxAmount = 0.0.obs;
  RxDouble totalShare = 0.0.obs;
  RxDouble enterPrice = 0.0.obs;
  double gst = 0;
  double fees = 0;
  RxDouble investedAmount = 0.0.obs;
  TextEditingController amountCTRL = TextEditingController();
  TextEditingController aifAmountCTRL = TextEditingController();
  AnimationStyle? animationStyle;

  GlobalKey<FormState> captableDesktopKey = GlobalKey<FormState>();
  GlobalKey<FormState> aifDesktopKey = GlobalKey<FormState>();
  GlobalKey<FormState> captablePhoneKey = GlobalKey<FormState>();
  GlobalKey<FormState> aifPhoneKey = GlobalKey<FormState>();

  Future<void> getData() async {
    final startup = Get.parameters['slug'] ?? "";
    final user = Get.parameters['id'] ?? "";
    logger.t('startup : $startup user:$user');
    if (startup.isNotEmpty && user.isNotEmpty) {
      investorID = int.tryParse(user) ?? 0;
      await getStartUp(startup);
      await getInvestor(user);
      findTransaction();
    }
    if (user.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onBackLogic(Get.context!, false);
      });
    }
  }

  Future<void> getStartUp(String startup) async {
    var res = await LandingPageApi.wStartupDetail(startup);
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      model(res.r);
    } else {
      toast(res.m);
    }
  }

  Future<void> getInvestor(String uuid) async {
    var res = await WInvestorsApi.getInvestor(uuid: uuid);
    isLoading(false);
    if (res.isSuccess && res.r != null) {
      investor(res.r);
    } else {
      toast(res.m);
    }
  }

  void clearData() {
    amountCTRL.clear();
    paymentMode(null);
    isSelected(false);
    totalShare(0);
    enterPrice(0);
    gst = 0;
    fees = 0;
  }

  Future<void> findTransaction() async {
    isLoading(true);
    var res = await InvestorPrimaryTransactionApi.wealthManagerTransaction(
      startupId: model().id,
      roundId: model().raisingRound.id,
      investorId: investorID,
    );
    if (res.isSuccess && res.r != null && res.r!.isNotEmpty) {
      transaction(res.r);
      totalShare(transaction().shares.toDouble());
      investedAmount(transaction().investmentAmount);
      alreadyInvested(true);
    }
    isLoading(false);
  }

  void findShares(double price) {
    totalShare.value =
        price.calculateShares(model().raisingRound.sharePrice).toDouble();
  }

  void onChangeForCapTable(String? p0) {
    if (p0 == null || double.tryParse(p0) == null) return;
    isMixedAmount(false);
    var price = double.parse(p0);
    investedAmount(price);
    var sharePrice = model().raisingRound.sharePrice.toDouble();
    if (price > model().raisingRound.minimumInvestment) {
      if (!price.isPerfectSharePrice(sharePrice)) {
        isMixedAmount(true);
        maxAmount.value = price.nearestAboveSharePrice(sharePrice);
        minAmount.value = price.nearestBelowSharePrice(sharePrice);
      }
    }
    findShares(price);
  }

  // void onChangeForAIF(String? p0) {
  //   if (p0 == null || double.tryParse(p0) == null) return;
  //   var price = double.parse(p0);
  //   enterPrice(price);
  //   investedAmount(enterPrice().aifFinalPrice);
  //   gst = enterPrice().aifGST;
  //   fees = enterPrice().aifManagementFees;
  //   totalShare.value = (investedAmount() / 1000).formatUnit();
  // }

  Future<void> onPress() async {
    investing(true);
    var res = await InvestorPrimaryTransactionApi.wealthManagerInvestment(
      startupId: model().id,
      roundId: model().raisingRound.id,
      instrument: model().raisingRound.instrument,
      shares: totalShare(),
      sharesPrice:
          // type() == PrimaryInvestmentType.Captable
          //     ?
          model().raisingRound.sharePrice,
      // : 1000,
      investedAmount: investedAmount(),
      investorId: investorID,
      paymentMode: paymentMode()!,
      // type: type(),
      type: PrimaryInvestmentType.Captable,
      fees: fees,
      gst: gst,
    );

    investing(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
      alreadyInvested(true);
      transaction(res.r);
    } else {
      toast(res.m, MessageEnum.alert);
    }
  }

  @override
  void onInit() {
    getData();
    animationStyle = AnimationStyle(
      duration: const Duration(seconds: 2),
      reverseDuration: const Duration(seconds: 1),
    );
    super.onInit();
  }
}
