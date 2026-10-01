// enum AuctionStatusType {
//   ended(status: -1, color: AppColors.lightPrimary),
//   ideal(status: 0, color: Colors.white),
//   current(status: 1, color: Colors.green),
//   upcoming(status: 2, color: Colors.yellow);
//
//   const AuctionStatusType({this.status = 0, this.color = Colors.white});
//
//   final int status;
//   final Color color;
// }

enum IndustryEnum { technology, finance }

enum LandingEnum { home, invest, notification }

enum StartupDetailEnum {
  idea,
  keyInfo,
  team,
  updates,
  investor,
  faq,
  meet,
  documents,
  // market,
}

enum SignUpEnum { mobileNo, otp, password }

enum ShareTypeEnum { None, Equity, CCPS, CCD, Eshop, Male }

enum PersonTypeEnum { None, Founder, Investor, Employee, VC, Angel }

enum GenderTypeEnum { Male, Female, Other }

enum ForgotPassEnum { mobile, otp, password }

enum AccountVisibilityEnum { public, name, private }

enum PayReceiptTypeEnum { Physical, Demat, None }

enum EquityTypeEnum { equity, ccps, ccd, preIpo }

enum DashboardTypeEnum { primary, preIpo }

enum TransactionTypeEnum { primary, secondary, preIpoBuy, preIpoSell }

enum MyEarningTypeEnum { investor, channelPartner }

enum LivePitchEnum { upcoming, completed }

enum GradientEnum { centerTopBottom, bottomRightToTopLeft }

// enum PartnerTypeEnum { distributors, retailer }

enum FilterTypeEnum { All, Yes, No }

enum PrimaryInvestmentType { Captable, AIF }

enum StartupStatusEnum { pending, raisingnow, completed, comingsoon }

enum ITabBarEnum {
  dashboard,
  favorites,
  transactions,
  secondaryTransactions,
  portfolio,
  mis,
  livePitch,
  // bankMandates,
  myFamily,
  documents,
  sellRequests,
  buyRequests,
  notifications,
  logout,
  primary,
  secondary,
  preIPO,
  profile,
  uploadPortfolio,
}

enum WTabBarEnum {
  investors,
  dashboard,
  transactions,
  sendDocuments,
  primaryList,
  secondaryList,
  companyDeals,
  secondaryDeals,
  sellEnquiries,
  preIPOList,
  profile,
  priceUpdate,
  changePassword,
  preIPOTransactions,
  secondaryTransactions,
}

enum ActionEnum { share, edit, delete }

enum MessageEnum { info, success, error, alert }

enum FileDataType { url, filePath, bytes, none }

enum PaymentTypeEnum { none, mandate, rtgs, cheque }

enum KycStatusEnum { pending, approve, approvalPending, rejected }

enum KycTypeEnum { manual, eKyc, none }

enum PendingTaskEnum { aif, kyc, document, fundTransfer }

enum MenuItemEnum {
  dashboard,
  profile,
  manageBankAccounts,
  kyc,
  changePassword,
  dematAccount,
  logout,
  deleteAccount,
  switchUser,
  none,
}

// enum FileType { any, image }

enum UserType { investor, distributor, startup }
// distributor

enum UnListedShareCategoryEnum {
  trending,
  comingSoon,
  exclusiveDeals,
  liquidStocks,
  listed,
  drhpFiled,
  aToZ,
}

enum InvestmentTypeEnum { buy, sell, inquiry, none }

enum CompanyType { unlisted, secondary, all }

extension UnListedShareCategoryEnumX on UnListedShareCategoryEnum {
  String get label {
    switch (this) {
      case UnListedShareCategoryEnum.trending:
        return 'Trending';
      case UnListedShareCategoryEnum.comingSoon:
        return 'Coming Soon';
      case UnListedShareCategoryEnum.exclusiveDeals:
        return 'Exclusive Deals';
      case UnListedShareCategoryEnum.liquidStocks:
        return 'Liquid Stocks';
      case UnListedShareCategoryEnum.listed:
        return 'Listed';
      case UnListedShareCategoryEnum.drhpFiled:
        return 'DRHP Filed';
      case UnListedShareCategoryEnum.aToZ:
        return 'A to Z';
    }
  }

  String get route {
    switch (this) {
      case UnListedShareCategoryEnum.trending:
        return 'trending';
      case UnListedShareCategoryEnum.comingSoon:
        return 'coming-soon';
      case UnListedShareCategoryEnum.exclusiveDeals:
        return 'exclusive-deals';
      case UnListedShareCategoryEnum.liquidStocks:
        return 'liquid-stocks';
      case UnListedShareCategoryEnum.listed:
        return 'listed';
      case UnListedShareCategoryEnum.drhpFiled:
        return 'drhp';
      case UnListedShareCategoryEnum.aToZ:
        return 'all';
    }
  }

  String get apiCategory {
    switch (this) {
      case UnListedShareCategoryEnum.trending:
        return 'Trending';
      case UnListedShareCategoryEnum.comingSoon:
        return 'Coming Soon';
      case UnListedShareCategoryEnum.exclusiveDeals:
        return 'Exclusive Deals';
      case UnListedShareCategoryEnum.liquidStocks:
        return 'Liquid Stocks';
      case UnListedShareCategoryEnum.listed:
        return 'Listed';
      case UnListedShareCategoryEnum.drhpFiled:
        return 'DRHP';
      case UnListedShareCategoryEnum.aToZ:
        return 'All';
    }
  }

  static UnListedShareCategoryEnum? fromRoute(String route) {
    for (final tab in UnListedShareCategoryEnum.values) {
      if (tab.route == route) {
        return tab;
      }
    }
    return null;
  }
}

extension CompanyTypeEnumX on CompanyType {
  String get value {
    switch (this) {
      case CompanyType.all:
        return 'All';
      case CompanyType.unlisted:
        return 'unlisted';
      case CompanyType.secondary:
        return 'secondary';
    }
  }
}
