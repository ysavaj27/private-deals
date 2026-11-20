import 'package:private_deals/src/features/auth/data/w_auth_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/user/user_model.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart' show DioApiError;
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

class SellerProfilePageCtrl extends GetxController {
  static const selfInvestorMissingMessage =
      'Your self investor is not set up yet. Contact support to buy deals.';

  final profile = _profileFromBusiness(app.wUser.toJson()).obs;
  /// Display photo via `GET`/`POST v2/business/profile` (logo form field only).
  final canEdit = true;
  final editing = false.obs;

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

  /// Institution self investor used by the existing CML KYC dialog.
  final selfInvestor = Rxn<InvestorModel>();
  final kycLoading = false.obs;
  final kycError = ''.obs;
  final kycMissing = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
    refreshSelfKyc();
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

  /// Loads KYC status for the seller's own investor. A successful save reloads
  /// this list; completion is `preipo_kyc_status == 1`.
  Future<void> refreshSelfKyc() async {
    if (kycLoading.value || isClosed) return;
    kycLoading.value = true;
    try {
      final result = await WInvestorsApi.investorsList(
        isKyc: 'All',
        isActive: 'All',
        isAif: 'All',
      );
      if (isClosed) return;
      if (!result.isSuccess || result.r == null) {
        selfInvestor.value = null;
        kycMissing.value = false;
        kycError.value = result.m.isEmpty
            ? 'Unable to load KYC. Please retry.'
            : result.m;
        return;
      }
      final id = app.wUser.selfInvestorId;
      final investor = result.r!.firstWhereOrNull(
        (item) => item.isSelf || (id != null && id > 0 && item.id == id),
      );
      if (investor == null) {
        selfInvestor.value = null;
        kycMissing.value = id == null || id <= 0;
        kycError.value = kycMissing.value
            ? ''
            : 'Unable to load KYC. Please retry.';
        return;
      }
      selfInvestor.value = investor;
      kycMissing.value = false;
      kycError.value = '';
    } catch (_) {
      if (!isClosed) {
        selfInvestor.value = null;
        kycMissing.value = false;
        kycError.value = 'Unable to load KYC. Please retry.';
      }
    } finally {
      if (!isClosed) kycLoading.value = false;
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
