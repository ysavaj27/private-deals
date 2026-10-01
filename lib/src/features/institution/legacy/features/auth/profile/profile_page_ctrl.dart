import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';
import 'package:private_deals/src/shared/models/base_model.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/legacy/backend/model/user/user_model.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/features/institution/legacy/utils/constant/app_url.dart';
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

class SellerProfilePageCtrl extends GetxController {
  final profile = UserModel.fromJson(app.wUser.toJson()).obs;
  final editing = false.obs;
  final picking = false.obs;
  final saving = false.obs;
  final loading = false.obs;
  final error = ''.obs;
  final logo = Rxn<MediaModel>();

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
  }

  Future<bool> refreshProfile() async {
    if (loading.value || isClosed) return false;
    loading.value = true;
    try {
      final response = await dioConfig
          .get(AppUrl.profileGet, {})
          .timeout(const Duration(seconds: 20));
      final result = BaseModel<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
      if (!result.isSuccess || result.r == null) {
        throw Exception('Unable to load profile. Please retry.');
      }
      if (isClosed || !app.isUserLogin) return false;
      profile.value = result.r!;
      error.value = '';
      return true;
    } catch (_) {
      if (!isClosed) error.value = 'Unable to refresh profile. Please retry.';
      return false;
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void edit() {
    if (saving.value) return;
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
    if (picking.value || saving.value) return;
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
    if (saving.value || picking.value || logo.value == null) return;
    saving.value = true;
    error.value = '';
    try {
      final selected = logo.value!;
      final body = await dioConfig.createBytesImage(
        image: selected.uint8list!,
        imageName: selected.name,
        key: 'logo',
      );
      final response = await dioConfig.post(AppUrl.profileUpdate, body, false);
      final result = BaseModel.fromMessage(response.data);
      if (isClosed) return;
      if (!result.isSuccess) {
        error.value = result.m.isEmpty
            ? 'Unable to update logo. Please retry.'
            : result.m;
        return;
      }
      editing.value = false;
      toast(
        result.m.isEmpty ? 'Profile logo updated.' : result.m,
        MessageEnum.success,
      );
      // Fetch the canonical URL; the update endpoint need not return a user.
      final refreshed = await refreshProfile();
      if (!isClosed) {
        if (refreshed) {
          logo.value = null;
        } else {
          error.value =
              'Logo saved, but profile could not be refreshed. Please retry refresh.';
        }
      }
    } catch (_) {
      if (!isClosed) error.value = 'Unable to update logo. Please retry.';
    } finally {
      if (!isClosed) saving.value = false;
    }
  }
}
