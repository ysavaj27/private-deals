// enquiry_dialog_ctrl.dart
import 'package:private_deals/src/shared/app_exports.dart';

class EnquiryDialogCtrl extends GetxController {
  late final String slug;

  // Optional: seed with an existing share/model if this dialog is opened
  // from a holdings/watchlist row, similar to SecondaryTransactionDialogCtrl.
  // final YourShareModel model;
  EnquiryDialogCtrl({required this.slug});

  final formKey = GlobalKey<FormState>();

  final Rx<InvestmentTypeEnum> enquiryType = InvestmentTypeEnum.buy.obs;
  final settlementDays = RxnInt();

  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController offerPriceCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  final RxString quantityError = "".obs;
  final RxString offerPriceError = "".obs;
  final RxString settlementError = "".obs;

  final RxBool isLoading = false.obs;

  bool get requiresSettlement => enquiryType.value == InvestmentTypeEnum.sell;

  static const int _notesMaxLength = 2000;

  @override
  void onClose() {
    quantityCtrl.dispose();
    offerPriceCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  void selectEnquiryType(InvestmentTypeEnum type) {
    enquiryType(type);
    settlementError('');
    if (type != InvestmentTypeEnum.sell) {
      settlementDays.value = null;
    }
  }

  /// Returns true and clears errors if valid; otherwise sets error strings.
  bool _validate() {
    bool isValid = true;

    final qty = int.tryParse(quantityCtrl.text.trim());
    if (qty == null || qty < 1) {
      quantityError("Quantity must be at least 1");
      isValid = false;
    } else {
      quantityError("");
    }

    final price = double.tryParse(offerPriceCtrl.text.trim());
    if (price == null || !price.isFinite || price < 0.01) {
      offerPriceError("Offer price must be greater than 0");
      isValid = false;
    } else {
      offerPriceError("");
    }

    if (requiresSettlement) {
      final allowed = app.config.settlementDays.map((e) => e.value).toSet();
      final cycle = settlementDays.value;
      if (cycle == null || !allowed.contains(cycle)) {
        settlementError('Select a settlement cycle');
        isValid = false;
      } else {
        settlementError('');
      }
    } else {
      settlementError('');
    }

    if (notesCtrl.text.length > _notesMaxLength) {
      isValid = false; // guarded by maxLength on the field too
    }

    return isValid;
  }

  Future<void> onPress() async {
    if (isLoading.value || !_validate()) return;
    isLoading(true);
    var res = await WPreIpoTransactionApi.inquiry(
      type: enquiryType.value,
      companySlug: slug,
      quantity: int.parse(quantityCtrl.text.trim()),
      offerPrice: double.parse(offerPriceCtrl.text.trim()),
      notes: notesCtrl.text,
      settlementDays: requiresSettlement ? settlementDays.value : null,
    );    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
