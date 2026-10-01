import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:private_deals/src/core/configuration/dio_config.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/shared/models/base_model.dart';

class CmlDocument {
  const CmlDocument(this.name, this.bytes);
  final String name;
  final Uint8List bytes;
  void validate() {
    if (!name.toLowerCase().endsWith('.pdf') ||
        bytes.length < 5 ||
        String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const FormatException('Choose a valid PDF document.');
    }
    if (bytes.length > 10 * 1024 * 1024)
      throw const FormatException('CML must be 10 MB or smaller.');
  }
}

class CmlApi {
  static const base = 'v2/business/investor/kyc/cml';
  static const requiredFields = ['dp_id', 'client_id', 'pan_no', 'name'];
  static const optionalFields = [
    'account_number',
    'ifsc_code',
    'bank_name',
    'dob',
  ];
  static bool isSelf(InvestorModel investor) =>
      investor.isSelf ||
      (app.wUser.selfInvestorId != null &&
          investor.id == app.wUser.selfInvestorId);
  static Future<BaseModel<Map<String, dynamic>>> read(
    int investorId,
    CmlDocument document,
  ) async {
    try {
      document.validate();
      final response = await dioConfig.post('$base/read', {
        'investor_id': investorId,
        'cml': MultipartFile.fromBytes(document.bytes, filename: document.name),
      }, false);
      return BaseModel.fromJson(response.data, (data) => data);
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel> save(
    InvestorModel investor,
    Map<String, String> fields,
    CmlDocument? document,
  ) async {
    if (isSelf(investor))
      return BaseModel.fromError('Saving your own CML is not available yet.');
    try {
      if (requiredFields.any((field) => (fields[field] ?? '').trim().isEmpty))
        throw const FormatException('Complete all required fields.');
      document?.validate();
      final payload = <String, dynamic>{
        'investor_id': investor.id,
        for (final field in [...requiredFields, ...optionalFields])
          if ((fields[field] ?? '').trim().isNotEmpty)
            field: fields[field]!.trim(),
        if (document != null)
          'cml_file': MultipartFile.fromBytes(
            document.bytes,
            filename: document.name,
          ),
      };
      final response = await dioConfig.post('$base/save', payload, false);
      return BaseModel.fromMessage(response.data);
    } catch (e) {
      return BaseModel.fromError(e.toString());
    }
  }
}
