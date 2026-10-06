import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/institution/data/api/institution_profile_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/pre_ipo/company_model.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/user/user_model.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart' show DioApiError;
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

class SellerProfilePageCtrl extends GetxController {
  final profile = _profileFromBusiness(app.wUser.toJson()).obs;
  /// Display photo via `GET`/`POST v2/business/profile` (logo form field only).
  final canEdit = true;
  final editing = false.obs;

  /// Public seller profile shown to partners on company detail deals.
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

  static UserModel _profileFromBusiness(Map<String, dynamic> data) {
    return UserModel.fromJson({
      ...data,
      'company_name': data['company_name'] ?? data['name'],
      // Show profile_photo as-is (including initials avatar URLs).
      'logo': data['profile_photo'] ?? data['logo'] ?? '',
      'profile': data['profile_photo'] ?? data['profile'] ?? data['logo'] ?? '',
    });
  }

  final picking = false.obs;
  final saving = false.obs;
  final loading = false.obs;
  final error = ''.obs;
  final logo = Rxn<MediaModel>();

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
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

  Future<bool> refreshProfile() async {
    if (loading.value || isClosed) return false;
    final revision = app.revision;
    final userId = app.userId;
    loading.value = true;
    try {
      final result = await WAuthApi.profilePhotoGet();
      if (!result.isSuccess || result.r == null || result.r!.id != userId) {
        throw Exception(
          result.m.isEmpty ? 'Unable to load profile. Please retry.' : result.m,
        );
      }
      if (isClosed || !app.isUserLogin || app.revision != revision) {
        return false;
      }
      profile.value = _profileFromBusiness(result.r!.toJson());
      error.value = '';
      return true;
    } catch (_) {
      if (!isClosed) error.value = 'Unable to refresh profile. Please retry.';
      return false;
    } finally {
      if (!isClosed) loading.value = false;
    }
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
      final result = await InstitutionProfileApi.getProfile();
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
      final result = await InstitutionProfileApi.saveProfile(payload);
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

  void edit() {
    if (!canEdit || saving.value) return;
    error.value = '';
    editing.value = true;
  }

  void cancel() {
    if (saving.value || picking.value) return;
    logo.value = null;
    error.value = '';
    editing.value = false;
  }

  Future<void> pickLogo() async {
    if (!canEdit || picking.value || saving.value) return;
    picking.value = true;
    error.value = '';
    try {
      final selected = await FilePickers().pickLogo();
      if (selected == null || isClosed) return;
      final bytes = selected.uint8list;
      if (bytes == null || bytes.isEmpty) {
        throw const FormatException('Select a non-empty image.');
      }
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 128);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (!isClosed) logo.value = selected;
    } on FormatException catch (e) {
      if (!isClosed) error.value = e.message;
    } catch (_) {
      if (!isClosed) {
        error.value = 'Unable to use this image. Please choose another.';
      }
    } finally {
      if (!isClosed) picking.value = false;
    }
  }

  Future<void> save() async {
    if (!canEdit || saving.value || picking.value || logo.value == null) return;
    saving.value = true;
    error.value = '';
    try {
      final selected = logo.value!;
      final result = await WAuthApi.profilePhotoUpdate(
        image: selected.uint8list!,
        imageName: selected.name,
      );
      if (isClosed) return;
      if (!result.isSuccess || result.r == null) {
        error.value = result.m.isEmpty
            ? 'Unable to update logo. Please retry.'
            : result.m;
        return;
      }
      profile.value = _profileFromBusiness(result.r!.toJson());
      logo.value = null;
      editing.value = false;
      toast(
        result.m.isEmpty ? 'Profile logo updated.' : result.m,
        MessageEnum.success,
      );
    } on DioApiError catch (e) {
      if (!isClosed) {
        error.value = e.message.isEmpty
            ? 'Unable to update logo. Please retry.'
            : e.message;
      }
    } catch (_) {
      if (!isClosed) error.value = 'Unable to update logo. Please retry.';
    } finally {
      if (!isClosed) saving.value = false;
    }
  }
}
