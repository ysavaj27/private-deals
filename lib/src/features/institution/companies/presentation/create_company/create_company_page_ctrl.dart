import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

// Add your API, model, and enum imports.

enum DuplicateState { idle, checking, clear, duplicate, failed }

class CompanyField {
  const CompanyField(
    this.key,
    this.label, {
    this.hint,
    this.required = true,
    this.numeric = false,
    this.min,
    this.max,
    this.maxLength,
    this.exactLength,
    this.lines = 1,
    this.initial = '',
  });

  final String key;
  final String label;
  final String? hint;
  final bool required;
  final bool numeric;
  final double? min;
  final double? max;
  final int? maxLength;
  final int? exactLength;
  final int lines;
  final String initial;
}

class CreateCompanyCtrl extends GetxController {
  static const identityFields = [
    CompanyField('cin', 'CIN', hint: 'e.g. U12345MH2020PTC123456'),
    CompanyField('brand_name', 'Brand name', hint: 'e.g. Acme', maxLength: 255),
    CompanyField(
      'company_name',
      'Legal company name',
      hint: 'e.g. Acme Private Limited',
      maxLength: 255,
    ),
    CompanyField(
      'about',
      'About company',
      hint: 'Describe the company, its business, and key products or services',
      lines: 4,
    ),
  ];

  static const financialFields = [
    CompanyField(
      'min_investment_amount',
      'Minimum investment amount (₹)',
      hint: 'e.g. 35000',
      numeric: true,
      min: 0,
    ),
    CompanyField('lot_size', 'Lot size', hint: 'e.g. 100'),
    CompanyField(
      'market_cap',
      'Market cap (Cr)',
      hint: 'e.g. 10 for ₹10 crore',
      numeric: true,
      min: 0,
    ),
    CompanyField('pe_ratio', 'PE ratio', hint: 'e.g. 25.5', numeric: true),
    CompanyField('pb_ratio', 'PB ratio', hint: 'e.g. 3.2', numeric: true),
    CompanyField(
      'debt_to_equity',
      'Debt to equity',
      hint: 'e.g. 0.45',
      numeric: true,
      min: 0,
    ),
    CompanyField('roe', 'ROE (%)', hint: 'e.g. 18.5', numeric: true),
    CompanyField(
      'book_value',
      'Book value (₹)',
      hint: 'e.g. 120',
      numeric: true,
      min: 0,
    ),
    CompanyField(
      'face_value',
      'Face value (₹)',
      hint: 'e.g. 10',
      numeric: true,
      min: 0,
    ),
  ];

  static const additionalFields = [
    CompanyField(
      'alternative_names',
      'Alternative names',
      hint: 'e.g. Acme, Acme Ltd',
      required: false,
    ),
    CompanyField('list_order', 'List order', hint: 'e.g. 10', required: false),
    CompanyField(
      'depository',
      'Depository',
      hint: 'e.g. NSDL or CDSL',
      required: false,
    ),
    CompanyField(
      'pan_number',
      'PAN number',
      hint: 'e.g. ABCDE1234F',
      required: false,
      exactLength: 10,
    ),
    CompanyField(
      'isin_number',
      'ISIN number',
      hint: 'e.g. INE123A01016',
      required: false,
      exactLength: 12,
    ),
    CompanyField(
      'rta',
      'RTA',
      hint: 'Enter the registrar and transfer agent',
      required: false,
    ),
    CompanyField(
      'total_shares',
      'Total shares',
      hint: 'e.g. 1000000',
      required: false,
      numeric: true,
      min: 0,
    ),
  ];

  ///LOGO realted variable
  final logo = Rxn<MediaModel>();
  final pickingLogo = false.obs;
  final logoError = ''.obs;

  static const maxLogoBytes = 2 * 1024 * 1024;

  bool get hasValidLogo {
    final bytes = logo.value?.uint8list;

    return bytes != null &&
        bytes.isNotEmpty &&
        bytes.lengthInBytes <= maxLogoBytes;
  }

  final formKey = GlobalKey<FormState>();

  final fields = <String, TextEditingController>{};

