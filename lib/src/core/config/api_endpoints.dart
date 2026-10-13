class AppUrl {
  static const String baseUrl = String.fromEnvironment(
    'PRIVATE_DEALS_BASE_URL',
    defaultValue: 'https://www.privatedeals.in/',
  );
  static const String baseApiURL = "${baseUrl}api/";

  static String version = "v1/";
  static String newVersion = "v2/";

  static const String imageURL =
      "https://s3-ap-south-1.amazonaws.com/privatedeals-main-storage/";

  static String itDisclosures =
      "${baseUrl}core/documents/investment-disclosures.pdf";

  /// Master / config
  static String sector = "master/get-sector";
  static const String blog = "master/get-blog";
  static String iConfig = "get-config";

  /// Catalog / landing
  static String home = "${version}get-home";
  static String wStartupList = "v2/business/startup/list";
  static String wStartupDetail = "v2/business/startup/detail";
  static String wStartupLite = "${version}business/get-startup-lite";
  static String wPreIPOHome = "v2/business/home/pre-ipo";
  static String wPreIPOCompanyList = "v2/business/company/list";
  static String wPreIPOHomeNewsSector = "v2/business/home/pre-ipo/news-sectors";
  static String wPreIPONewsList = "v2/business/common/preipo-news";
  static String wSecondaryLandingPage = "v2/business/home/secondary";
  static String wCompanyDetail = "${newVersion}business/company/detail";

  /// Investor paths still called from WM UI
  static String iCompanyStartupList = "${version}investor/company-startup-list";
  static String iPitch = "${version}investor/pitch";
  static String iPrimarySellNow =
      "${version}investor/secondary-invest/sell-now";
  static String iUploadPaymentReceipt =
      "${version}investor/primary-invest/upload-payment-receipt";

  /// Partner auth / profile
  static String wLogin = "${version}business/login";
  static String wChangePassword = "${version}business/changepassword";
  static String wLogout = "${version}business/logout";
  static String wForgot = "${version}business/forgot-password";
  static String wResendOtp = "${version}business/forgot-password/resend-otp";
  static String wVerifyOtp = "${version}business/forgot-password/verify-otp";
  static String wForgotChangePass =
      "${version}business/forgot-password/change-password";
  static String wDeleteAccount = "${version}business/delete-account";
  static String wProfileGet = "${version}business/profile";
  static String wProfileSave = "${version}business/profile";
  static String wProfilePhoto = "${newVersion}business/profile";

  /// Dashboard / earnings / ops
  static String wDashboard = "${version}business/dashboard";
  static String wPreIPODashboard = "${version}business/dashboard-pre-ipo";
  static String wInvestorEarning = "v2/business/earning/investor";
  static String wPartnerEarning = "${version}business/earning/partner";
  static String wMis = "${version}business/invested-startup-mis";
  static String wNotification = "${version}business/notifications";
  static String wDocuments = "${newVersion}business/documents";
  static String wDocumentsDownload = "${newVersion}business/documents/download";
  static String wDocumentsSend = "${newVersion}business/documents/send";
  static String wPendingTasks = "${newVersion}business/pending-tasks";

  /// Portfolio
  static String wCompanyStartupList = "${version}business/company-startup-list";
  static String wAddPortfolio = "${version}business/add-portfolio";
  static String wPortfolio = "v2/business/portfolio/startup";
  static String wPreIpoPortfolio = "v2/business/portfolio/pre-ipo";

  /// Investors / KYC / channel partners
  static String wInvestorList = "v2/business/investor";
  static String wAddInvestor = "v2/business/investor";
  static String wUpdateInvestor = "${version}business/investor/update";
  static String wInvestorDetail = "v2/business/investor/detail";
  static String wInvestorKyc = "${version}business/investor-kyc";
  static String wRelationManager = "${version}business/relation-manager";
  static String wChannelPartnerList = "${newVersion}business/channel-partner";
  static String wAddChannelPartner = "${newVersion}business/channel-partner";

  /// Primary transactions
  static String wTransactions = "${version}business/primary-transactions";
  static String wTransaction = "${version}business/primary-invest/transaction";
  static String wPrimaryInvestment =
      "${version}business/primary-invest/invest-now";

  /// Secondary transactions
  static String wShareReceiptApprove =
      "${version}business/secondary-invest/transactions/share-receipt-approve";
  static String wPaymentReceiptUpload =
      "${version}business/secondary-invest/payment-receipt-upload";
  static String wShareReceiptUpload =
      "${version}business/secondary-invest/transactions/share-receipt-upload";
  static String wSecondaryTransaction =
      "${version}business/secondary-invest/transactions/list";
  static String wOpportunitiesStatus =
      "${version}business/secondary-invest/transactions/rofr-status";

  /// Pre-IPO
  static String wPreIpoBuy = "v2/business/pre-ipo/buy";
  static String wNewPreIpoTransaction = "v2/business/pre-ipo/transaction-list";
  static String wPreIpoTransactionDetail =
      "v2/business/pre-ipo/transaction/detail";
  static String wPreIpoTransactionCancel =
      "v2/business/pre-ipo/transaction/cancel";
  static String wPreIpoPaymentReceipt =
      "v2/business/pre-ipo/transaction/payment-receipt";
  static String wPreIpoConfirmShareTransfer =
      "v2/business/pre-ipo/transaction/confirm-share-transfer";
  static String wPreIPOSellNow = "${version}business/pre-ipo/sell";

  /// Enquiries
  static String wEnquiry = "v2/business/enquiries/deals";
}
