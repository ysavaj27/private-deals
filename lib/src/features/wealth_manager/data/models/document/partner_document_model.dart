import 'package:private_deals/src/shared/functions/parse.dart';

/// Partner client document from GET /api/v2/business/documents.
class PartnerDocumentModel {
  final int id;
  final String type;
  final String name;
  final String status;
  final String? signLink;
  final PartnerDocumentInvestor investor;
  final PartnerDocumentTransaction? transaction;

  const PartnerDocumentModel({
    this.id = 0,
    this.type = '',
    this.name = '',
    this.status = '',
    this.signLink,
    required this.investor,
    this.transaction,
  });

  bool get isPendingSignature => status == PartnerDocumentStatus.pendingSignature;
  bool get isExpired => status == PartnerDocumentStatus.expired;
  bool get isSigned => status == PartnerDocumentStatus.signed;
  bool get hasOpenSignLink =>
      signLink != null && signLink!.trim().isNotEmpty && !isSigned;

  factory PartnerDocumentModel.fromJson(Map<String, dynamic> json) {
    final signLinkRaw = json['sign_link'];
    final signLink = signLinkRaw == null ? null : Parse.toStrings(signLinkRaw);
    final transactionRaw = json['transaction'];
    return PartnerDocumentModel(
      id: Parse.toInt(json['id']),
      type: Parse.toStrings(json['type']),
      name: Parse.toStrings(json['name'] ?? json['display_name']),
      status: Parse.toStrings(json['status']),
      signLink: (signLink == null || signLink.isEmpty) ? null : signLink,
      investor: PartnerDocumentInvestor.fromJson(
        Map<String, dynamic>.from(json['investor'] as Map? ?? const {}),
      ),
      transaction: transactionRaw is Map
          ? PartnerDocumentTransaction.fromJson(
              Map<String, dynamic>.from(transactionRaw),
            )
          : null,
    );
  }
}

class PartnerDocumentInvestor {
  final int id;
  final String name;
  final String mobileCountryCode;
  final String mobileNumber;
  final String email;
  final String profilePhoto;

  const PartnerDocumentInvestor({
    this.id = 0,
    this.name = '',
    this.mobileCountryCode = '',
    this.mobileNumber = '',
    this.email = '',
    this.profilePhoto = '',
  });

  String get mobileDisplay {
    final code = mobileCountryCode.trim();
    final number = mobileNumber.trim();
    if (code.isEmpty) return number;
    if (number.isEmpty) return code;
    return '$code $number';
  }

  factory PartnerDocumentInvestor.fromJson(Map<String, dynamic> json) =>
      PartnerDocumentInvestor(
        id: Parse.toInt(json['id']),
        name: Parse.toStrings(json['name']),
        mobileCountryCode: Parse.toStrings(json['mobile_country_code']),
        mobileNumber: Parse.toStrings(json['mobile_number']),
        email: Parse.toStrings(json['email']),
        profilePhoto: Parse.parseUrl(json['profile_photo']),
      );
}

/// Optional Pre-IPO order summary when the file is tied to an order.
class PartnerDocumentTransaction {
  final int id;
  final String invoiceNo;
  final String companyName;
  final String status;

  const PartnerDocumentTransaction({
    this.id = 0,
    this.invoiceNo = '',
    this.companyName = '',
    this.status = '',
  });

  factory PartnerDocumentTransaction.fromJson(Map<String, dynamic> json) =>
      PartnerDocumentTransaction(
        id: Parse.toInt(json['id']),
        invoiceNo: Parse.toStrings(
          json['invoice_no'] ?? json['transaction_invoice_no'],
        ),
        companyName: Parse.toStrings(
          json['company_name'] ??
              json['brand_name'] ??
              (json['company'] is Map
                  ? (json['company']['brand_name'] ?? json['company']['name'])
                  : null),
        ),
        status: Parse.toStrings(json['status']),
      );
}

abstract final class PartnerDocumentStatus {
  static const pendingSignature = 'pending_signature';
  static const expired = 'expired';
  static const signed = 'signed';

  static const all = [pendingSignature, expired, signed];

  static String label(String status) {
    switch (status) {
      case pendingSignature:
        return 'Pending signature';
      case expired:
        return 'Expired';
      case signed:
        return 'Signed';
      default:
        return status.isEmpty ? '—' : status;
    }
  }
}

abstract final class DocumentSendChannel {
  static const whatsapp = 'whatsapp';
  static const email = 'email';
  static const both = 'both';

  static const all = [whatsapp, email, both];

  static String label(String channel) {
    switch (channel) {
      case whatsapp:
        return 'WhatsApp';
      case email:
        return 'Email';
      case both:
        return 'WhatsApp & Email';
      default:
        return channel;
    }
  }
}

abstract final class DocumentSendAction {
  static const resentLink = 'resent_link';
  static const regenerated = 'regenerated';
  static const sentFile = 'sent_file';

  static String toastMessage(String? action) {
    switch (action) {
      case resentLink:
        return 'Existing sign link sent again.';
      case regenerated:
        return 'New sign link generated and sent.';
      case sentFile:
        return 'Document file sent.';
      default:
        return 'Document sent.';
    }
  }
}
