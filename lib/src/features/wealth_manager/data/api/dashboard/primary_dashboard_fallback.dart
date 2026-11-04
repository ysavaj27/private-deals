import 'package:private_deals/src/core/config/master_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/w_investor_model.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/api/portfolio/portfolio_api.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/dashboard/w_dashboard_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/portfolio/portfolio_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/sector/sector_model.dart';

/// Builds the Private Equity dashboard from the equity portfolio.
///
/// `GET v1/business/dashboard` returns HTTP 500 once startup holdings exist.
/// The portfolio list for those same holdings still succeeds, so the overview
/// can be shown from that list until the dashboard endpoint is fixed.
class PrimaryDashboardFallback {
  static Future<WDashboardModel?> load() async {
    final portfolio = await PortfolioApi.wPortfolioAPi('equity', const [], const []);
    if (!portfolio.isSuccess || portfolio.r == null) return null;
    final groups = portfolio.r!;
    if (groups.every((group) => group.holdings.isEmpty)) return null;

    final sectors = await MasterApi.sectorList();
    final investors = await WInvestorsApi.investorsList(
      isKyc: 'All',
      isActive: 'All',
      isAif: 'All',
    );
    return fromPortfolio(
      groups,
      sectorNames: {
        for (final sector in sectors.r ?? const <SectorModel>[])
          if (sector.id > 0 && sector.name.trim().isNotEmpty)
            sector.id: sector.name.trim(),
      },
      directory: investors.r ?? const [],
    );
  }

  static WDashboardModel fromPortfolio(
    List<StartupPortfolioListModel> groups, {
    Map<int, String> sectorNames = const {},
    List<InvestorModel> directory = const [],
  }) {
    final holdings = [
      for (final group in groups) ...group.holdings,
    ];
    final invested = holdings.fold<double>(
      0,
      (sum, holding) => sum + _invested(holding),
    );
    final startupIds = holdings
        .map((holding) => holding.startupId > 0
            ? 'id:${holding.startupId}'
            : 'name:${holding.startup.brandName.trim().toLowerCase()}')
        .where((id) => id != 'name:')
        .toSet();
    final people = _investors(groups, holdings);
    final growth = _growth(holdings);
    return WDashboardModel(
      totalStartups: startupIds.length,
      totalInvestors: people.length,
      totalAmountInvested: invested,
      averageTicketSize: holdings.isEmpty ? 0 : invested / holdings.length,
      investors: people,
      topInvestors: people,
      sectors: _sectors(holdings, sectorNames),
      investmentGrowth: growth,
      investments: _timeline(holdings),
      investorChartModel: _chart(people, directory),
    );
  }

  static double _invested(PortfolioModel holding) {
    if (holding.investmentAmount > 0) return holding.investmentAmount;
    return holding.shares * holding.purchasePrice;
  }

  static bool _hasValue(PortfolioModel holding) =>
      holding.reportedCurrentValue != null || holding.currentSharePrice > 0;

  static List<WInvestorModel> _investors(
    List<StartupPortfolioListModel> groups,
    List<PortfolioModel> holdings,
  ) {
    final people = <WInvestorModel>[];
    for (final group in groups) {
      final rows = group.holdings;
      if (rows.isEmpty && group.totalInvestmentAmount <= 0) continue;
      final amount = rows.isEmpty
          ? group.totalInvestmentAmount
          : rows.fold<double>(0, (sum, row) => sum + _invested(row));
      final startups = rows
          .map((row) => row.startupId)
          .where((id) => id > 0)
          .toSet()
          .length;
      people.add(
        WInvestorModel(
          investorId: group.investor.id,
          name: group.investor.name,
          profilePhoto: group.investor.profilePhoto,
          totalStartups: startups > 0 ? startups : group.totalCompanyCount,
          amountInvested: amount,
        ),
      );
    }
    if (people.isEmpty) {
      final byInvestor = <int, List<PortfolioModel>>{};
      for (final holding in holdings) {
        byInvestor.putIfAbsent(holding.investorId, () => []).add(holding);
      }
      for (final entry in byInvestor.entries) {
        final rows = entry.value;
        people.add(
          WInvestorModel(
            investorId: entry.key,
            name: rows.first.investor.name,
            totalStartups: rows.map((row) => row.startupId).toSet().length,
            amountInvested: rows.fold<double>(
              0,
              (sum, row) => sum + _invested(row),
            ),
          ),
        );
      }
    }
    people.sort((a, b) => b.amountInvested.compareTo(a.amountInvested));
    return people;
  }

