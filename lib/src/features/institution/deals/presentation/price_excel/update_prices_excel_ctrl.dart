import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart';
import 'package:private_deals/src/features/institution/data/models/common/media_model.dart';
import 'package:private_deals/src/features/institution/data/models/deal/price_excel_review_model.dart';
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart';
import 'package:private_deals/src/shared/plugins/download_file/download_file.dart';
import 'package:private_deals/src/shared/plugins/open_file.dart';

enum PriceExcelStep { start, review, done }

class UpdatePricesExcelCtrl extends ChangeNotifier {
  PriceExcelStep step = PriceExcelStep.start;
  bool busy = false;
  String message = '';
  bool messageIsError = false;
  PriceExcelReview? review;
  MediaModel? pickedFile;
  int savedCount = 0;
  bool _saveBlocked = false;

  bool get canDismiss => !busy;

  bool get canSave {
    final data = review;
    if (data == null || _saveBlocked) return false;
    // API refuses confirm while any sheet row still needs a fix.
    return data.createCount > 0 && data.errorCount == 0;
  }

  bool get hasFixableErrors => (review?.errorCount ?? 0) > 0;

  void _setBusy(bool value) {
    busy = value;
    notifyListeners();
  }

  void _setMessage(String value, {bool isError = true}) {
    message = value;
    messageIsError = isError;
    notifyListeners();
  }

  void clearMessage() {
    if (message.isEmpty) return;
    message = '';
    messageIsError = false;
    notifyListeners();
  }

  bool _isSaveBlockedMessage(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'these prices are already saved for today.' ||
        normalized ==
            'no prices to save. fill at least one sell or buy price.';
  }

  bool _isFixRowsBeforeSaveMessage(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized.contains('fix') &&
        (normalized.contains('highlight') ||
            normalized.contains('row') ||
            normalized.contains('error'));
  }

  String get _fixRowsGuidance =>
      'Clear or fix the highlighted rows in Excel (you can leave those prices blank), then tap Upload another file. After errors are cleared, Save will store the valid prices.';

  Future<void> downloadSheet() async {
    if (busy) return;
    _setBusy(true);
    clearMessage();

    final result = await DealApi.downloadPriceExcel(
      type: CompanyType.unlisted,
    );

    if (!result.isSuccess || result.r == null) {
      _setBusy(false);
      _setMessage(
        result.m.isNotEmpty ? result.m : 'Download failed. Try again.',
      );
      return;
    }

    final bytes = result.r!;
    final path = await DownloadFile.downloadFromByte(
      bytes: bytes,
      fileName: 'institution-prices.xlsx',
    );

    _setBusy(false);

    if (path.isEmpty) {
      _setMessage('Could not save the sheet. Check storage permissions.');
      return;
    }

    if (!kIsWeb) {
      openFile(path);
    }

    _setMessage(
      'Sheet downloaded. Edit prices in Excel, then upload it here.',
      isError: false,
    );
  }

  Future<void> pickAndUpload({bool confirm = false}) async {
    if (busy) return;

    if (!confirm) {
      final files = await FilePickers().pickFile(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
      );
      if (files.isEmpty) return;
      pickedFile = files.first;
      _saveBlocked = false;
    }

    final file = pickedFile;
    if (file == null || file.uint8list == null || file.uint8list!.isEmpty) {
      _setMessage('Choose an .xlsx file to continue.');
      return;
    }

    await _upload(file: file, confirm: confirm);
  }

  Future<void> uploadAnother() => pickAndUpload(confirm: false);

  Future<void> savePrices() async {
    if (busy) return;
    final data = review;
    if (data == null || _saveBlocked) return;

    // Backend rejects confirm while any row needs a fix — guide re-upload instead
    // of leaving the user stuck on "fix highlighted rows".
    if (data.errorCount > 0) {
      _setMessage(_fixRowsGuidance);
      return;
    }

    if (data.createCount <= 0) return;
    await pickAndUpload(confirm: true);
  }

  Future<void> _upload({
    required MediaModel file,
    required bool confirm,
  }) async {
    _setBusy(true);
    clearMessage();

    final result = await DealApi.uploadPriceExcel(
      file: file,
      confirm: confirm,
    );

    _setBusy(false);

    if (!result.isSuccess) {
      final data = result.r;
      final hasErrors = data != null && data.errors.isNotEmpty;
      final blocked = _isSaveBlockedMessage(result.m);
      final needsFix = _isFixRowsBeforeSaveMessage(result.m) || hasErrors;

      if (confirm) {
        if (data != null) {
          review = data;
        }
        step = PriceExcelStep.review;
        _saveBlocked = blocked;
        _setMessage(
          needsFix
              ? _fixRowsGuidance
              : result.m.isNotEmpty
              ? result.m
              : 'Could not save prices. Try again.',
        );
        return;
      }

      _setMessage(
        result.m.isNotEmpty ? result.m : 'Upload failed. Try again.',
      );
      return;
    }

    final data = result.r;
    if (data == null) {
      _setMessage(result.m.isNotEmpty ? result.m : 'Unexpected response.');
      return;
    }

    review = data;
    _saveBlocked = false;

    if (confirm) {
      savedCount = data.createCount;
      step = PriceExcelStep.done;
      message = '';
      messageIsError = false;
      notifyListeners();
      return;
    }

    step = PriceExcelStep.review;
    if (data.errorCount > 0 && data.createCount > 0) {
      _setMessage(_fixRowsGuidance);
    } else {
      message = '';
      messageIsError = false;
      notifyListeners();
    }
  }
}
