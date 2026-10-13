import 'package:private_deals/src/features/wealth_manager/data/models/document/partner_document_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class SendDocumentPageCtrl extends GetxController {
  final isLoading = false.obs;
  final isSending = false.obs;
  final isDownloading = false.obs;
  final error = ''.obs;
  final documents = <PartnerDocumentModel>[].obs;
  final selectedType = ''.obs;
  final selectedStatus = ''.obs;
  final searchQuery = ''.obs;

  int _request = 0;

  List<DocumentTypeOption> get typeOptions =>
      app.config.enumValues.documentType.options;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> selectType(String type) async {
    if (selectedType() == type) return;
    selectedType(type);
    await refreshData();
  }

  Future<void> selectStatus(String status) async {
    if (selectedStatus() == status) return;
    selectedStatus(status);
    await refreshData();
  }

  void search(String query) {
    searchQuery(query.trim().toLowerCase());
  }

  List<PartnerDocumentModel> get filteredDocuments {
    final query = searchQuery();
    if (query.isEmpty) return documents.toList(growable: false);
    return documents
        .where((doc) {
          final tx = doc.transaction;
          final haystack = [
            doc.type,
            doc.name,
            doc.status,
            doc.investor.name,
            doc.investor.email,
            doc.investor.mobileDisplay,
            if (tx != null) tx.invoiceNo,
            if (tx != null) tx.companyName,
            if (tx != null) tx.status,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  Future<void> refreshData() async {
    final request = ++_request;
    isLoading(true);
    error('');
    try {
      final res = await DocumentApi.list(
        type: selectedType().isEmpty ? null : selectedType(),
        status: selectedStatus().isEmpty ? null : selectedStatus(),
      );
      if (request != _request || isClosed) return;
      if (res.isSuccess && res.r != null) {
        documents.assignAll(res.r!);
      } else {
        documents.clear();
        error(
          res.m.isNotEmpty
              ? res.m
              : 'Unable to load documents. Please try again.',
        );
      }
    } catch (_) {
      if (request == _request && !isClosed) {
        documents.clear();
        error('Unable to load documents. Please try again.');
      }
    } finally {
      if (request == _request && !isClosed) isLoading(false);
    }
  }

  Future<void> download(PartnerDocumentModel doc) async {
    if (isDownloading() || doc.id <= 0) return;
    isDownloading(true);
    try {
      final res = await DocumentApi.download(doc.id);
      if (!res.isSuccess) {
        toast(
          res.m.isNotEmpty ? res.m : 'Download failed.',
          MessageEnum.error,
        );
        return;
      }

      final bytes = res.r;
      final fileName = _fileNameFor(doc);

      // JSON download responses may return a URL in the message with empty bytes.
      if ((bytes == null || bytes.isEmpty) && res.m.isNotEmpty) {
        final ok = await DownloadFile.downloadFromUrl(
          url: res.m,
          fileName: fileName,
        );
        if (!ok) toast('Download failed.', MessageEnum.error);
        return;
      }

      if (bytes == null || bytes.isEmpty) {
        toast('Download failed.', MessageEnum.error);
        return;
      }

      final path = await DownloadFile.downloadFromByte(
        bytes: bytes,
        fileName: fileName,
      );
      if (path.isEmpty) {
        toast('Download failed.', MessageEnum.error);
      } else {
        toast('Download started.', MessageEnum.success);
      }
    } catch (e) {
      toast(e.toString(), MessageEnum.error);
    } finally {
      isDownloading(false);
    }
  }

  Future<void> send(PartnerDocumentModel doc, String channel) async {
    if (isSending() || doc.id <= 0) return;
    isSending(true);
    try {
      final res = await DocumentApi.send(
        documentId: doc.id,
        channel: channel,
      );
      if (res.isSuccess) {
        toast(
          DocumentSendAction.toastMessage(res.r),
          MessageEnum.success,
        );
        await refreshData();
      } else {
        toast(
          res.m.isNotEmpty ? res.m : 'Unable to send document.',
          MessageEnum.error,
        );
      }
    } catch (e) {
      toast(e.toString(), MessageEnum.error);
    } finally {
      isSending(false);
    }
  }

  String _fileNameFor(PartnerDocumentModel doc) {
    final base = doc.name.trim().isNotEmpty
        ? doc.name.trim()
        : (doc.type.trim().isNotEmpty ? doc.type.trim() : 'document');
    final safe = base.replaceAll(RegExp(r'[^\w\-. ]+'), '_');
    if (safe.toLowerCase().endsWith('.pdf')) return safe;
    return '$safe.pdf';
  }
}
