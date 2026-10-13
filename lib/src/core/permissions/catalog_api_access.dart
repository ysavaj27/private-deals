import 'package:private_deals/src/core/config/api_endpoints.dart';

/// APIs used by the shared catalog and its investment/enquiry dialogs.
/// Seller pages keep using these endpoints; unrelated business operations
/// remain protected by their existing workspace policy.
class CatalogApiAccess {
  static bool supportsInstitution(String method, String path) {
    final endpoints = switch (method) {
      'GET' => {
        AppUrl.wStartupList,
        AppUrl.wStartupDetail,
        AppUrl.wStartupLite,
        AppUrl.wPreIPOHome,
        AppUrl.wPreIPOCompanyList,
        AppUrl.wPreIPOHomeNewsSector,
        AppUrl.wPreIPONewsList,
        AppUrl.wSecondaryLandingPage,
        AppUrl.wCompanyDetail,
        AppUrl.wInvestorList,
        AppUrl.wInvestorDetail,
        AppUrl.wTransaction,
      },
      'POST' => {
        AppUrl.wAddInvestor,
        'v2/business/investor/kyc/cml/read',
        'v2/business/investor/kyc/cml/save',
        AppUrl.wPrimaryInvestment,
        AppUrl.wPreIpoBuy,
        AppUrl.wEnquiry,
      },
      _ => <String>{},
    };
    return endpoints.contains(path);
  }
}
