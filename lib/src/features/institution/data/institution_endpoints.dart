/// This family always uses v2; get-config.current_api_version does not override it.
abstract final class InstitutionEndpoints {
  static const dashboard = 'v2/business/institution/dashboard';
  static const profile = 'v2/business/institution/profile';
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
  static const companyPricesExcel = '$company/prices/excel';

  static const preIpoTransaction = 'v2/business/institution/pre-ipo/transaction';
  static const preIpoTransactionDetail = '$preIpoTransaction/detail';
  static const preIpoTransactionApprove = '$preIpoTransaction/approve';
  static const preIpoTransactionReject = '$preIpoTransaction/reject';
  static const preIpoPaymentReceipt = '$preIpoTransaction/payment-receipt';
  static const preIpoConfirmPayment = '$preIpoTransaction/confirm-payment';
  static const preIpoShareTransferReceipt =
      '$preIpoTransaction/share-transfer-receipt';
}
