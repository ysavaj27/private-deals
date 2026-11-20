import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/account/data/additional_profile_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/plugins/toast.dart';

/// Loads and saves the seven-field additional profile for any partner type.
class AdditionalProfileCtrl extends GetxController {
  final publicProfile = const PartnerPublicProfile().obs;
  final publicEditing = false.obs;
  final publicLoading = false.obs;
  final publicSaving = false.obs;
  final publicError = ''.obs;

  final yearsOfExperienceCtrl = TextEditingController();
  final totalTradesExecutedCtrl = TextEditingController();
  final totalInvestorBaseCtrl = TextEditingController();
  final verifiedStatusCtrl = TextEditingController();
  final companiesPreviouslyListedCtrl = TextEditingController();
  final geographicPresenceCtrl = TextEditingController();
  final approachCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    refreshPublicProfile();
  }

  @override
  void onClose() {
    yearsOfExperienceCtrl.dispose();
    totalTradesExecutedCtrl.dispose();
    totalInvestorBaseCtrl.dispose();
    verifiedStatusCtrl.dispose();
    companiesPreviouslyListedCtrl.dispose();
    geographicPresenceCtrl.dispose();
    approachCtrl.dispose();
    super.onClose();
  }

  void _bindPublicForm(PartnerPublicProfile data) {
    yearsOfExperienceCtrl.text = data.yearsOfExperience;
    totalTradesExecutedCtrl.text = data.totalTradesExecuted;
    totalInvestorBaseCtrl.text = data.totalInvestorBase;
    verifiedStatusCtrl.text = data.verifiedStatus;
    companiesPreviouslyListedCtrl.text = data.companiesPreviouslyListed;
    geographicPresenceCtrl.text = data.geographicPresence;
    approachCtrl.text = data.approach;
  }

  Future<bool> refreshPublicProfile() async {
    if (publicLoading.value || isClosed) return false;
    publicLoading.value = true;
    try {
      final result = await AdditionalProfileApi.getProfile();
      if (isClosed) return false;
      if (!result.isSuccess || result.r == null) {
        publicError.value = result.m.isEmpty
            ? 'Unable to load seller profile. Please retry.'
            : result.m;
        return false;
      }
      publicProfile.value = result.r!;
      _bindPublicForm(result.r!);
      publicError.value = '';
      return true;
    } catch (_) {
      if (!isClosed) {
        publicError.value = 'Unable to load seller profile. Please retry.';
      }
      return false;
    } finally {
      if (!isClosed) publicLoading.value = false;
    }
  }

  void editPublicProfile() {
    if (publicSaving.value || publicLoading.value) return;
    publicError.value = '';
    _bindPublicForm(publicProfile.value);
    publicEditing.value = true;
  }

  void cancelPublicProfile() {
    if (publicSaving.value) return;
    _bindPublicForm(publicProfile.value);
    publicError.value = '';
    publicEditing.value = false;
  }

  Future<void> savePublicProfile() async {
    if (publicSaving.value || publicLoading.value) return;
    publicSaving.value = true;
    publicError.value = '';
    try {
      final payload = {
        'years_of_experience': yearsOfExperienceCtrl.text.trim(),
        'total_trades_executed': totalTradesExecutedCtrl.text.trim(),
        'total_investor_base': totalInvestorBaseCtrl.text.trim(),
        'verified_status': verifiedStatusCtrl.text.trim(),
        'companies_previously_listed':
            companiesPreviouslyListedCtrl.text.trim(),
        'geographic_presence': geographicPresenceCtrl.text.trim(),
        'approach': approachCtrl.text.trim(),
      };
      final result = await AdditionalProfileApi.saveProfile(payload);
      if (isClosed) return;
      if (!result.isSuccess || result.r == null) {
        publicError.value = result.m.isEmpty
            ? 'Unable to save seller profile. Please retry.'
            : result.m;
        return;
      }
      publicProfile.value = result.r!;
      _bindPublicForm(result.r!);
      publicEditing.value = false;
      toast(
        result.m.isEmpty ? 'Profile saved' : result.m,
        MessageEnum.success,
      );
    } catch (_) {
      if (!isClosed) {
        publicError.value = 'Unable to save seller profile. Please retry.';
      }
    } finally {
      if (!isClosed) publicSaving.value = false;
    }
  }
}
