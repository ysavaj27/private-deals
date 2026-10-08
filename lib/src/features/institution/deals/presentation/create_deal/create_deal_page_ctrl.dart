import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/lite_company_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/features/institution/deals/presentation/deal_list/deal_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

// Add your API, model, and toast imports.

class CreateDealPageCtrl extends GetxController {
  late final DealRouteContext dealRoute;

  CompanyType get companyType => dealRoute.type;
  bool get isHotDeal => dealRoute.isHotDeal;

  String get pageTitle => companyType == CompanyType.unlisted
      ? 'Create Unlisted deal'
      : 'Create LP Secondary deal';

  final formKey = GlobalKey<FormState>();
  final availableQuantityCtrl = TextEditingController();
  final sharePriceCtrl = TextEditingController();
  final minimumQuantityCtrl = TextEditingController();

  final companies = <LiteCompanyModel>[].obs;
  final selectedCompany = Rxn<LiteCompanyModel>();
  final companiesLoading = false.obs;
  final companiesError = ''.obs;

  final saving = false.obs;
  final dealType = 'sell'.obs;
  final settlementDays = RxnInt();
  final settlementError = ''.obs;

  final expiryDate = Rxn<DateTime>();
  final expiryTime = Rxn<TimeOfDay>();
  final expiryError = ''.obs;

  static const istOffset = Duration(hours: 5, minutes: 30);

  bool get isBuyDeal => dealType.value == 'buy';

  // Read isBuyDeal first so Obx always tracks dealType (avoids GetX error on LP Secondary).
  bool get requiresSettlement =>
      !isBuyDeal && companyType == CompanyType.unlisted;

  String get availableQuantityLabel =>
      isBuyDeal ? 'Required total quantity' : 'Available total quantity';

  String get sharePriceLabel => 'Base price (₹) *';

  String get minimumQuantityLabel => 'Minimum quantity *';

  @override
  void onInit() {
    super.onInit();
    dealRoute = DealRouteContext.fromPath(Get.currentRoute);
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    if (companiesLoading.value) return;

    companiesLoading.value = true;
    companiesError.value = '';

    try {
      final res = await CompanyApi.getCompanyListLite(type: companyType);
      if (isClosed) return;

      logger.d("Company List :${res.r?.length}");
      if (res.isSuccess) {
        companies.assignAll(res.r ?? <LiteCompanyModel>[]);

        if (companies.isEmpty) {
          companiesError.value = 'No companies are available.';
        }
      } else {
        companiesError.value = 'Unable to load companies. Please retry.';
      }
    } catch (_) {
      if (!isClosed) {
        companiesError.value = 'Unable to load companies. Please retry.';
      }
    } finally {
      if (!isClosed) companiesLoading.value = false;
    }
  }

  String? validateQuantity(String? raw) {
    final value = raw?.trim() ?? '';

    if (value.isEmpty) return 'Total quantity is required';

    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Enter a whole number greater than zero';
    }

