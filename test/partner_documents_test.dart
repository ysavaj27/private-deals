import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/document/partner_document_model.dart';
import 'package:private_deals/src/shared/models/config_model.dart';

void main() {
  group('DocumentType from get-config', () {
    test('parses map values as filter options without hardcoding', () {
      final types = DocumentType.fromJson({
        'BuyMandate': 'BuyMandate',
        'SellMandate': 'SellMandate',
        'deal_slip': 'Pre-IPO Deal Slip',
        'payment': 'Payment Receipt',
        'share_transfer': 'Pre-IPO Share Transfer Receipt',
        'cmr': 'Client Master Report',
      });

      expect(types.options, hasLength(6));
      expect(types.values, containsAll([
        'BuyMandate',
        'SellMandate',
        'Pre-IPO Deal Slip',
        'Payment Receipt',
        'Pre-IPO Share Transfer Receipt',
        'Client Master Report',
      ]));
      expect(types.values, isNot(contains('ssa')));
      expect(types.values, isNot(contains('PAN')));
    });

    test('parses list of strings', () {
      final types = DocumentType.fromJson([
        'BuyMandate',
        'SellMandate',
        'Client Master Report',
      ]);
      expect(types.values, [
        'BuyMandate',
        'SellMandate',
        'Client Master Report',
      ]);
    });
  });

  group('PartnerDocumentModel', () {
    test('shows investor always and null transaction for Client Master Report', () {
      final doc = PartnerDocumentModel.fromJson({
        'id': 12,
        'type': 'Client Master Report',
        'name': 'CMR - Ada',
        'status': 'signed',
        'sign_link': null,
        'investor': {
          'id': 70,
          'name': 'Ada Lovelace',
          'mobile_country_code': '+91',
          'mobile_number': '9000000000',
          'email': 'ada@example.com',
          'profile_photo': '',
        },
        'transaction': null,
      });

      expect(doc.investor.name, 'Ada Lovelace');
      expect(doc.investor.mobileDisplay, '+91 9000000000');
      expect(doc.transaction, isNull);
      expect(doc.isSigned, isTrue);
      expect(doc.hasOpenSignLink, isFalse);
    });

    test('keeps sign link while pending signature', () {
      final doc = PartnerDocumentModel.fromJson({
        'id': 9,
        'type': 'BuyMandate',
        'status': 'pending_signature',
        'sign_link': 'https://digio.example/sign/abc',
        'investor': {'id': 1, 'name': 'Investor'},
        'transaction': {
          'id': 55,
          'invoice_no': 'INV-1',
          'company_name': 'OYO',
          'status': 'pending',
        },
      });

      expect(doc.transaction?.companyName, 'OYO');
      expect(doc.hasOpenSignLink, isTrue);
      expect(doc.signLink, contains('digio'));
    });
  });

  group('DocumentSendAction', () {
    test('maps channel send actions to toasts', () {
      expect(
        DocumentSendAction.toastMessage('resent_link'),
        'Existing sign link sent again.',
      );
      expect(
        DocumentSendAction.toastMessage('regenerated'),
        'New sign link generated and sent.',
      );
      expect(
        DocumentSendAction.toastMessage('sent_file'),
        'Document file sent.',
      );
    });
  });
}