  final sectors = <SectorModel>[].obs;
  final sectorId = Rxn<int>();
  final category = Rxn<UnListedShareCategoryEnum>();

  // final type = CompanyType.unlisted.obs;
  late final CompanyRouteContext companyRoute;

  CompanyType get companyType => companyRoute.type;

  String get pageTitle => companyType == CompanyType.unlisted
      ? 'Create Pre-IPO company'
      : 'Create LP Secondary company';

  final sectorsLoading = false.obs;
  final sectorsError = ''.obs;
  final saving = false.obs;
  final submitError = ''.obs;

  final duplicateState = DuplicateState.idle.obs;
  final duplicateMatches = <String>[].obs;

  Timer? _duplicateTimer;
  int _duplicateRequestId = 0;
  String? _checkedIdentity;

  List<CompanyField> get allFields => [
    ...identityFields,
    ...financialFields,
    ...additionalFields,
  ];

  String text(String key) => fields[key]!.text.trim();

  String get identityKey => [
    companyType.value,
    text('cin').toUpperCase(),
    text('company_name'),
  ].join('\u0000');

  bool get canSave =>
      !saving.value &&
      !pickingLogo.value &&
      (logo.value == null || hasValidLogo) &&
      !sectorsLoading.value &&
      sectorId.value != null &&
      duplicateState.value == DuplicateState.clear &&
      _checkedIdentity == identityKey;

  @override
  void onInit() {
    super.onInit();

    companyRoute = CompanyRouteContext.fromPath(Get.currentRoute);

    for (final field in allFields) {
      fields[field.key] = TextEditingController(text: field.initial);
    }

    fields['cin']!.addListener(scheduleDuplicateCheck);
    fields['company_name']!.addListener(scheduleDuplicateCheck);

    fetchSectors();
  }

  Future<void> fetchSectors() async {
    if (sectorsLoading.value) return;

    sectorsLoading.value = true;
    sectorsError.value = '';

    try {
      final result = await CompanyApi.getSectorList();
      if (isClosed) return;
      if (result.isSuccess) {
        sectors.assignAll(result.r ?? []);
      } else {
        sectorsError.value = result.m.isEmpty
            ? 'Unable to load sectors.'
            : result.m;
      }
    } catch (_) {
      if (!isClosed) {
        sectorsError.value = 'Unable to load sectors.';
      }
    } finally {
      if (!isClosed) sectorsLoading.value = false;
    }
  }

  // void changeType(CompanyType? value) {
  //   if (value == null || value == type.value) return;
  //   type.value = value;
  //   scheduleDuplicateCheck();
  // }

  void scheduleDuplicateCheck() {
    _duplicateTimer?.cancel();
    _duplicateRequestId++;
    _checkedIdentity = null;
    duplicateMatches.clear();

    if (text('cin').isEmpty && text('company_name').isEmpty) {
      duplicateState.value = DuplicateState.idle;
      return;
    }

    duplicateState.value = DuplicateState.checking;

    _duplicateTimer = Timer(const Duration(milliseconds: 500), checkDuplicate);
  }

  Future<void> checkDuplicate() async {
    _duplicateTimer?.cancel();

    if (text('cin').isEmpty && text('company_name').isEmpty) {
      duplicateState.value = DuplicateState.idle;
      return;
    }

    final requestId = ++_duplicateRequestId;
    final requestedIdentity = identityKey;

    duplicateState.value = DuplicateState.checking;
    _checkedIdentity = null;

    try {
      final result = await CompanyApi.checkDuplicate(
        cin: text('cin').toUpperCase(),
        companyName: text('company_name'),
        type: companyType.value,
      );

      if (result.isSuccess) {
        if (isClosed ||
            requestId != _duplicateRequestId ||
            requestedIdentity != identityKey) {
          return;
        }

        _checkedIdentity = requestedIdentity;
        duplicateMatches.assignAll(result.r?.matches ?? []);
        duplicateState.value = result.r?.isDuplicate ?? false
            ? DuplicateState.duplicate
            : DuplicateState.clear;
      } else if (!isClosed && requestId == _duplicateRequestId) {
        duplicateState.value = DuplicateState.failed;
      }
    } catch (_) {
      if (!isClosed && requestId == _duplicateRequestId) {
        duplicateState.value = DuplicateState.failed;
      }
    }
  }

