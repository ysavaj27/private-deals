import 'package:private_deals/src/shared/app_exports.dart';

enum AuctionStatusType {
  ended(status: -1, color: AppColors.lightPrimary),
  ideal(status: 0, color: Colors.white),
  current(status: 1, color: Colors.green),
  upcoming(status: 2, color: Colors.yellow);

  const AuctionStatusType({this.status = 0, this.color = Colors.white});

  final int status;
  final Color color;
}

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
  dashboard,
  investorTransactions,
  myEarnings,
  profile,
  investors,
  pendingTasks,
  // pendingTasks,
  sendDocuments,
  channelPartner,
  notifications,
  primary,
  secondary,
  preIPO,
  logout,
  mis,
  uploadPortfolio,
  changePassword,
  portfolio,
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

enum UnListedShareTabEnum {
  trending,
  hotDeals,
  exclusiveDeals,
  liquidStocks,
  drhpFiled,
  aToZ,
}

enum InvestmentTypeEnum { buy, sell, inquiry,none }

extension UnListedShareTabEnumX on UnListedShareTabEnum {
  String get label {
    switch (this) {
      case UnListedShareTabEnum.hotDeals:
        return 'Hot Deals';
      case UnListedShareTabEnum.trending:
        return 'Trending';
      case UnListedShareTabEnum.exclusiveDeals:
        return 'Exclusive';
      case UnListedShareTabEnum.liquidStocks:
        return 'Liquid Stocks';
      case UnListedShareTabEnum.drhpFiled:
        return 'DRHP Filed';
      case UnListedShareTabEnum.aToZ:
        return 'A to Z';
    }
  }

  String get route {
    switch (this) {
      case UnListedShareTabEnum.hotDeals:
        return 'hot-deals';
      case UnListedShareTabEnum.trending:
        return 'trending';
      case UnListedShareTabEnum.exclusiveDeals:
        return 'exclusive-deals';
      case UnListedShareTabEnum.liquidStocks:
        return 'liquid-stocks';
      case UnListedShareTabEnum.drhpFiled:
        return 'drhp';
      case UnListedShareTabEnum.aToZ:
        return 'all';
    }
  }

  String get apiCategory {
    switch (this) {
      case UnListedShareTabEnum.hotDeals:
        return 'Hot Deals';
      case UnListedShareTabEnum.trending:
        return 'Trending';
      case UnListedShareTabEnum.exclusiveDeals:
        return 'Exclusive Deals';
      case UnListedShareTabEnum.liquidStocks:
        return 'Liquid Stocks';
      case UnListedShareTabEnum.drhpFiled:
        return 'DRHP';
      case UnListedShareTabEnum.aToZ:
        return 'All';
    }
  }

  static UnListedShareTabEnum? fromRoute(String route) {
    for (final tab in UnListedShareTabEnum.values) {
      if (tab.route == route) {
        return tab;
      }
    }
    return null;
  }
}
