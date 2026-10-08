import 'dart:math';

import 'package:get/get_utils/src/extensions/double_extensions.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

// Keep the original pattern and honor locale changes without rebuilding the
// formatter for every cell in a list or table.
final Map<String, NumberFormat> _displayFormats = {};

NumberFormat get _displayFormat {
  final locale = Intl.getCurrentLocale();
  return _displayFormats.putIfAbsent(
    locale,
    () => NumberFormat('#,##,##0.##', locale),
  );
}

extension Formatte on int {
  double get convertToMB {
    return this / 1024 / 1024;
  }

  String get toMaskedString {
    String accountNumber = toString();
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    String masked = 'x' * (accountNumber.length - 4);
    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return masked + lastFour;
  }

  String get toHidePhoneNo {
    String accountNumber = toString();
    if (accountNumber.length <= 2) {
      return accountNumber;
    }
    String masked = '*' * (accountNumber.length - 2);
    String lastFour = accountNumber.substring(accountNumber.length - 2);
    return masked + lastFour;
  }

  String get weekName {
    switch (this) {
      case 1:
        return 'M';
      case 2:
        return 'T';
      case 3:
        return 'W';
      case 4:
        return 'T';
      case 5:
        return 'F';
      case 6:
        return 'S';
      case 7:
        return 'S';
      default:
        return '';
    }
  }

  String get fileSize {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (this == 0) return '0 ${suffixes[0]}';
    var i = (log(this) / log(1024)).floor();
    return "${(this / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}";
  }

  String get monthName {
    switch (this) {
      case 1:
        return 'jan'.tr;
      case 2:
        return 'feb'.tr;
      case 3:
        return 'mar'.tr;
      case 4:
        return 'apr'.tr;
      case 5:
        return 'may'.tr;
      case 6:
        return 'jun'.tr;
      case 7:
        return 'jul'.tr;
      case 8:
        return 'aug'.tr;
      case 9:
        return 'sep'.tr;
      case 10:
        return 'oct'.tr;
      case 11:
        return 'nov'.tr;
      case 12:
        return 'dec'.tr;
      default:
        return '';
    }
  }

  String get alphaBets {
    return String.fromCharCode(this + 65);
  }

  bool get success => this == 1 ? true : false;

  bool get isNotEmpty => this == 0 ? false : true;

  bool get isEmpty => this == 0 ? true : false;

  String get show => this == 0 ? "" : '$this';

  String? validateSellQuantity(int minQty, int sellQty) {
    // Case 1: Total shares are less than twice the minimum quantity
    if (this < 2 * minQty) {
      // Allow selling exactly minQty shares
      if (sellQty == this || sellQty == minQty) {
        return null; // Valid
      }
      return 'You need to sell all $this shares.';
    }

    // Case 2: Entered quantity is less than the minimum quantity
    if (sellQty < minQty) {
      return 'You must sell at least $minQty shares.';
    }

    // Case 3: Check if the entered quantity is not divisible by minQty
    if (sellQty % minQty != 0) {
      int nearestMin = (sellQty ~/ minQty) * minQty;
      int nearestMax = nearestMin + minQty;

      // Ensure the nearest max doesn't exceed total shares
      if (nearestMax > this) nearestMax = this;

      return 'Invalid quantity. You can sell $nearestMin or $nearestMax shares.';
    }

    return null; // Valid case
  }
}

extension FancyNum on num {
  num plus(num other) => this + other;

  num times(num other) => this * other;

  num get percentageOf10 => (this * 10) / 100;

  String get currency => "₹";

  double get distributorPrice {
    return ((this * (1 / 100)) + this).toPrecision(2);
  }

  String get formattedDecimal {
    final doubleValue = double.tryParse(toString());
    if (doubleValue == null) return toString();
    return doubleValue.toStringAsFixed(
      doubleValue.truncateToDouble() == doubleValue
          ? 0
          : doubleValue.toString().split('.').last.length,
    );
  }

  // 2. Distributor Price + Gross Distributor Price
  double get distributorPriceWithGross {
    double grossDisPrice = distributorPrice * (2.5 / 100);
    return grossDisPrice.toPrecision(2);
  }

  // 3. Final Price (Distributor Price + Gross Distributor Price + GST)
  double get finalDistributorPrice {
    double grossDisPrice = distributorPrice * (2.5 / 100);
    double gst = grossDisPrice * (18 / 100);
    return (gst).toPrecision(2);
  }

  // 2. Distributor Price + Gross Distributor Price
  double get aifManagementFees {
    double grossDisPrice = this * (2 / 100);
    return grossDisPrice.toPrecision(2);
  }

  // 3. Final Price (Distributor Price + Gross Distributor Price + GST)
  double get aifGST {
    double grossDisPrice = this * (2 / 100);
    double gst = grossDisPrice * (18 / 100);
    return (gst).toPrecision(2);
  }

  double get aifFinalPrice {
    return (this + aifManagementFees + aifGST).toPrecisions(2);
  }

  double formatUnit() {
    return double.parse(toStringAsFixed(3));
  }

  String get fixDigit {
    return "$currency ${toPrecisions(2)}";
  }

  String get toCurrency {
    if (this <= 0) return '-';
    return "$currency ${_displayFormat.format(this)}";
  }

  String get toShowNum {
    if (this <= 0) return '-';
    return _displayFormat.format(this);
  }

  num minus(int value) {
    var newValue = this - value;
    if (newValue >= 0) {
      return newValue;
    } else {
      return 0;
    }
  }

  double nearestBelowSharePrice(double sharePrice) {
    return ((this ~/ sharePrice) * sharePrice).toPrecision(3);
  }

  double nearestAboveSharePrice(double sharePrice) {
    return ((this / sharePrice).ceil() * sharePrice).toPrecision(3);
  }

  int calculateShares(double sharePrice) {
    if (sharePrice >= 0) {
      return (this / sharePrice).floor();
    } else {
      return 0;
    }
  }

  bool isPerfectSharePrice(double sharePrice) {
    return this % sharePrice == 0;
  }

  String get toShowString {
    if (this != 0) {
      return toString();
    } else {
      return 'N/A';
    }
  }

  double toPrecisions(int n) => double.parse(toStringAsFixed(n));

  String get toFormattedPrice {
    if (this <= 0) return 'N/A';
    if (this >= 10000000) {
      return '₹${(this / 10000000).toStringAsFixed(1)}Cr';
    } else if (this >= 100000) {
      return '₹${(this / 100000).toStringAsFixed(2)}L';
    } else if (this >= 1000) {
      return '₹${(this / 1000).toStringAsFixed(2)}K';
    } else {
      return '₹$this';
    }
  }

  String toLakesCorersFormat() {
    if (this <= 0) return 'N/A';
    if (this >= 10000000) {
      return '₹${(this / 10000000).toStringAsFixed(0)}Cr';
    } else if (this >= 100000) {
      return '₹${(this / 100000).toStringAsFixed(0)}L';
    } else if (this >= 1000) {
      return '₹${(this / 1000).toStringAsFixed(0)}K';
    } else {
      return '₹$this';
    }
  }
}
