import 'package:private_deals/src/core/config/api_endpoints.dart';

/// APIs used by the shared catalog, portfolio and investment/enquiry dialogs.
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
        AppUrl.wPortfolio,
        AppUrl.wPreIpoPortfolio,
        AppUrl.wEnquiry,
      },
      'POST' => {
        AppUrl.wAddInvestor,
        'v2/business/investor/kyc/cml/read',
        'v2/business/investor/kyc/cml/save',
        AppUrl.wPrimaryInvestment,
        AppUrl.wPreIpoBuy,
        AppUrl.wEnquiry,
        '${AppUrl.wEnquiry}/withdraw',
        '${AppUrl.wEnquiry}/reject',
        '${AppUrl.wEnquiry}/accept',
        '${AppUrl.wEnquiry}/accept-counterparty',
        '${AppUrl.wEnquiry}/quotes/accept',
      },
      _ => <String>{},
    };
    return endpoints.contains(path);
  }
}
