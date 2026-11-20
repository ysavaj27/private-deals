import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/data/api/company_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/features/institution/support/plugins/toast.dart';

class CompanyEventsCtrl extends GetxController {
  static final _apiDate = DateFormat('d-M-yyyy');
  static final _displayDate = DateFormat('d MMM yyyy');

  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final events = <CompanyEventModel>[].obs;
  final loading = true.obs;
  final saving = false.obs;
  final loadError = ''.obs;
  final companyName = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final pickedFile = Rxn<MediaModel>();
  final existingFileUrl = ''.obs;
  final editingEventId = RxnInt();

  late final String slug;
  int companyId = 0;

  bool get isEditing => editingEventId.value != null;

  String get editorTitle => isEditing ? 'Edit event' : 'Add event';

  @override
  void onInit() {
    super.onInit();
    slug = Get.parameters['slug']?.trim() ?? '';
    if (slug.isEmpty) {
      loading.value = false;
      loadError.value = 'Company slug is missing from the URL.';
      return;
    }
    fetchCompanyAndEvents();
  }

  Future<void> fetchCompanyAndEvents() async {
    if (slug.isEmpty) return;

    loading.value = true;
    loadError.value = '';

    try {
      final companyRes = await CompanyApi.getCompanyDetail(slug: slug);
      if (isClosed) return;

      if (!companyRes.isSuccess || companyRes.r == null) {
        loadError.value = companyRes.m.isEmpty
            ? 'Unable to load company.'
            : companyRes.m;
        return;
      }

      final company = companyRes.r!;
      // Ownership was gated on the list; detail may omit is_editable.

      companyId = company.id;
      companyName.value = company.brandName.isNotEmpty
          ? company.brandName
          : company.companyName;

      final eventsRes = await CompanyApi.getCompanyEvents(companyId: companyId);
      if (isClosed) return;

      if (!eventsRes.isSuccess) {
        loadError.value = eventsRes.m.isEmpty
            ? 'Unable to load events.'
            : eventsRes.m;
        return;
      }

      events.assignAll(eventsRes.r ?? []);
      resetEditor();
    } catch (_) {
      if (!isClosed) {
        loadError.value = 'Unable to load company events. Please retry.';
      }
    } finally {
      if (!isClosed) loading.value = false;
    }
  }

  void resetEditor() {
    editingEventId.value = null;
    titleCtrl.clear();
    descriptionCtrl.clear();
    selectedDate.value = null;
    pickedFile.value = null;
    existingFileUrl.value = '';
    formKey.currentState?.reset();
  }

  void startCreate() {
    if (saving.value) return;
    resetEditor();
  }

  void startEdit(CompanyEventModel event) {
    if (saving.value) return;
    editingEventId.value = event.id;
    titleCtrl.text = event.title;
    descriptionCtrl.text = event.description;
    selectedDate.value = event.date;
    pickedFile.value = null;
    existingFileUrl.value = event.downloadUrl;
  }

  Future<void> pickEventFile() async {
    if (saving.value) return;
    try {
      final files = await FilePickers().pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'xlsx'],
      );
      if (files.isEmpty || isClosed) return;
      pickedFile.value = files.first;
    } catch (_) {
      toast('Unable to select that file. Please try another.', MessageEnum.error);
    }
  }

  void clearPickedFile() {
    if (saving.value) return;
    pickedFile.value = null;
  }

  Future<void> pickDate(BuildContext context) async {
    if (saving.value) return;
    final now = DateTime.now();
    final initial = selectedDate.value ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null && !isClosed) {
      selectedDate.value = picked;
    }
  }

  String formatDisplayDate(DateTime date) => _displayDate.format(date);

  String? validateTitle(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return 'Title is required';
    if (value.length > 255) return 'Use 255 characters or fewer';
    return null;
  }

  String? validateDescription(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return 'Description is required';
    if (value.length > 5000) return 'Use 5000 characters or fewer';
    return null;
  }

  Future<void> saveEvent() async {
    if (saving.value || companyId <= 0) return;

    final formValid = formKey.currentState?.validate() ?? false;
    final date = selectedDate.value;
    if (!formValid) return;
    if (date == null) {
      toast('Select an event date.', MessageEnum.error);
      return;
    }

    saving.value = true;
    try {
      final title = titleCtrl.text.trim();
      final description = descriptionCtrl.text.trim();
      final dateText = _apiDate.format(date);
      final file = pickedFile.value;

      final res = isEditing
          ? await CompanyApi.updateCompanyEvent(
              id: editingEventId.value!,
              date: dateText,
              title: title,
              description: description,
              file: file,
            )
          : await CompanyApi.createCompanyEvent(
              companyId: companyId,
              date: dateText,
              title: title,
              description: description,
              file: file,
            );

      if (isClosed) return;

      if (!res.isSuccess) {
        toast(
          res.m.isEmpty ? 'Unable to save event.' : res.m,
          MessageEnum.error,
        );
        return;
      }

      toast(
        res.m.isEmpty
            ? (isEditing ? 'Event updated.' : 'Event created.')
            : res.m,
        MessageEnum.success,
      );
      await fetchCompanyAndEvents();
    } catch (_) {
      if (!isClosed) {
        toast('Unable to save event. Please retry.', MessageEnum.error);
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  Future<void> deleteEvent(CompanyEventModel event) async {
    if (saving.value || event.id <= 0) return;

    saving.value = true;
    try {
      final res = await CompanyApi.deleteCompanyEvent(id: event.id);
      if (isClosed) return;
      if (!res.isSuccess) {
        toast(
          res.m.isEmpty ? 'Unable to delete event.' : res.m,
          MessageEnum.error,
        );
        return;
      }
      toast(
        res.m.isEmpty ? 'Event deleted.' : res.m,
        MessageEnum.success,
      );
      if (editingEventId.value == event.id) {
        resetEditor();
      }
      await fetchCompanyAndEvents();
    } catch (_) {
      if (!isClosed) {
        toast('Unable to delete event. Please retry.', MessageEnum.error);
      }
    } finally {
      if (!isClosed) saving.value = false;
    }
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
