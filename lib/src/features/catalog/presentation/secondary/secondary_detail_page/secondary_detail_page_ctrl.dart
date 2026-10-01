import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/select_investor_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class SecondaryDetailPageCtrl extends GetxController{
  RxBool isLoading = false.obs;
  RxBool isBuying = false.obs;
  RxBool isVisible = false.obs;
  RxBool isExpanded = false.obs;
  // RxBool isButtonClicked = false.obs;
  Rx<CompanyModel> model = CompanyModel.fromJson({}).obs;
  Rx<InvestmentTypeEnum> type = InvestmentTypeEnum.none.obs;
  final GlobalKey<FormState> desktopKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneKey = GlobalKey<FormState>();
  // final TextEditingController qtyCTRL = TextEditingController();
  RxInt qty = 0.obs;
  RxInt financialTab = 1.obs;
  RxInt shareHoldingTab = 0.obs;
  RxInt tab = 0.obs;
  ScrollController scrollController = ScrollController();
  List<GlobalKey> sectionKeys = [];

  Future<void> getData() async {
    final slug = Get.parameters['slug'] ?? "";
    isLoading(true);
    var res = await PreIpoLandingPageApi.wCompanyDetail(slug);
    isLoading(false);
    if (res.isSuccess) {
      model(res.r);
      minTicketSize = model().minInvestment;
      if (model().minInvestmentType ==
          app.config.enumValues.minInvestmentType.amount) {
        isQty(false);
      } else {
        isQty(true);
      }
      // if (model().transaction.id.isNotEmpty) {
      //   qtyCTRL.text = model().transaction.shares.toString();
      // }
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  void updateScrollPosition() {
    sectionKeys = List.generate(7, (index) => GlobalKey());
    scrollController.addListener(() {
      // if (_isButtonClicked) return; // Ignore if scroll was triggered by a button click
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (currentScroll >= 200) {
        isVisible(true);
      } else {
        isVisible(false);
      }

      for (int i = 0; i < sectionKeys.length; i++) {
        final RenderBox? box =
        sectionKeys[i].currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final position = box.localToGlobal(Offset.zero).dy;
          if (position >= 0 && position < 200) {
            tab(i);
          }
          if (currentScroll == maxScroll) {
            tab(6);
          }
        }
      }
    });
  }

  // Scroll to the section corresponding to the clicked button
  void scrollToSection(int index) {
    tab(index);
    // isButtonClicked(true);
    final RenderBox box =
    sectionKeys[index].currentContext!.findRenderObject() as RenderBox;
    final position =
        box.localToGlobal(Offset.zero).dy + scrollController.offset - 100;
    scrollController
        .animateTo(
      position,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    )
        .then((_) {
      // isButtonClicked(false);
    });
  }

  Future<void> onPress() async {
    investing(true);
    var res = await WPreIpoTransactionApi.buy(
      list: investorList,
      companyId: model().id,
      distributorPrice: model().distributerPrice,
    );
    investing(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
      investorList.clear();
    } else {
      toast(res.m, MessageEnum.alert);
    }
  }

  @override
  void onInit() {
    getData();
    updateScrollPosition();
    super.onInit();
  }

  /// investment variable
  Rxn<String> paymentMode = Rxn<String>();
  RxBool isSelected = false.obs;
  Rx<CompanyModel> transaction = CompanyModel.fromJson({}).obs;
  Rx<InvestorModel> investor = InvestorModel.fromJson({}).obs;
  RxBool isMixedAmount = false.obs;
  RxBool investing = false.obs;
  RxBool alreadyInvested = false.obs;
  RxBool isInvesting = false.obs;
  RxDouble minAmount = 0.0.obs;
  RxDouble maxAmount = 0.0.obs;
  RxInt totalShare = 0.obs;
  RxDouble investedAmount = 0.0.obs;
  double minTicketSize = 100000;
  TextEditingController amountCTRL = TextEditingController();
  RxList<SelectInvestorModel> investorList = <SelectInvestorModel>[].obs;
  RxBool isQty = true.obs;

  GlobalKey<FormState> desktopFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  void setData() {
    minTicketSize = model().minInvestment;
    if (model().minInvestmentType ==
        app.config.enumValues.minInvestmentType.amount) {
      isQty(false);
    } else {
      isQty(true);
    }
  }

  void addInvestor() async {
    var res = await showCustomDialog(const SelectInvestorDialog());
    investorList.clear();
    if (res != null && res is List<InvestorModel>) {
      for (var i = 0; i < res.length; i++) {
        var e = res[i];
        var data = investorList.firstWhereOrNull((a) => e.id == a.investorId);
        if (data == null) {
          investorList.add(
            SelectInvestorModel(
              investorId: e.id,
              investorName: e.name,
              isMarket: true,
              price: model().sharePrice,
              priceCTRL: TextEditingController(
                  text: model().sharePrice.toString()),
              quantityCTRL: TextEditingController(),
            ),
          );
        }
      }
    }
  }

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

  Future<void> onInvest() async {
    investing(true);
    var res = await WPreIpoTransactionApi.buy(
      list: investorList,
      companyId: model().id,
      distributorPrice: model().distributerPrice,
    );
    investing(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
      transaction(res.r);
    } else {
      toast(res.m, MessageEnum.alert);
    }
  }
}