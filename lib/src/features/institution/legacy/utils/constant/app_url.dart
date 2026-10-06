import 'package:private_deals/src/features/institution/data/institution_endpoints.dart';

/// API contracts used by the restored Institution screens.
abstract final class AppUrl {
  static const imageURL =
      'https://s3-ap-south-1.amazonaws.com/privatedeals-main-storage/';
  static const dashboard = InstitutionEndpoints.dashboard;
  static const sellEnquiriesList = 'v2/seller/sell-enquiries/list';
  static const preIPOTransactions =
      'v2/business/institution/pre-ipo/transaction';
  static const profileGet = 'v2/seller/profile';
  static const profileUpdate = 'v2/seller/profile/update';
}
