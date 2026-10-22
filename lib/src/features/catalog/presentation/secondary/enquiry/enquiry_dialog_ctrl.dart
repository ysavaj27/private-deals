import 'package:private_deals/src/shared/app_exports.dart';

class EnquiryDialogCtrl extends GetxController {
  final String slug;
  final VoidCallback onCreated;
  final int _sessionRevision = app.revision;
  bool _submitted = false;

  EnquiryDialogCtrl({required this.slug, required this.onCreated});

  final Rx<InvestmentTypeEnum> enquiryType = InvestmentTypeEnum.buy.obs;
  final settlementDays = RxnInt();

  final TextEditingController quantityCtrl = TextEditingController();
  final TextEditingController offerPriceCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  final RxString quantityError = "".obs;
  final RxString offerPriceError = "".obs;
  final RxString settlementError = "".obs;
  final RxString notesError = "".obs;

  final RxBool isLoading = false.obs;

  bool get requiresSettlement => true;

  static const int _notesMaxLength = 2000;

  @override
  void onClose() {
    quantityCtrl.dispose();
    offerPriceCtrl.dispose();
    notesCtrl.dispose();
    super.onClose();
  }

  void selectEnquiryType(InvestmentTypeEnum type) {
    if (isClosed || isLoading.value || _submitted) return;
    enquiryType(type);
    settlementError('');
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

    if (notesCtrl.text.trim().characters.length > _notesMaxLength) {
      notesError('Notes must be $_notesMaxLength characters or fewer');
      isValid = false;
    } else {
      notesError('');
    }

    return isValid;
  }

  Future<void> onPress() async {
    if (isClosed ||
        _submitted ||
        isLoading.value ||
        _sessionRevision != app.revision ||
        !_validate()) {
      return;
    }
    isLoading(true);
    var res = await WPreIpoTransactionApi.inquiry(
      type: enquiryType.value,
      companySlug: slug,
      quantity: int.parse(quantityCtrl.text.trim()),
      offerPrice: double.parse(offerPriceCtrl.text.trim()),
      notes: notesCtrl.text.trim(),
      settlementDays: settlementDays.value,
    );
    if (isClosed) return;
    isLoading(false);
    if (_sessionRevision != app.revision) return;
    if (res.isSuccess) {
      // The state owns the route. A completed request must never pop whichever
      // unrelated screen or dialog happens to be at the top of the navigator.
      _submitted = true;
      onCreated();
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }
}
