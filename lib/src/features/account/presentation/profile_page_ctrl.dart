import 'dart:ui' as ui;

import 'package:private_deals/src/shared/app_exports.dart';

class ProfilePageCtrl extends GetxController {
  final isLoading = false.obs;
  final picking = false.obs;
  final saving = false.obs;
  final editing = false.obs;
  final error = ''.obs;
  final photoUrl = ''.obs;
  final selectedLogo = Rxn<MediaModel>();

  final emailCTRL = TextEditingController();
  final commissionCTRL = TextEditingController();
  final mobileCTRL = TextEditingController();
  final nameCTRL = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _bindFromSession();
    refreshProfile();
  }

  void _bindFromSession() {
    emailCTRL.text = app.wUser.email.toLowerCase();
    nameCTRL.text = app.wUser.name;
    mobileCTRL.text = app.wUser.mobileNumber.toShowString;
    commissionCTRL.text = app.wUser.commission.toShowString;
    // Show profile_photo as returned (including initials avatar URLs).
    photoUrl.value = app.wUser.profilePhoto.trim().isNotEmpty
        ? app.wUser.profile
        : '';
  }

  Future<void> refreshProfile() async {
    if (isLoading.value || isClosed) return;
    isLoading.value = true;
    try {
      final result = await WAuthApi.profilePhotoGet();
      if (isClosed) return;
      if (!result.isSuccess || result.r == null) {
        error.value = result.m.isEmpty
            ? 'Unable to load profile. Please retry.'
            : result.m;
        return;
      }
      _bindFromSession();
      error.value = '';
    } catch (_) {
      if (!isClosed) error.value = 'Unable to load profile. Please retry.';
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void editPhoto() {
    if (saving.value || picking.value) return;
    error.value = '';
    editing.value = true;
  }

  void cancelPhoto() {
    if (saving.value || picking.value) return;
    selectedLogo.value = null;
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
      if (!isClosed) selectedLogo.value = selected;
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

  Future<void> savePhoto() async {
    final selected = selectedLogo.value;
    if (saving.value || picking.value || selected?.uint8list == null) return;
    saving.value = true;
    error.value = '';
    try {
      final result = await WAuthApi.profilePhotoUpdate(
        image: selected!.uint8list!,
        imageName: selected.name,
      );
      if (isClosed) return;
      if (!result.isSuccess || result.r == null) {
        error.value = result.m.isEmpty
            ? 'Unable to update photo. Please retry.'
            : result.m;
        return;
      }
      _bindFromSession();
      selectedLogo.value = null;
      editing.value = false;
      toast(
        result.m.isEmpty ? 'Profile photo updated.' : result.m,
        MessageEnum.success,
      );
    } catch (_) {
      if (!isClosed) error.value = 'Unable to update photo. Please retry.';
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  Future<void> updateProfile() async {
    isLoading(true);
    var res = await WAuthApi.profileDetailUpdate(email: emailCTRL.text);
    isLoading(false);
    if (res.isSuccess) {
      toast(res.m, MessageEnum.success);
    } else {
      toast(res.m, MessageEnum.error);
    }
  }

  @override
  void onClose() {
    emailCTRL.dispose();
    commissionCTRL.dispose();
    mobileCTRL.dispose();
    nameCTRL.dispose();
    super.onClose();
  }
}