    return null;
  }

  String? validateMinimumQuantity(String? raw) {
    final value = raw?.trim() ?? '';

    if (value.isEmpty) return 'Minimum quantity is required';

    final minimum = int.tryParse(value);
    if (minimum == null || minimum <= 0) {
      return 'Enter a whole number greater than zero';
    }

    final available = int.tryParse(availableQuantityCtrl.text.trim());

    if (available != null && minimum > available) {
      return isBuyDeal
          ? 'Cannot exceed required quantity'
          : 'Cannot exceed available quantity';
    }

    return null;
  }

  String? validatePrice(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return isBuyDeal ? 'Offer price is required' : 'Share price is required';
    }

    final price = num.tryParse(value);
    if (price == null || !price.isFinite || price <= 0) {
      return 'Enter a price greater than zero';
    }

    return null;
  }

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  String get expiryDateLabel {
    final date = expiryDate.value;
    if (date == null) return 'Select date';

    return '${twoDigits(date.day)}/'
        '${twoDigits(date.month)}/${date.year}';
  }

  String get expiryTimeLabel {
    final time = expiryTime.value;
    if (time == null) return 'Select time';

    return '${twoDigits(time.hour)}:${twoDigits(time.minute)} IST';
  }

  Future<void> pickExpiryDate(BuildContext context) async {
    final nowIST = DateTime.now().toUtc().add(istOffset);
    final today = DateTime(nowIST.year, nowIST.month, nowIST.day);
    final selected = expiryDate.value;

    final result = await showDatePicker(
      context: context,
      initialDate: selected != null && !selected.isBefore(today)
          ? selected
          : today,
      firstDate: today,
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Select expiry date · IST',
    );

    if (result == null || isClosed) return;

    expiryDate.value = result;
    expiryError.value = '';
  }

  Future<void> pickExpiryTime(BuildContext context) async {
    final nowIST = DateTime.now().toUtc().add(istOffset);

    final result = await showTimePicker(
      context: context,
      initialTime:
          expiryTime.value ??
          TimeOfDay(hour: nowIST.hour, minute: nowIST.minute),
      helpText: 'Select expiry time · IST',
    );

    if (result == null || isClosed) return;

    expiryTime.value = result;
    expiryError.value = '';
  }

  void clearExpiry() {
    expiryDate.value = null;
    expiryTime.value = null;
    expiryError.value = '';
  }

  bool validateExpiry() {
    final date = expiryDate.value;
    final time = expiryTime.value;

    expiryError.value = '';

    if (date == null && time == null) return true;

    if (date == null || time == null) {
      expiryError.value = 'Select both an expiry date and time.';
      return false;
    }

    final expiryUTC = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).subtract(istOffset);

    if (!expiryUTC.isAfter(DateTime.now().toUtc())) {
      expiryError.value = 'Expiry must be in the future.';
      return false;
    }

    return true;
  }

  String? get formattedExpiry {
    final date = expiryDate.value;
    final time = expiryTime.value;

    if (date == null || time == null) return null;

    return '${date.year}-${twoDigits(date.month)}-'
        '${twoDigits(date.day)} '
        '${twoDigits(time.hour)}:${twoDigits(time.minute)}:00';
  }

  bool validateSettlement() {
    settlementError.value = '';
    if (!requiresSettlement) return true;
    final value = settlementDays.value;
    final allowed = app.config.settlementDays.map((e) => e.value).toSet();
    if (value == null || !allowed.contains(value)) {
      settlementError.value = 'Select a settlement cycle';
      return false;
    }
    return true;
  }

  Map<String, dynamic> buildPayload() {
    return {
      'company_id': selectedCompany.value!.id,
      'deal_type': dealType.value,
      'available_quantity': int.parse(availableQuantityCtrl.text.trim()),
      'share_price': num.parse(sharePriceCtrl.text.trim()),
      'minimum_qty': int.parse(minimumQuantityCtrl.text.trim()),
      'is_hot_deal': isHotDeal ? 1 : 0,
      if (requiresSettlement) 'settlement_days': settlementDays.value,
      if (formattedExpiry != null) 'expired_at': formattedExpiry,
    };
  }

  Future<void> submit() async {
    if (saving.value) return;

    final formValid = formKey.currentState?.validate() ?? false;
    final expiryValid = validateExpiry();
    final settlementValid = validateSettlement();

    if (!formValid || !expiryValid || !settlementValid) return;

    saving.value = true;

    try {
      final res = await DealApi.createDeal(buildPayload());

      if (isClosed) return;

      if (res.isSuccess) {
        Get.back(result: true);
        toast(res.m, MessageEnum.success);
      } else {
        toast(res.m, MessageEnum.error);
      }
    } catch (_) {
      if (!isClosed) {
        toast('Unable to create deal. Please try again.', MessageEnum.error);
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    availableQuantityCtrl.dispose();
    sharePriceCtrl.dispose();
    minimumQuantityCtrl.dispose();
    super.onClose();
  }
}