  Future<void> pickLogo() async {
    if (pickingLogo.value || saving.value) return;

    pickingLogo.value = true;
    logoError.value = '';

    try {
      // Uses the FilePickers.pickLogo() returning MediaModel.
      final selected = await FilePickers().pickLogo();

      // Cancelling preserves the previous selection.
      if (selected == null || isClosed) return;

      final bytes = selected.uint8list;

      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('The selected image is empty.');
      }

      if (bytes.lengthInBytes > maxLogoBytes) {
        throw const FormatException('Logo must be 2 MB or smaller.');
      }

      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 128);

      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }

      if (isClosed) return;

      logo.value = selected;
    } on FormatException catch (e) {
      if (!isClosed) {
        logoError.value = e.message;
      }
    } catch (_) {
      if (!isClosed) {
        logoError.value = 'Unable to use this image. Please choose another.';
      }
    } finally {
      if (!isClosed) {
        pickingLogo.value = false;
      }
    }
  }

  bool validateLogo() {
    if (logo.value != null && !hasValidLogo) {
      logoError.value = 'Select a valid company logo of 2 MB or smaller.';
      return false;
    }

    logoError.value = '';
    return true;
  }

  void removeLogo() {
    if (saving.value || pickingLogo.value) return;

    logo.value = null;
    logoError.value = '';
  }

  String? validate(CompanyField field, String? raw) {
    final value = raw?.trim() ?? '';

    if (value.isEmpty) {
      return field.required ? '${field.label} is required' : null;
    }

    if (field.maxLength != null && value.length > field.maxLength!) {
      return 'Use ${field.maxLength} characters or fewer';
    }

    if (field.exactLength != null && value.length != field.exactLength!) {
      return 'Enter exactly ${field.exactLength} characters';
    }

    if (field.numeric) {
      final number = num.tryParse(value);

      if (number == null || !number.isFinite) {
        return 'Enter a valid number';
      }

      if (field.min != null && number < field.min!) {
        return 'Must be at least ${field.min}';
      }

      if (field.max != null && number > field.max!) {
        return 'Must be ${field.max} or less';
      }

      if (field.key == 'market_cap' && !(number * 10000000).isFinite) {
        return 'Market cap is too large';
      }
    }

    return null;
  }

  Map<String, dynamic> buildPayload() {
    final body = <String, dynamic>{
      'type': companyType.value,
      'sector': sectorId.value!,
      if (category.value != null) 'category': category.value!.apiCategory,
    };

    for (final field in allFields) {
      final value = text(field.key);
      if (value.isEmpty && !field.required) continue;

      if (field.numeric) {
        final number = num.parse(value);
        body[field.key] = field.key == 'market_cap' ? number : number;
      } else {
        body[field.key] =
            ['cin', 'pan_number', 'isin_number'].contains(field.key)
            ? value.toUpperCase()
            : value;
      }
    }

    return body;
  }

  Future<void> submit() async {
    if (saving.value || pickingLogo.value) return;

    final formValid = formKey.currentState?.validate() ?? false;
    final logoValid = validateLogo();

    if (!formValid || !logoValid || !canSave) return;

    final selectedLogo = logo.value;

    saving.value = true;
    submitError.value = '';

    try {
      var res = await CompanyApi.createCompany(
        buildPayload(),
        logo: selectedLogo,
      );
      if (isClosed) return;
      if (res.isSuccess) {
        Get.back(result: true);
        toast(res.m, MessageEnum.success);
      } else {
        toast(res.m, MessageEnum.error);
      }
    } catch (_) {
      if (!isClosed) {
        submitError.value =
            'Unable to create company. Please check your details and retry.';
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    _duplicateTimer?.cancel();
    _duplicateRequestId++;

    for (final controller in fields.values) {
      controller.dispose();
    }

    super.onClose();
  }
}
