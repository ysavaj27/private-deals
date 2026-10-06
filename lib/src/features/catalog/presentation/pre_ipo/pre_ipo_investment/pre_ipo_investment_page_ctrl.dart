import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/pre_ipo_offer.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/select_investor_dialog.dart';

class PreIPOInvestmentPageCtrl extends GetxController {
  final selectedOffer = Rxn<PreIPOOffer>();
  double get purchasePrice =>
      selectedOffer.value?.price ?? model().distributerPrice;
  double get sharePrice => selectedOffer.value?.price ?? model().sharePrice;
  Rxn<String> paymentMode = Rxn<String>();
  RxBool isSelected = false.obs;
  Rx<CompanyModel> model = CompanyModel.fromJson({}).obs;
  Rx<CompanyModel> transaction = CompanyModel.fromJson({}).obs;
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;
  RxBool isMixedAmount = false.obs;
  RxBool investing = false.obs;
  RxBool alreadyInvested = false.obs;
  RxBool isLoading = false.obs;
  RxDouble minAmount = 0.0.obs;
  RxDouble maxAmount = 0.0.obs;
  RxInt totalShare = 0.obs;
  RxDouble investedAmount = 0.0.obs;
  double minTicketSize = 100000;
  TextEditingController amountCTRL = TextEditingController();
  RxList<SelectInvestorModel> investorList = <SelectInvestorModel>[].obs;
  RxBool isQty = true.obs;

  GlobalKey<FormState> desktopKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneKey = GlobalKey<FormState>();

  void getData() {
    var data = Get.arguments;
    if (data is PreIPOInvestmentSelection) {
      selectedOffer.value = data.offer;
      model(data.company);
      minTicketSize = data.offer.minimumQty.toDouble();
      isQty(true);
      return;
    }
    if (data != null && data is CompanyModel) {
      model(data);
      minTicketSize = model().minInvestment;
      if (model().minInvestmentType ==
          app.config.enumValues.minInvestmentType.amount) {
        isQty(false);
      } else {
        isQty(true);
      }
    }
  }

  void addInvestor() async {
    var res = await showCustomDialog(const SelectInvestorDialog());
    if (res != null && res is List<InvestorModel>) {
      for (var i = 0; i < res.length; i++) {
        var e = res[i];
        var data = investorList.firstWhereOrNull((a) => e.id == a.investorId);
        if (data == null) {
          investorList.add(
            SelectInvestorModel(
              investorId: e.id,
              investorName: e.displayName,
              isSelf: e.isSelf,
              isMarket: true,
              price: sharePrice,
              priceCTRL: TextEditingController(text: sharePrice.toString()),
              quantityCTRL: TextEditingController(),
            ),
          );
        }
      }
    }
  }

  // Future<void> findTransaction() async {
  //   isLoading(true);
  //   var res = await InvestorPrimaryTransactionApi.transaction(
  //       startupId: model().id, roundId: model().lastRoundModel.id);
  //   if (res.isSuccess && res.r != null && res.r!.isNotEmpty) {
  //     transaction(res.r);
  //     totalShare(transaction().shares);
  //     investedAmount(transaction().investmentAmount);
  //     alreadyInvested(true);
  //   }
  //   isLoading(false);
  // }

  findShares(double price) {
    totalShare.value = price.calculateShares(model().sharePrice);
  }

  void onChange(String? p0) {
    if (p0 == null || double.tryParse(p0) == null) return;
    isMixedAmount(false);
    var price = double.parse(p0);
    investedAmount(price);
    var sharePrice = model().sharePrice;
    if (price > minTicketSize) {
      if (!price.isPerfectSharePrice(sharePrice)) {
        isMixedAmount(true);
        maxAmount.value = price.nearestAboveSharePrice(sharePrice);
        minAmount.value = price.nearestBelowSharePrice(sharePrice);
      }
    }
    findShares(price);
  }

  Future<void> onPress() async {
    if (investing.value || investorList.isEmpty) return;
    final offer = selectedOffer.value;
    if (offer == null || !offer.canBuy) {
      toast(
        offer?.buyBlockedReason ??
            'Please select an available Institution sell deal',
        MessageEnum.alert,
      );
      return;
    }
    for (final investor in investorList) {
      final error = offer.validateQuantity(investor.quantityCTRL?.text) ??
          offer.validatePrice(investor.priceCTRL?.text);
      if (error != null) {
        toast(error, MessageEnum.alert);
        return;
      }
    }
    investing(true);
    var res = await WPreIpoTransactionApi.buy(
      list: investorList,
      dealId: offer.dealId,
      dealUuid: offer.dealUuid,
    );
    investing(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.alert);
    }
  }

  @override
  void onReady() {
    addInvestor();
    super.onReady();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
