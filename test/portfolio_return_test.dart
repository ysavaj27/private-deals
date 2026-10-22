import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/portfolio/portfolio_model.dart';
import 'package:private_deals/src/features/wealth_manager/data/models/portfolio/pre_ipo_portfolio_model.dart';

void main() {
  test('startup holding uses reported return instead of purchase price', () {
    final holding = PortfolioModel.fromJson({
      'shares': 100,
      'purchase_price': 1000,
      'investment_amount': 110000,
      'current_share_price': 1250,
      'current_value': 125000,
      'return_amount': -15000,
      'return_percentage': -13.64,
    });

    expect(holding.totalCurrentPrice, 125000);
    expect(holding.profitAmount, -15000);
    expect(holding.profitPercentage, '-13.64%');
    expect(holding.profitAmountText, '-₹ 15,000');
    expect(holding.usesReportedReturn, isTrue);
  });

  test('startup holding keeps the local return when fields are absent', () {
    final holding = PortfolioModel.fromJson({
      'shares': 100,
      'purchase_price': 1000,
      'current_share_price': 900,
    });

    expect(holding.usesReportedReturn, isFalse);
    expect(holding.profitAmount, -10000);
    expect(holding.profitPercentage, '-10.00%');
  });

  test('unlisted holding uses reported return instead of purchase price', () {
    final holding = PreIPOPortfolioModel.fromJson({
      'shares': 100,
      'purchase_price': 1000,
      'investment_amount': 110000,
      'current_share_price': 900,
      'current_value': 90000,
      'return_amount': -20000,
      'return_percentage': -18.18,
    });

    expect(holding.totalCurrentPrice, 90000);
    expect(holding.profitAmount, -20000);
    expect(holding.profitPercentage, '-18.18%');
    expect(holding.usesReportedReturn, isTrue);
  });
}