  static List<WSector> _sectors(
    List<PortfolioModel> holdings,
    Map<int, String> sectorNames,
  ) {
    final grouped = <int, List<PortfolioModel>>{};
    for (final holding in holdings) {
      final id = holding.startup.sector.id > 0
          ? holding.startup.sector.id
          : holding.startup.sectorId;
      grouped.putIfAbsent(id, () => []).add(holding);
    }
    final sectors = [
      for (final entry in grouped.entries)
        WSector(
          id: entry.key,
          name: _sectorName(entry.key, entry.value, sectorNames),
          totalInvestment: entry.value.fold<double>(
            0,
            (sum, row) => sum + _invested(row),
          ),
          startups: [
            for (final holding in entry.value)
              WStartup(
                startupId: holding.startupId,
                startupName: holding.startup.brandName,
                investorName: holding.investor.name.isNotEmpty
                    ? holding.investor.name
                    : '',
                investmentAmount: _invested(holding),
                currentValue: holding.totalCurrentPrice,
                purchasePrice: holding.purchasePrice,
                shares: holding.shares,
                createdAt: holding.createdAt,
              ),
          ],
        ),
    ]..sort((a, b) => b.totalInvestment.compareTo(a.totalInvestment));
    return sectors;
  }

  static String _sectorName(
    int id,
    List<PortfolioModel> holdings,
    Map<int, String> sectorNames,
  ) {
    final fromMaster = sectorNames[id];
    if (fromMaster != null && fromMaster.isNotEmpty) return fromMaster;
    for (final holding in holdings) {
      final name = holding.startup.sector.name.trim();
      if (name.isNotEmpty) return name;
    }
    return id > 0 ? 'Sector $id' : 'Uncategorised';
  }

  static List<InvestmentGrowthModel> _growth(List<PortfolioModel> holdings) {
    final grouped = <String, List<PortfolioModel>>{};
    for (final holding in holdings) {
      final key = holding.startupId > 0
          ? 'id:${holding.startupId}'
          : 'name:${holding.startup.brandName.trim().toLowerCase()}';
      grouped.putIfAbsent(key, () => []).add(holding);
    }
    final growth = [
      for (final rows in grouped.values)
        InvestmentGrowthModel(
          startupId: rows.first.startupId,
          startupName: rows.first.startup.brandName,
          totalInvestedAmount: rows.fold<double>(
            0,
            (sum, row) => sum + _invested(row),
          ),
          currentValue: rows.fold<double>(
            0,
            (sum, row) => sum + row.totalCurrentPrice,
          ),
          hasCurrentValue: rows.every(_hasValue),
          logo: rows
              .map((row) => row.startup.cms.logo)
              .firstWhere((logo) => logo.isNotEmpty, orElse: () => ''),
        ),
    ]..sort((a, b) => b.totalInvestedAmount.compareTo(a.totalInvestedAmount));
    return growth;
  }

  static InvestmentTimeline _timeline(List<PortfolioModel> holdings) {
    final monthly = <String, double>{};
    final quarterly = <String, _Quarter>{};
    for (final holding in holdings) {
      final date = holding.createdAt;
      if (date.year < 1900) continue;
      final month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthly[month] = (monthly[month] ?? 0) + _invested(holding);
      final quarter = ((date.month - 1) ~/ 3) + 1;
      final key = '${date.year}-Q$quarter';
      final bucket = quarterly.putIfAbsent(
        key,
        () => _Quarter(
          label: 'Q$quarter ${date.year}',
          start: DateTime(date.year, (quarter - 1) * 3 + 1, 1),
          end: DateTime(date.year, quarter * 3 + 1, 0),
        ),
      );
      bucket.amount += _invested(holding);
    }
    final months = monthly.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final quarters = quarterly.values.toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return InvestmentTimeline(
      monthly: [
        for (final entry in months)
          MonthlyInvestmentModel(month: entry.key, totalInvestment: entry.value),
      ],
      quarterly: [
        for (final quarter in quarters)
          QuarterlyInvestmentModel(
            quarter: quarter.label,
            start: quarter.start,
            end: quarter.end,
            totalInvestment: quarter.amount,
          ),
      ],
    );
  }

  static InvestorChartModel _chart(
    List<WInvestorModel> people,
    List<InvestorModel> directory,
  ) {
    final known = {for (final investor in directory) investor.id: investor};
    final rows = [
      for (final person in people)
        Active(
          id: person.investorId,
          name: person.name,
          mobileNumber: known[person.investorId]?.mobileNumber ?? 0,
          email: known[person.investorId]?.email ?? '',
          isActive: known[person.investorId]?.isActive ?? -1,
          kycStatus: known[person.investorId]?.kycStatus ?? -1,
        ),
    ];
    return InvestorChartModel(kyc: rows, active: rows);
  }
}

class _Quarter {
  _Quarter({required this.label, required this.start, required this.end});
  final String label;
  final DateTime start;
  final DateTime end;
  double amount = 0;
}
