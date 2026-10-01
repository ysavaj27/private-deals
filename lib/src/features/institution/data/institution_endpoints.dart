/// This family always uses v2; get-config.current_api_version does not override it.
abstract final class InstitutionEndpoints {
  static const company = 'v2/business/institution/company';
  static const checkCompanyDuplicate = '$company/check-duplicate';
  static const createCompany = company;
  static const sectors = '$company/sectors';
  static const companyList = '$company/list';
  static const companyListLite = '$company/list-lite';
  static const companyDetail = '$company/detail';
  static const mySubmissions = '$company/my-submissions';
  static const addPromoters = '$company/promoters';
  static const addShareHolders = '$company/shareholders';
  static const dealList = '$company/deals';
  static const createDeal = dealList;
  static const updateDeal = '$dealList/update';
  static const deleteDeal = '$dealList/delete';
  static const bulkDeals = '$dealList/bulk';
}
