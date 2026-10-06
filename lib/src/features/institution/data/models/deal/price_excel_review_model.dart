import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/features/institution/support/functions/parse.dart';

class PriceExcelReview {
  final bool saved;
  final double feePercent;
  final int createCount;
  final int skipCount;
  final int unchangedCount;
  final int errorCount;
  final List<PriceExcelRow> rows;
  final List<PriceExcelError> errors;
  final List<DealModel> deals;

  const PriceExcelReview({
    this.saved = false,
    this.feePercent = 0,
    this.createCount = 0,
    this.skipCount = 0,
    this.unchangedCount = 0,
    this.errorCount = 0,
    this.rows = const [],
    this.errors = const [],
    this.deals = const [],
  });

  List<PriceExcelRow> get createRows =>
      rows.where((row) => row.action == 'create').toList();

  /// Confirm save only when there is at least one create row and no sheet errors.
  bool get canSave => createCount > 0 && errorCount == 0;

  factory PriceExcelReview.fromJson(Map<String, dynamic> json) {
    final rowsRaw = json['rows'];
    final errorsRaw = json['errors'];
    final dealsRaw = json['deals'];

    return PriceExcelReview(
      saved: Parse.toBool(json['saved']),
      feePercent: Parse.toDouble(json['fee_percent']),
      createCount: Parse.toInt(json['create_count']),
      skipCount: Parse.toInt(json['skip_count']),
      unchangedCount: Parse.toInt(json['unchanged_count']),
      errorCount: Parse.toInt(json['error_count']),
      rows: rowsRaw is List
          ? rowsRaw
                .whereType<Map>()
                .map(
                  (e) => PriceExcelRow.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      errors: errorsRaw is List
          ? errorsRaw
                .whereType<Map>()
                .map(
                  (e) => PriceExcelError.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      deals: dealsRaw is List
          ? dealsRaw
                .whereType<Map>()
                .map((e) => DealModel.fromJson(Map<String, dynamic>.from(e)))
                .toList()
          : const [],
    );
  }
}

class PriceExcelRow {
  final String sheet;
  final int excelRow;
  final String brandName;
  final String legalName;
  final String action;
  final double? basePrice;
  final double? sharePrice;
  final double? minQty;
  final int? settlementDays;
  final double? totalQty;

  const PriceExcelRow({
    this.sheet = '',
    this.excelRow = 0,
    this.brandName = '',
    this.legalName = '',
    this.action = '',
    this.basePrice,
    this.sharePrice,
    this.minQty,
    this.settlementDays,
    this.totalQty,
  });

  factory PriceExcelRow.fromJson(Map<String, dynamic> json) {
    return PriceExcelRow(
      sheet: Parse.toStrings(json['sheet']),
      excelRow: Parse.toInt(json['excel_row']),
      brandName: Parse.toStrings(json['brand_name']),
      legalName: Parse.toStrings(json['legal_name']),
      action: Parse.toStrings(json['action']),
      basePrice: _nullableDouble(json['base_price']),
      sharePrice: _nullableDouble(json['share_price']),
      minQty: _nullableDouble(json['min_qty']),
      settlementDays: json['settlement_days'] == null
          ? null
          : Parse.toInt(json['settlement_days']),
      totalQty: _nullableDouble(json['total_qty']),
    );
  }
}

class PriceExcelError {
  final String sheet;
  final int excelRow;
  final String brandName;
  final String legalName;
  final String message;

  const PriceExcelError({
    this.sheet = '',
    this.excelRow = 0,
    this.brandName = '',
    this.legalName = '',
    this.message = '',
  });

  factory PriceExcelError.fromJson(Map<String, dynamic> json) {
    return PriceExcelError(
      sheet: Parse.toStrings(json['sheet']),
      excelRow: Parse.toInt(json['excel_row']),
      brandName: Parse.toStrings(json['brand_name']),
      legalName: Parse.toStrings(json['legal_name']),
      message: Parse.toStrings(json['message']),
    );
  }
}

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  return double.tryParse(value.toString());
}
