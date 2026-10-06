import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/models/pre_ipo_order_model.dart';

void main() {
  test('parses order_step driven detail payload', () {
    final order = PreIpoOrderModel.fromJson({
      'id': 481,
      'order_step': 'payment_pending',
      'current': 'Deal slip signed. Payment details sent to the investor.',
      'next': 'Upload the payment receipt.',
      'action': ['view_payment_details', 'upload_payment_receipt'],
      'sign_link': null,
      'investor': {'id': 22, 'name': 'Client Name', 'is_self': 0},
      'company': {
        'id': 12,
        'brand_name': 'Example Co',
        'logo': 'company/logo.png',
      },
      'shares': 10,
      'base_price': '99.00',
      'distributer_price': '100.00',
      'share_price': '102.00',
      'payable_amount': '1020.00',
      'cancellation_reason': null,
      'payment_details': {
        'amount': '1020.00',
        'account': {
          'account_holder_name': 'Institution Self',
          'bank_name': 'HDFC Bank',
          'account_number': '1234567890',
          'ifsc_code': 'HDFC0000123',
        },
      },
      'payment_receipt': null,
      'share_transfer_receipt': null,
    });

    expect(order.isNewFlow, isTrue);
    expect(order.orderStep, 'payment_pending');
    expect(order.hasActionNamed(PreIpoOrderAction.viewPaymentDetails), isTrue);
    expect(order.payableAmount, 1020);
    expect(order.paymentDetails?.account?.ifscCode, 'HDFC0000123');
    expect(order.investor.isSelf, isFalse);
    expect(order.documents, isEmpty);
  });

  test('parses unified documents list while keeping receipt keys', () {
    final order = PreIpoOrderModel.fromJson({
      'id': 965,
      'order_step': 'completed',
      'current': 'Transaction completed.',
      'next': 'N/A',
      'action': null,
      'investor': {'id': 22, 'name': 'Client Name', 'is_self': 0},
      'company': {'id': 12, 'brand_name': 'OYO', 'logo': ''},
      'shares': 10,
      'share_price': '102.00',
      'payable_amount': '1020.00',
      'payment_receipt': {
        'id': 1438,
        'name': 'Payment Receipt - OYO',
        'path': 'preipo_transaction_payment_receipt/receipt.pdf',
        'url':
            'https://example.s3.amazonaws.com/preipo_transaction_payment_receipt/receipt.pdf',
      },
      'share_transfer_receipt': {
        'id': 1439,
        'name': 'Share transfer receipt - OYO',
        'path': 'preipo/transfer.pdf',
        'url': 'https://example.s3.amazonaws.com/preipo/transfer.pdf',
      },
      'documents': [
        {
          'id': 1401,
          'type': 'BuyMandate',
          'name': 'Buy mandate - OYO',
          'path': 'preipo/mandate.pdf',
          'url': 'https://example.s3.amazonaws.com/preipo/mandate.pdf',
        },
        {
          'id': 1410,
          'type': 'Pre-IPO Deal Slip',
          'name': 'Deal slip - OYO',
          'path': 'preipo/deal-slip.pdf',
          'url': 'https://example.s3.amazonaws.com/preipo/deal-slip.pdf',
        },
        {
          'id': 1438,
          'type': 'Payment Receipt',
          'name': 'Payment Receipt - OYO',
          'path': 'preipo_transaction_payment_receipt/receipt.pdf',
          'url':
              'https://example.s3.amazonaws.com/preipo_transaction_payment_receipt/receipt.pdf',
        },
        {
          'id': 1439,
          'type': 'Pre-IPO Share Transfer Receipt',
          'name': 'Share transfer receipt - OYO',
          'path': 'preipo/transfer.pdf',
          'url': 'https://example.s3.amazonaws.com/preipo/transfer.pdf',
        },
      ],
    });

    expect(order.hasDocuments, isTrue);
    expect(order.documents.length, 4);
    expect(order.documents.first.type, PreIpoDocumentType.buyMandate);
    expect(order.documents.first.displayName, 'Buy mandate - OYO');
    expect(order.documents.last.type, PreIpoDocumentType.shareTransferReceipt);
    expect(order.paymentReceipt?.id, 1438);
    expect(order.shareTransferReceipt?.id, 1439);
  });

  test('displayName prefixes [Self] when is_self is set', () {
    final self = PreIpoOrderInvestor.fromJson({
      'id': 1,
      'name': 'SOHAM ROY CHOWDHURY',
      'is_self': 1,
    });
    final other = PreIpoOrderInvestor.fromJson({
      'id': 2,
      'name': 'Client Name',
      'is_self': 0,
    });

    expect(self.displayName, '[Self] SOHAM ROY CHOWDHURY');
    expect(other.displayName, 'Client Name');
  });

  test('skips rows without order_step as old flow', () {
    final order = PreIpoOrderModel.fromJson({
      'id': 1,
      'current_status': 'Processing',
      'status_list': [],
    });
    expect(order.isNewFlow, isFalse);
  });
}
