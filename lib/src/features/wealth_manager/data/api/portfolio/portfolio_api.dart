import 'package:private_deals/src/shared/app_exports.dart';

class PortfolioApi {
  static Future<BaseModel<List<StartupPortfolioListModel>>> wPortfolioAPi(
    String type,
    List<int> investors,
    List<int> startups,
  ) async {
    try {
      Map<String, dynamic> body = {"type": type};
      body.addIf(investors.isNotEmpty, 'investor_ids', investors.join(","));
      body.addIf(startups.isNotEmpty, 'startup_ids', startups.join(","));
      var res = await dioConfig.get(AppUrl.wPortfolio, body);
      logger.d(res.data);
      BaseModel<List<StartupPortfolioListModel>> baseModel =
          BaseModel.fromListJson(
            res.data,
            (p0) =>
                p0.map((e) => StartupPortfolioListModel.fromJson(e)).toList(),
          );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Config", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<List<PreIPOPortfolioListModel>>> wPreIpoPortfolioAPi(
    List<int> investors,
  ) async {
    try {
      Map<String, dynamic> body = {};

      body.addIf(investors.isNotEmpty, 'investor_ids', investors.join(','));
      var res = await dioConfig.get(AppUrl.wPreIpoPortfolio, {});
      BaseModel<List<PreIPOPortfolioListModel>> baseModel =
          BaseModel.fromListJson(
            res.data,
            (p0) =>
                p0.map((e) => PreIPOPortfolioListModel.fromJson(e)).toList(),
          );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Unlisted Shares list", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  static Future<BaseModel<CompanyStartupModel>> getCompanyStartupApi() async {
    try {
      var res = await dioConfig.get(
        app.userType == UserType.investor
            ? AppUrl.iCompanyStartupList
            : AppUrl.wCompanyStartupList,
        {},
      );
      BaseModel<CompanyStartupModel> baseModel = BaseModel.fromJson(
        res.data,
        (p0) => CompanyStartupModel.fromJson(p0),
      );
      return baseModel;
    } catch (e, t) {
      logger.e("Error on Company StartUp", error: e, stackTrace: t);
      return BaseModel.fromError(e.toString());
    }
  }

  /// Partner upload of one unlisted-company holding.
  ///
  /// [companyId] identifies a company already on the platform. When it is
  /// omitted, [otherName] is the custom company name. Startup holdings are
  /// not accepted by this endpoint.
  static Future<BaseModel<void>> wAddPortfolioApi({
    required int investorId,
    int? companyId,
    String otherName = "",
    required int shares,
    required double sharePrice,
    String date = "",
  }) => Analytics.trackRequest(
    "portfolio_add",
    params: {
      "asset_type": "company",
      if (companyId != null && companyId > 0) "company_id": companyId,
    },
    request: () async {
      if (app.userType == UserType.investor) {
        return BaseModel.fromError(
          "Portfolio upload is only available in the partner portal.",
        );
      }
      final knownCompany = companyId != null && companyId > 0;
      final customName = otherName.trim();
      if (investorId <= 0) {
        return BaseModel.fromError("Select an investor");
      }
      if (!knownCompany && customName.isEmpty) {
        return BaseModel.fromError("Enter a company name");
      }
      if (shares < 1) {
        return BaseModel.fromError("Enter at least 1 share");
      }
      if (!sharePrice.isFinite || sharePrice < 0.01) {
        return BaseModel.fromError("Enter a price of at least 0.01");
      }
      final purchaseDate = date.trim();
      if (purchaseDate.isNotEmpty &&
          !RegExp(r"^\d{2}-\d{2}-\d{4}$").hasMatch(purchaseDate)) {
        return BaseModel.fromError("Enter the date as DD-MM-YYYY");
      }
      try {
        final body = <String, dynamic>{
          "investor_id": investorId,
          "type": "company",
          "shares": shares,
          "share_price": sharePrice,
        };
        if (knownCompany) {
          body["company_id"] = companyId;
        } else {
          body["other_name"] = customName;
        }
        if (purchaseDate.isNotEmpty) body["date"] = purchaseDate;

        var res = await dioConfig.post(AppUrl.wAddPortfolio, body);
        return BaseModel<void>.fromMessage(res.data);
      } catch (e, t) {
        logger.e("Error on Add portfolio", error: e, stackTrace: t);
        return BaseModel.fromError(e.toString());
      }
    },
  );
}
