import 'package:private_deals/src/core/config/api_endpoints.dart';

/// Static app config formerly loaded from `GET /api/get-config`.
/// Only fields consumed by [ConfigModel] / `app.config` are kept.
///
/// Env-specific value: `s3-baseurl` = [AppUrl.imageURL], same dart-defines /
/// `tools/env/*.json` as [AppUrl.baseUrl]. Enums and settlement days are
/// identical across staging, live, and demo.
final Map<String, dynamic> kStaticAppConfig = {
  's3-baseurl': AppUrl.imageURL,
  'pre_ipo_min_sell_amount': 50000,
  'settlement_days': [
    for (var i = 1; i <= 30; i++) {'value': i, 'label': 'T+$i'},
  ],
  'enum': {
    'gender': {
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
    },
    'document_type': {
      'buymandate': 'BuyMandate',
      'sellmandate': 'SellMandate',
      'preipodealslip': 'Pre-IPO Deal Slip',
      'paymentreceipt': 'Payment Receipt',
      'preiposharetransferreceipt': 'Pre-IPO Share Transfer Receipt',
      'clientmaster': 'Client Master Report',
    },
    'instrument_type': {
      'equity': 'equity',
      'ccps': 'ccps',
      'ccd': 'ccd',
    },
    'investor_profile_visibility': {
      'public': 'Public',
      'nameonly': 'Name Only',
      'Private': 'Private',
    },
    'partner_type': {
      'wealthmanager': 'Wealth Manager',
      'distributor': 'Distributor',
      'retailer': 'Retailer',
      'relationmanager': 'Relation Manager',
      'institution': 'Institution',
    },
    'primary_transaction_payment_mode': {
      'rtgs': 'RTGS',
      'cheque': 'Cheque',
      'mandate': 'Mandate',
    },
    'min_investment_type': {
      'quantity': 'Quantity',
      'amount': 'Amount',
    },
    'startup_primary_round_status': {
      'pending': 'Pending',
      'comingsoon': 'Coming Soon',
      'raisingnow': 'Raising Now',
      'completed': 'Completed',
    },
    'status': {
      'pending': 'pending',
      'approved': 'approved',
      'rejected': 'rejected',
    },
    'preipo_category': {
      'trending': 'Trending',
      'coming_soon': 'Coming Soon',
      'exclusive_deals': 'Exclusive Deals',
      'listed': 'Listed',
      'liquid_stocks': 'Liquid Stocks',
      'drhp': 'DRHP',
    },
  },
};
