import 'package:private_deals/src/shared/models/enums.dart';

extension InvestmentTypeEnumX on InvestmentTypeEnum {
  String get label {
    switch (this) {
      case InvestmentTypeEnum.buy:
        return "Buy";
      case InvestmentTypeEnum.sell:
        return "Sell";
      case InvestmentTypeEnum.inquiry:
        return "Enquiry";
      case InvestmentTypeEnum.none:
        return "";
    }
  }
}

enum OfferValidTillOption { today, thisWeek, thisMonth, custom }

extension OfferValidTillOptionX on OfferValidTillOption {
  String get label {
    switch (this) {
      case OfferValidTillOption.today:
        return "Today";
      case OfferValidTillOption.thisWeek:
        return "This week";
      case OfferValidTillOption.thisMonth:
        return "This month";
      // case OfferValidTillOption.tillTransactionStart:
      //   return "Till transaction start";
      case OfferValidTillOption.custom:
        return "Custom";
    }
  }

  /// Resolves the option to a concrete date. `custom` requires [customDate].
  DateTime resolveDate({DateTime? customDate}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case OfferValidTillOption.today:
        return today;
      case OfferValidTillOption.thisWeek:
        return today.add(Duration(days: 7 - today.weekday));
      case OfferValidTillOption.thisMonth:
        return DateTime(today.year, today.month + 1, 0);
      // case OfferValidTillOption.tillTransactionStart:
      // TODO: wire to actual transaction-start date once available upstream
      // return today;
      case OfferValidTillOption.custom:
        return customDate ?? today;
    }
  }
}

class EnquiryRequestModel {
  final InvestmentTypeEnum enquiryType;
  final int quantity;
  final double offerPrice;
  final DateTime offerValidTill;
  final String? notes;

  EnquiryRequestModel({
    required this.enquiryType,
    required this.quantity,
    required this.offerPrice,
    required this.offerValidTill,
    this.notes,
  });

  String get _formattedDate =>
      "${offerValidTill.year.toString().padLeft(4, '0')}-"
      "${offerValidTill.month.toString().padLeft(2, '0')}-"
      "${offerValidTill.day.toString().padLeft(2, '0')}";

  Map<String, dynamic> toJson() {
    return {
      "enquiry_type": enquiryType.name,
      "quantity": quantity,
      "offer_price": offerPrice,
      "offer_valid_till": _formattedDate,
      if (notes != null && notes!.trim().isNotEmpty) "notes": notes!.trim(),
    };
  }
}
