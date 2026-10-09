import 'package:flutter/foundation.dart';
import 'package:private_deals/src/features/investors/data/w_investor_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/dashboard/w_dashboard_model.dart';

/// Local preview records. The release path returns before creating any data.
WDashboardModel createDashboardDebugData({required bool isPrimary}) {
  if (!kDebugMode) return WDashboardModel.fromJson({});

  final names = isPrimary
      ? [
          'Cedar Cloud',
          'Harbor Payments',
          'Juniper Health',
          'Maple Consumer',
          'Solstice Energy',
          'Atlas Logistics',
          'Willow Software',
          'Beacon Finance',
        ]
      : [
          'Northstar Technologies',
          'Summit Financial',
          'Bharat Healthcare',
          'Orchard Consumer',
          'Helios Renewables',
          'Meridian Logistics',
          'Pioneer Digital',
          'Crescent Capital',
        ];
  const sectorNames = [
    'Technology',
    'Financial services',
    'Healthcare',
    'Consumer goods',
    'Clean energy',
    'Logistics',
  ];
  const companySectors = [0, 1, 2, 3, 4, 5, 0, 1];
  const investorNames = [
    'Aarav Shah',
    'Priya Mehta',
    'Rohan Patel',
    'Ananya Rao',
    'Vikram Nair',
    'Neha Desai',
    'Arjun Kapoor',
    'Kavya Iyer',
    'Dev Malhotra',
    'Isha Sen',
    'Kabir Joshi',
    'Meera Menon',
  ];
  const prices = [250.0, 500.0, 1000.0, 1250.0, 2500.0, 500.0, 1000.0, 250.0];
  const valueMultiples = [1.26, 1.14, .86, 1.38, .96, 1.18, 1.07, null];
  final now = DateTime.now();
  final quarterStart = DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1);
  final start = DateTime(quarterStart.year, quarterStart.month - 12);
  final records = <WStartup>[];
  final monthly = <MonthlyInvestmentModel>[];
  final companyTotals = List<double>.filled(names.length, 0);
  final investorTotals = List<double>.filled(investorNames.length, 0);
  final investorCompanies = List.generate(investorNames.length, (_) => <int>{});

  for (var month = 0; month < 12; month++) {
    var monthlyTotal = 0.0;
    for (var deal = 0; deal < 2; deal++) {
      final index = month * 2 + deal;
      final company = index % names.length;
      final investor = index % investorNames.length;
      final amount = (250000 + (index % 7) * 125000) * (isPrimary ? 1.4 : 1.0);
      monthlyTotal += amount;
      companyTotals[company] += amount;
      investorTotals[investor] += amount;
      investorCompanies[investor].add(company);
      records.add(
        WStartup(
          startupId: -(company + 1),
          startupName: names[company],
          investorName: investorNames[investor],
          investmentAmount: amount,
          currentValue: amount * (valueMultiples[company] ?? 0),
          purchasePrice: prices[company],
          shares: amount / prices[company],
          createdAt: DateTime(
            start.year,
            start.month + month,
            deal == 0 ? 5 : 19,
          ),
        ),
      );
    }
    final date = DateTime(start.year, start.month + month);
    monthly.add(
      MonthlyInvestmentModel(
        month: '${date.year}-${date.month.toString().padLeft(2, '0')}',
        totalInvestment: monthlyTotal,
      ),
    );
  }
  final investors = List.generate(
    investorNames.length,
    (i) => WInvestorModel(
      investorId: -(i + 1),
      name: investorNames[i],
      amountInvested: investorTotals[i],
      totalInvestment: investorTotals[i],
      commissionEarned: investorTotals[i] * .015,
      totalStartups: investorCompanies[i].length,
    ),
  )..sort((a, b) => b.amountInvested.compareTo(a.amountInvested));
  final statuses = List.generate(
    investorNames.length,
    (i) => Active(
      id: -(i + 1),
      name: investorNames[i],
      email: 'sample.investor.${i + 1}@example.com',
      isActive: i < 9 ? 1 : 0,
      kycStatus: i % 4 == 0 ? 0 : 1,
    ),
  );
  final total = companyTotals.fold<double>(0, (sum, amount) => sum + amount);
  return WDashboardModel(
    totalStartups: names.length,
    totalInvestors: investors.length,
    totalAmountInvested: total,
    averageTicketSize: total / records.length,
    pendingKyc: statuses.where((i) => i.kycStatus == 0).length,
    pendingDocumentSign: 4,
    pendingPayment: 3,
    investors: investors,
    topInvestors: investors.take(8).toList(),
    sectors: List.generate(sectorNames.length, (sector) {
      final investments = records
          .where((r) => companySectors[-r.startupId - 1] == sector)
          .toList();
      return WSector(
        id: -(sector + 1),
        name: sectorNames[sector],
        totalInvestment: investments.fold<double>(
          0,
          (sum, r) => sum + r.investmentAmount,
        ),
        startups: investments,
      );
    }),
    investmentGrowth: List.generate(
      names.length,
      (i) => InvestmentGrowthModel(
        startupId: -(i + 1),
        startupName: names[i],
        totalInvestedAmount: companyTotals[i],
        currentValue: companyTotals[i] * (valueMultiples[i] ?? 0),
        hasCurrentValue: valueMultiples[i] != null,
      ),
    ),
    investments: InvestmentTimeline(
      monthly: monthly,
      quarterly: List.generate(4, (i) {
        final date = DateTime(start.year, start.month + i * 3);
        return QuarterlyInvestmentModel(
          quarter: 'Q${(date.month - 1) ~/ 3 + 1} ${date.year}',
          start: date,
          end: DateTime(date.year, date.month + 3, 0),
          totalInvestment: monthly
              .skip(i * 3)
              .take(3)
              .fold<double>(0, (sum, p) => sum + p.totalInvestment),
        );
      }),
    ),
    investorChartModel: InvestorChartModel(active: statuses, kyc: statuses),
  );
}
