import 'package:intl/intl.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/dashboard/w_dashboard_model.dart';

/// Dashboard-only formatting: zero and negative amounts are valid data.
String dashboardMoney(num value, {bool full = false}) {
  if (!value.isFinite) return 'Unavailable';
  final sign = value < 0 ? '−' : '';
  final amount = value.abs();
  if (full) {
    return '$sign₹${NumberFormat('#,##,##0.##', 'en_IN').format(amount)}';
  }
  for (final unit in [(10000000, 'Cr'), (100000, 'L'), (1000, 'K')]) {
    if (amount >= unit.$1) {
      return '$sign₹${NumberFormat('0.##').format(amount / unit.$1)}${unit.$2}';
    }
  }
  return '$sign₹${NumberFormat('0.##').format(amount)}';
}

String dashboardPercent(double value) =>
    '${NumberFormat('0.#').format(value)}%';

class DashboardPeriod {
  const DashboardPeriod(this.label, this.amount, {this.date, this.range = ''});
  final String label;
  final double amount;
  final DateTime? date;
  final String range;

  String get displayLabel {
    if (label.isEmpty) return 'Unlabelled period';
    if (date != null && RegExp(r'^\d{4}-\d{2}(-\d{2})?$').hasMatch(label)) {
      return DateFormat('MMM yy', 'en_US').format(date!);
    }
    if (date != null && range.isNotEmpty && !RegExp(r'\d{4}').hasMatch(label)) {
      return '$label ${date!.year}';
    }
    return label;
  }
}

class SectorExposure {
  SectorExposure(this.sector);
  final WSector sector;
  double get amount => sector.totalInvestment;

  // A company may occur repeatedly, once for each investor/transaction.
  int get companies => sector.startups
      .map(
        (item) => item.startupId > 0
            ? 'id:${item.startupId}'
            : 'name:${item.startupName.trim().toLowerCase()}',
      )
      .where((id) => id != 'name:')
      .toSet()
      .length;
}

class CompanyPerformance {
  const CompanyPerformance(this.company);
  final InvestmentGrowthModel company;
  double get invested => company.totalInvestedAmount;
  bool get hasValuation =>
      company.hasCurrentValue && company.currentValue.isFinite;
  double? get change => hasValuation ? company.currentValue - invested : null;
  double? get changePercent =>
      invested > 0 && change != null ? change! / invested * 100 : null;
}

class DashboardInsights {
  const DashboardInsights(this.model);
  final WDashboardModel model;

  List<SectorExposure> get sectors =>
      model.sectors
          .where((s) => s.totalInvestment.isFinite && s.totalInvestment >= 0)
          .map(SectorExposure.new)
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
  double get sectorTotal => sectors.fold(0, (sum, s) => sum + s.amount);
  List<CompanyPerformance> get companies =>
      model.investmentGrowth
          .where(
            (c) => c.totalInvestedAmount.isFinite && c.totalInvestedAmount >= 0,
          )
          .map(CompanyPerformance.new)
          .toList()
        ..sort((a, b) => b.invested.compareTo(a.invested));

  List<DashboardPeriod> periods({required bool monthly}) {
    final entries = monthly
        ? model.investments.monthly
              .where((p) => p.totalInvestment.isFinite)
              .map(
                (p) => DashboardPeriod(
                  p.month,
                  p.totalInvestment,
                  date: _monthDate(p.month),
                ),
              )
              .toList()
        : model.investments.quarterly
              .where((p) => p.totalInvestment.isFinite)
              .map(
                (p) => DashboardPeriod(
                  p.quarter,
                  p.totalInvestment,
                  date: p.start.year > 1900 ? p.start : null,
                  range: p.start.year > 1900 && p.end.year > 1900
                      ? '${DateFormat('d MMM y').format(p.start)} – ${DateFormat('d MMM y').format(p.end)}'
                      : '',
                ),
              )
              .toList();
    // Undated labels (e.g. January) retain API order; never invent a year.
    if (entries.every((p) => p.date != null)) {
      entries.sort((a, b) => a.date!.compareTo(b.date!));
    }
    return entries;
  }

  static DateTime? _monthDate(String input) {
    final iso = RegExp(r'^\d{4}-\d{2}(-\d{2})?$');
    if (iso.hasMatch(input)) {
      return DateTime.tryParse(input.length == 7 ? '$input-01' : input);
    }
    for (final format in ['MMM yyyy', 'MMMM yyyy', 'MMM-yy', 'MMM-yyyy']) {
      try {
        return DateFormat(format, 'en_US').parseStrict(input);
      } on FormatException {
        // Try the next documented display shape, otherwise keep API order.
      }
    }
    return null;
  }

  List<Active> get active =>
      model.investorChartModel.active.where((i) => i.isActive == 1).toList();
  List<Active> get inactive =>
      model.investorChartModel.active.where((i) => i.isActive == 0).toList();
  List<Active> get unknownActivity => model.investorChartModel.active
      .where((i) => i.isActive != 0 && i.isActive != 1)
      .toList();
  List<Active> get verified =>
      model.investorChartModel.kyc.where((i) => i.kycStatus == 1).toList();
  List<Active> get pendingKyc =>
      model.investorChartModel.kyc.where((i) => i.kycStatus == 0).toList();
  List<Active> get otherKyc => model.investorChartModel.kyc
      .where((i) => i.kycStatus != 0 && i.kycStatus != 1)
      .toList();
}
