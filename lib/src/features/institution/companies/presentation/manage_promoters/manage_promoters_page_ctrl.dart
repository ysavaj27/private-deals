import 'package:private_deals/src/features/institution/support/plugins/toast.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';

class PromoterFields {
  PromoterFields({Map<String, dynamic> data = const {}})
    : name = TextEditingController(text: data['name']?.toString() ?? ''),
      designation = TextEditingController(
        text: data['designation']?.toString() ?? '',
      ),
      experience = TextEditingController(
        text: data['experience']?.toString() ?? '',
      ),
      url = TextEditingController(text: data['url']?.toString() ?? '');

  final key = UniqueKey();

  final TextEditingController name;
  final TextEditingController designation;
  final TextEditingController experience;
  final TextEditingController url;

  Map<String, dynamic> toJson() {
    return {
      'name': name.text.trim(),
      'designation': designation.text.trim(),
      'experience': experience.text.trim(),
      'url': url.text.trim(),
    };
  }

  void dispose() {
    name.dispose();
    designation.dispose();
    experience.dispose();
    url.dispose();
  }
}

class CompanyPromotersCtrl extends GetxController {
  final formKey = GlobalKey<FormState>();

  final promoters = <PromoterFields>[].obs;
  final loading = true.obs;
  final saving = false.obs;
  final loadError = ''.obs;
  final errorMessage = ''.obs;
  final companyName = ''.obs;

  final List<PromoterFields> _removed = [];

  late final String slug;
  int companyId = 0;

  @override
  void onInit() {
    super.onInit();

    slug = Get.parameters['slug']?.trim() ?? '';

    if (slug.isEmpty) {
      loading.value = false;
      loadError.value = 'Company UUID is missing from the URL.';
      return;
    }

    fetchCompany();
  }

  Future<void> fetchCompany() async {
    if (slug.isEmpty) return;

    loading.value = true;
    loadError.value = '';

    try {
      // Connect this to your existing company-details API.
      final data = await CompanyApi.getCompanyDetail(slug: slug);

      if (isClosed) return;
      if (data.isSuccess && data.r != null) {
        final id = data.r!.id;

        final rawPromoters = data.r!.promoters;

        final rows = rawPromoters.map((item) {
          return PromoterFields(data: Map<String, dynamic>.from(item.toJson()));
        }).toList();

        _removed.addAll(promoters);

        companyId = id;
        companyName.value = data.r!.brandName;
        promoters.assignAll(rows);
      }
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load company promoters. Please retry.';
      }
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void addPromoter() {
    if (saving.value) return;

    promoters.add(PromoterFields());
    errorMessage.value = '';
  }

  void removePromoter(PromoterFields promoter) {
    if (saving.value) return;

    if (promoters.remove(promoter)) {
      _removed.add(promoter);
    }
  }

  String? requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? validateUrl(String? raw) {
    final value = raw?.trim() ?? '';

    if (value.isEmpty || value.toUpperCase() == 'N/A') {
      return null;
    }

    final uri = Uri.tryParse(value);

    if (uri == null ||
        !['http', 'https'].contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(value)) {
      return 'Enter a valid http:// or https:// URL';
    }

    return null;
  }

  Future<void> save() async {
    if (saving.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    saving.value = true;
    errorMessage.value = '';

    try {
      final res = await CompanyApi.savePromoters(
        companyId: companyId,
        promoters: promoters.map((row) => row.toJson()).toList(),
      );

      if (isClosed) return;
      if (res.isSuccess) {
        Get.back(result: true);
        toast(
          res.m.isEmpty ? 'Promoters saved successfully.' : res.m,
          MessageEnum.success,
        );
      } else {
        errorMessage.value = res.m.isEmpty
            ? 'Unable to save promoters. Please retry.'
            : res.m;
        toast(errorMessage.value, MessageEnum.error);
      }
    } catch (_) {
      if (!isClosed) {
        errorMessage.value =
            'Unable to save promoters. Your changes are still here.';
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    for (final row in [...promoters, ..._removed]) {
      row.dispose();
    }
    super.onClose();
  }
}
