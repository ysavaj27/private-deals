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

  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController offerPriceCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  final Rx<OfferValidTillOption> validTillOption =
      OfferValidTillOption.today.obs;
  final Rx<DateTime?> customValidTillDate = Rx<DateTime?>(null);

  final RxString quantityError = "".obs;
  final RxString offerPriceError = "".obs;
  final RxString validTillError = "".obs;

  final RxBool isLoading = false.obs;

  static const int _notesMaxLength = 2000;

  @override
  void onClose() {
    quantityCtrl.dispose();
    offerPriceCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  void selectEnquiryType(InvestmentTypeEnum type) => enquiryType(type);

  void selectValidTillOption(OfferValidTillOption option) {
    validTillOption(option);
    validTillError("");
    if (option == OfferValidTillOption.custom) {
      _pickCustomDate();
    }
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: customValidTillDate.value ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      customValidTillDate(picked);
    } else if (customValidTillDate.value == null) {
      // No date chosen yet — fall back so the field isn't left dangling
      validTillOption(OfferValidTillOption.today);
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
    if (price == null || price < 0.01) {
      offerPriceError("Offer price must be greater than 0");
      isValid = false;
    } else {
      offerPriceError("");
    }

    if (validTillOption.value == OfferValidTillOption.custom &&
        customValidTillDate.value == null) {
      validTillError("Please pick a date");
      isValid = false;
    } else {
      validTillError("");
    }

    if (notesCtrl.text.length > _notesMaxLength) {
      isValid = false; // guarded by maxLength on the field too
    }

    return isValid;
  }

  Future<void> oness() async {
    final model = EnquiryRequestModel(
      enquiryType: enquiryType.value,
      quantity: int.parse(quantityCtrl.text.trim()),
      offerPrice: double.parse(offerPriceCtrl.text.trim()),
      offerValidTill: validTillOption.value.resolveDate(
        customDate: customValidTillDate.value,
      ),
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
    );

    try {
      isLoading(true);
      // await YourRepo.submitEnquiry(model.toJson());
      Get.back(result: model);
    } finally {
      isLoading(false);
    }
  }

  Future<void> onPress() async {
    if (!_validate()) return;
    isLoading(true);
    var res = await WPreIpoTransactionApi.inquiry(
      type: enquiryType.value,
      companySlug: slug,
      quantity: int.parse(quantityCtrl.text.trim()),
      offerPrice: double.parse(offerPriceCtrl.text.trim()),
      offerValidTill: validTillOption.value
          .resolveDate(customDate: customValidTillDate.value),
      notes: notesCtrl.text,
    );
    isLoading(false);
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
