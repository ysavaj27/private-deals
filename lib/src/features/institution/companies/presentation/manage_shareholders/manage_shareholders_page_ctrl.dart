import 'package:private_deals/src/features/institution/support/plugins/toast.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';

class ShareholderFields {
  ShareholderFields({ShareholderModel? data})
    : name = TextEditingController(text: data?.name ?? ''),
      percentage = TextEditingController(
        text: data?.percentage.toString() ?? '',
      );
  final key = UniqueKey();
  final TextEditingController name;
  final TextEditingController percentage;
  Map<String, dynamic> toJson() => {
    'name': name.text.trim(),
    'percentage': double.parse(percentage.text.trim()),
  };
  void dispose() {
    name.dispose();
    percentage.dispose();
  }
}

class ShareholderYearFields {
  ShareholderYearFields({ShareholderYearModel? data})
    : year = TextEditingController(text: data?.year ?? '') {
    shareholders.addAll(
      data?.shareholders.map((e) => ShareholderFields(data: e)) ?? [],
    );
  }
  final key = UniqueKey();
  final TextEditingController year;
  final shareholders = <ShareholderFields>[].obs;
  final removed = <ShareholderFields>[];
  Map<String, dynamic> toJson() => {
    'year': year.text.trim(),
    'shareholders': shareholders.map((e) => e.toJson()).toList(),
  };
  void dispose() {
    year.dispose();
    for (final row in [...shareholders, ...removed]) {
      row.dispose();
    }
  }
}

class CompanyShareholdersCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();
  final years = <ShareholderYearFields>[].obs;
  final _removed = <ShareholderYearFields>[];
  final loading = true.obs;
  final saving = false.obs;
  final loadError = ''.obs;
  final errorMessage = ''.obs;
  final companyName = ''.obs;
  late final String slug;
  int companyId = 0;

  @override
  void onInit() {
    super.onInit();
    slug = Get.parameters['slug']?.trim() ?? '';
    fetchCompany();
  }

  Future<void> fetchCompany() async {
    loading.value = true;
    loadError.value = '';
    companyId = 0;
    try {
      if (slug.isEmpty) {
        loadError.value = 'Company is missing from the URL.';
        return;
      }
      final res = await CompanyApi.getCompanyDetail(slug: slug);
      if (isClosed) return;
      final company = res.r;
      if (!res.isSuccess || company == null || company.id <= 0) {
        loadError.value = 'Unable to load company shareholders. Please retry.';
        return;
      }
      if (!company.isEditable) {
        loadError.value = 'This company cannot be edited.';
        return;
      }
      companyId = company.id;
      companyName.value = company.brandName;
      _removed.addAll(years);
      years.assignAll(
        company.shareHolders.map((e) => ShareholderYearFields(data: e)),
      );
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load company shareholders. Please retry.';
      }
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void addYear() {
    if (!saving.value) years.add(ShareholderYearFields());
  }

  void removeYear(ShareholderYearFields year) {
    if (!saving.value && years.remove(year)) _removed.add(year);
  }

  void addShareholder(ShareholderYearFields year) {
    if (!saving.value) year.shareholders.add(ShareholderFields());
  }

  void removeShareholder(ShareholderYearFields year, ShareholderFields row) {
    if (!saving.value && year.shareholders.remove(row)) year.removed.add(row);
  }

  String? requiredText(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label is required' : null;
  String? validatePercentage(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    return number == null || !number.isFinite || number < 0 || number > 100
        ? 'Enter a percentage from 0 to 100'
        : null;
  }

  Future<void> save() async {
    if (saving.value ||
        loading.value ||
        loadError.value.isNotEmpty ||
        companyId <= 0) {
      return;
    }
    if (!(formKey.currentState?.validate() ?? false)) return;
    saving.value = true;
    errorMessage.value = '';
    try {
      final res = await CompanyApi.saveShareholders(
        companyId: companyId,
        shareholders: years.map((e) => e.toJson()).toList(),
      );
      if (isClosed) return;
      if (res.isSuccess) {
        Get.back(result: true);
        toast(
          res.m.isEmpty ? 'Shareholders saved successfully.' : res.m,
          MessageEnum.success,
        );
      } else {
        errorMessage.value = res.m.isNotEmpty
            ? res.m
            : 'Unable to save shareholders. Please retry.';
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value =
            'Unable to save shareholders. Your changes are still here.';
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    for (final year in [...years, ..._removed]) {
      year.dispose();
    }
    super.onClose();
  }
}
