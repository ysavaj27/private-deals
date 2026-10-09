class AppUrl {
  static const String baseUrl = String.fromEnvironment(
    'PRIVATE_DEALS_BASE_URL',
    defaultValue: 'https://www.privatedeals.in/',
  );
  static const String baseApiURL = "${baseUrl}api/";

  static String pinCodeToAddress(int pinCode) =>
      "https://api.postalpincode.in/pincode/$pinCode";

  // static String version = "${app.config.currentApiVersion}/";

  static String version = "v1/";
  static String newVersion = "v2/";

  // static String imageURL = masterConfig.config.s3Baseurl;

  static const String imageURL =
      "https://s3-ap-south-1.amazonaws.com/privatedeals-main-storage/";

  /// INVESTOR APIS ("i" for investor)

  /// AUTH

  static String itDisclosures =
      "${baseUrl}core/documents/investment-disclosures.pdf";

  static String iLogin = "${version}investor/login";

  // static String iChangePassword = "${version}investor/change-password";
  static String iRegisterInquiry = "${version}investor/register-inquiry";
  static String iDeleteAccount = "${version}investor/delete-account";
  static String iLogout = "${version}investor/logout";
  static String iForgot = "${version}investor/forgot";
  static String iResendOtp = "${version}investor/forgot/resend-otp";
  static String iVerifyOtp = "${version}investor/forgot/verify-otp";
  static String iForgotChangePass = "${version}investor/forgot/change-password";
  static String iSwitchProfile = "${version}investor/profile/switch-profile";
  static String verifyMobileNumber = "verify-mobile-number";

  /// PROFILE

  static String iProfileGet = "${version}investor/profile/get";
  static String iProfileSave = "${version}investor/profile/save";
  static String iProfilePhotoUpdate = "${version}investor/profile/photo";
  static String iProfilePhotoRemove = "${version}investor/profile/photo-remove";
  static String iAifSubmit = "${version}investor/aif/submit";
  static String iAifGet = "${version}investor/aif/get";

  /// GUEST
  // static String iHome = version + "investor/home";
  // static String iStartupDetail = version + "investor/startup";
  // static String iStartupList = version + "investor/startup-list";

  // static String wHome = "${version}business/home";
  // static String wStartupDetail = "${version}business/startup";
  // static String wStartupList = "${version}business/startup-list";

  /// MASTER
  static const String country = "master/get-country";
  static const String state = "master/get-state";
  static const String city = "master/get-city";
  static String sector = "master/get-sector";
  static String cityData = "master/city-to-data";
  static const String iFamilyRelation = "master/get-familyrelation";
  static const String blog = "master/get-blog";
  static String iConfig = "get-config";

  /// WITH AUTH
  static String startupList = "${version}get-startup-list";
  static String wStartupList = "v2/business/startup/list";
  static String startupDetail = "${version}get-startup";
  static String wStartupDetail = "v2/business/startup/detail";
  static String home = "${version}get-home";
  static String iCompanyStartupList = "${version}investor/company-startup-list";
  static String iAddPortfolio = "${version}investor/add-portfolio";

  // static String iAuthStartupList = "${version}investor/auth/startup-list";
  // static String iAuthStartupDetail = "${version}investor/auth/startup";
  // static String iAuthHome = "${version}investor/auth/home";
  static String iSecondaryMarket = "${version}investor/secondary-invest/market";

  static String iDashboard = "${version}investor/dashboard";
  static String iPreIpoDashboard = "${version}investor/dashboard-pre-ipo";
  static String iDemat = "${version}investor/demat";
  static String iFavorites = "${version}investor/favorite";
  static String iFamily = "${version}investor/family";
  static String iPitch = "${version}investor/pitch";

  // static String iEKycToken = "${version}investor/kyc/get-ekyc-token";
  // static String iEKycData = "${version}investor/kyc/get-ekyc-data";
  static String iKyc = "${version}investor/kyc";
  static String iPortfolio = "${version}investor/portfolio";
  static String iPreIpoPortfolio = "${version}investor/portfolio-pre-ipo";
  static String iBankMandate = "${version}investor/bank-mandate";
  static String iMis = "${version}investor/mis";
  static String wMis = "${version}business/invested-startup-mis";
  static String iDocument = "${version}investor/document";
  static String iNotification = "${version}investor/notification";

  static String iTransactionList =
      "${version}investor/primary-transaction-list";
  static String iTransaction = "${version}investor/primary-invest/transaction";
  static String wTransaction = "${version}business/primary-invest/transaction";
  static String primaryInvestment =
      "${version}investor/primary-invest/invest-now";
  static String wPrimaryInvestment =
      "${version}business/primary-invest/invest-now";
  static String iUploadPaymentReceipt =
      "${version}investor/primary-invest/upload-payment-receipt";

  /// secondary transaction

  static String iPrimarySellNow =
      "${version}investor/secondary-invest/sell-now";
  static String iPreIPOSellNow = "${version}investor/pre-ipo/sell";
  static String iBuyNow = "${version}investor/secondary-invest/buy-now";
  static String iStartupLite = "${version}investor/get-startup-lite";
  static String iShareReceiptApprove =
      "${version}investor/secondary-invest/transactions/share-receipt-approve";
  static String iPaymentReceiptUpload =
      "${version}investor/secondary-invest/payment-receipt-upload";
  static String iShareReceiptUpload =
      "${version}investor/secondary-invest/transactions/share-receipt-upload";
  static String iSecondaryTransaction =
      "${version}investor/secondary-invest/transactions/list";
  static String iSellRequestList =
      "${version}investor/secondary-invest/sell-request";
  static String iOpportunitiesList =
      "${version}investor/secondary-invest/related-oppotunities";
  static String iOpportunitiesStatus =
      "${version}investor/secondary-invest/transactions/rofr-status";

  static String iCompanyList = "${version}investor/company/market";
  static String iCompanyDetail = "${version}investor/company/detail";
  static String iPreIpoBuy = "${version}investor/pre-ipo/buy";
  static String iPreIpoTransaction = "${version}investor/pre-ipo/transaction";
  static String iPreIpoSellTransaction =
      "${version}investor/pre-ipo/sell-transaction";

  /// WEALTH-MANAGER APIS ("w" for wealth-manager)

  static String wLogin = "${version}business/login";
  static String wChangePassword = "${version}business/changepassword";
  static String wLogout = "${version}business/logout";
  static String wForgot = "${version}business/forgot-password";
  static String wResendOtp = "${version}business/forgot-password/resend-otp";
  static String wVerifyOtp = "${version}business/forgot-password/verify-otp";
  static String wInvestorKyc = "${version}business/investor-kyc";
  static String wForgotChangePass =
      "${version}business/forgot-password/change-password";
  static String wDeleteAccount = "${version}business/delete-account";

  /// Session restore / legacy partner profile (v1).
  static String wProfileGet = "${version}business/profile";
  static String wProfileSave = "${version}business/profile";

  /// Display-photo screen for every partner role (v2).
  static String wProfilePhoto = "${newVersion}business/profile";
  static String wAifGet = "${version}business/aif/get";
  static String wAifSubmit = "${version}business/aif/submit";

  // static String wProfilePhotoUpdate = version + "investor/profile/photo";
  // static String wProfilePhotoRemove = version + "investor/profile/photo-remove";

  static String wDashboard = "${version}business/dashboard";
  static String wPreIPODashboard = "${version}business/dashboard-pre-ipo";

  static String wInvestorEarning = "${version}business/earning/investor";
  static String wPartnerEarning = "${version}business/earning/partner";
  static String wCompanyStartupList = "${version}business/company-startup-list";

  static String wInvestorList = "v2/business/investor";
  static String wAddInvestor = "v2/business/investor";
  static String wRelationManager = "${version}business/relation-manager";
  static String wUpdateInvestor = "${version}business/investor/update";

  static String wChannelPartnerList = "${newVersion}business/channel-partner";
  static String wAddChannelPartner = "${newVersion}business/channel-partner";

  static String wNotification = "${version}business/notifications";
  static String wDocument = "${version}business/document";
  static String wSendDocument = "${version}business/send-document";
  static String wTransactions = "${version}business/primary-transactions";
  static String wPendingTasks = "${version}business/pending-tasks";
  static String wAddPortfolio = "${version}business/add-portfolio";
  static String wStartupLite = "${version}business/get-startup-lite";

  static String wPreIpoBuy = "v2/business/pre-ipo/buy";
  static String wPreIpoTransaction = "${version}business/pre-ipo/transaction";
  static String wNewPreIpoTransaction = "v2/business/pre-ipo/transaction-list";
  static String wPreIpoTransactionDetail =
      "v2/business/pre-ipo/transaction/detail";
  static String wPreIpoTransactionCancel =
      "v2/business/pre-ipo/transaction/cancel";
  static String wPreIpoPaymentReceipt =
      "v2/business/pre-ipo/transaction/payment-receipt";
  static String wPreIpoConfirmShareTransfer =
      "v2/business/pre-ipo/transaction/confirm-share-transfer";
  static String wCompanyList = "${version}business/company/market";
  static String wCompanyDetail = "${newVersion}business/company/detail";

  static String wSecondaryMarket = "${version}business/secondary-invest/market";
  static String wSellNow = "${version}business/secondary-invest/sell-now";
  static String wBuyNow = "${version}business/secondary-invest/buy-now";
  static String wPreIPOSellNow = "${version}business/pre-ipo/sell";
  static String wPreIpoSellTransaction =
      "${version}business/pre-ipo/sell-transaction";
  static String wShareReceiptApprove =
      "${version}business/secondary-invest/transactions/share-receipt-approve";
  static String wPaymentReceiptUpload =
      "${version}business/secondary-invest/payment-receipt-upload";
  static String wShareReceiptUpload =
      "${version}business/secondary-invest/transactions/share-receipt-upload";
  static String wSecondaryTransaction =
      "${version}business/secondary-invest/transactions/list";
  static String wSellRequestList =
      "${version}business/secondary-invest/sell-request";
  static String wOpportunitiesList =
      "${version}business/secondary-invest/related-oppotunities";
  static String wOpportunitiesStatus =
      "${version}business/secondary-invest/transactions/rofr-status";
  static String wPortfolio = "v2/business/portfolio/startup";
  static String wPreIpoPortfolio = "v2/business/portfolio/pre-ipo";
  static String wInvestorDetail = "v2/business/investor/detail";

  static String wPreIPOHome = "v2/business/home/pre-ipo";
  static String wPreIPOCompanyList = "v2/business/company/list";
  static String wPreIPOHomeNewsSector = "v2/business/home/pre-ipo/news-sectors";
  static String wPreIPONewsList = "v2/business/common/preipo-news";
  static String wSecondaryLandingPage = "v2/business/home/secondary";
  static String wEnquiry = "v2/business/enquiries/deals";
  // static const String wPendingTasks = "wealth-manager/dashboard/pending-tasks";
  // static const String wPendingKYC =
  //     "wealth-manager/dashboard/pending-tasks/kyc";
  // static const String wPendingDocument =
  //     "wealth-manager/dashboard/pending-tasks/document-sign";
  // static const String wPendingFundTransfer =
  //     "wealth-manager/dashboard/pending-tasks/fund-transfer";
  // static const String wPendingKYCUpdate =
  //     "wealth-manager/dashboard/pending-tasks/kyc-save";
  // static const String wDistributors = "wealth-manager/dashboard/distributors";
  // static const String wAddDistributor = "wealth-manager/dashboard/distributors";
  // static const String wRetailers = "wealth-manager/dashboard/retailers";
  // static const String wAddRetailer = "wealth-manager/dashboard/retailers";
}
