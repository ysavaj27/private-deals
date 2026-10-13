import 'dart:convert';

import 'package:private_deals/src/features/wealth_manager/data/models/document/partner_document_model.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

class DocumentApi {
  static Future<BaseModel<List<PartnerDocumentModel>>> list({
    String? type,
    String? status,
    int? investorId,
    int? companyId,
    int? transactionId,
    String? from,
    String? to,
    int? skip,
    int? take,
  }) async {
    try {
      final params = <String, dynamic>{
        if (type != null && type.isNotEmpty) 'type': type,
        if (status != null && status.isNotEmpty) 'status': status,
        if (investorId != null) 'investor_id': investorId,
        if (companyId != null) 'company_id': companyId,
        if (transactionId != null) 'transaction_id': transactionId,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (skip != null) 'skip': skip,
        if (take != null) 'take': take,
      };
      final res = await dioConfig.get(AppUrl.wDocuments, params);
      return BaseModel.fromListJson(
        res.data,
        (list) => list
            .whereType<Map>()
            .map(
              (item) => PartnerDocumentModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );
    } catch (e, t) {
      logger.e('Error on DocumentApi.list', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<Uint8List>> download(int documentId) async {
    try {
      final res = await dioConfig.getBytes(
        AppUrl.wDocumentsDownload,
        {'id': documentId},
      );
      final raw = res.data;
      if (raw == null) {
        return BaseModel.fromError('Download failed. Try again.');
      }

      final bytes = raw is Uint8List
          ? raw
          : Uint8List.fromList(List<int>.from(raw as List));

      final contentType =
          (res.headers.value('content-type') ?? '').toLowerCase();
      final looksLikeJson =
          contentType.contains('json') ||
          (bytes.isNotEmpty && bytes.first == 0x7B);

      if (looksLikeJson) {
        try {
          final decoded = jsonDecode(utf8.decode(bytes));
          if (decoded is Map) {
            final map = Map<String, dynamic>.from(decoded);
            if ((map['status'] ?? 0) == 1) {
              final data = map['data'];
              final url = data is Map
                  ? Parse.toStrings(
                      data['url'] ?? data['signed_path'] ?? data['path'],
                    )
                  : Parse.toStrings(data);
              if (url.isNotEmpty) {
                // Caller can treat empty bytes + message as URL hint via message.
                return BaseModel(
                  s: 1,
                  m: url,
                  r: Uint8List(0),
                );
              }
            }
            final message = Parse.toStrings(map['message']);
            return BaseModel.fromError(
              message.isNotEmpty ? message : 'Download failed. Try again.',
            );
          }
        } catch (_) {
          // Fall through and treat as file bytes.
        }
      }

      if (bytes.isEmpty) {
        return BaseModel.fromError('Download failed. Try again.');
      }
      return BaseModel(s: 1, m: '', r: bytes);
    } catch (e, t) {
      logger.e('Error on DocumentApi.download', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<String>> send({
    required int documentId,
    required String channel,
  }) async {
    try {
      final res = await dioConfig.post(AppUrl.wDocumentsSend, {
        'document_id': documentId,
        'channel': channel,
      });
      return BaseModel.fromJson(
        res.data,
        (data) => Parse.toStrings(data['action']),
      );
    } catch (e, t) {
      logger.e('Error on DocumentApi.send', error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }
}
