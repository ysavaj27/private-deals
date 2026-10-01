/// Original Seller API contracts used by the restored screens.
/// These require backend support for the authenticated Institution principal.
abstract final class AppUrl {
  static const imageURL =
      'https://s3-ap-south-1.amazonaws.com/privatedeals-main-storage/';
  static const dashboard = 'v2/seller/dashboard';
  static const sellEnquiriesList = 'v2/seller/sell-enquiries/list';
  static const preIPOTransactions = 'v2/seller/pre-ipo/transaction';
  static const profileGet = 'v2/seller/profile';
  static const profileUpdate = 'v2/seller/profile/update';
}
