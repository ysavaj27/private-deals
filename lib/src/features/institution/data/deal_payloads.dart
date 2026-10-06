/// Deliberately separate create/base pricing from update/final pricing.
class DealPayloads {
  static num price(String text) {
    final value = num.tryParse(text.trim());
    if (value == null || !value.isFinite || value <= 0)
      throw const FormatException('Enter a price greater than zero.');
    return value;
  }

  static int quantity(String text) {
    final value = int.tryParse(text.trim());
    if (value == null || value < 1)
      throw const FormatException('Minimum quantity must be at least 1.');
    return value;
  }

  static int settlementDays(int? value) {
    if (value == null || value < 1 || value > 30) {
      throw const FormatException(
        'Select a settlement cycle from T+1 to T+30.',
      );
    }
    return value;
  }

  static Map<String, dynamic> update({
    required String uuid,
    required String finalPrice,
    required String minimumQuantity,
    String totalQuantity = '',
    String dealType = '',
    String status = '',
    int? settlementDays,
  }) {
    if (uuid.isEmpty) throw const FormatException('Select an owned deal.');
    final min = quantity(minimumQuantity);
    final total = totalQuantity.trim().isEmpty ? null : quantity(totalQuantity);
    if (total != null && min > total)
      throw const FormatException(
        'Minimum quantity cannot exceed total quantity.',
      );
    return {
      'uuid': uuid,
      if (dealType.isNotEmpty) 'deal_type': dealType,
      'share_price': price(finalPrice),
      'minimum_qty': min,
      if (total != null) 'available_quantity': total,
      if (status.isNotEmpty) 'status': status,
      if (settlementDays != null)
        'settlement_days': DealPayloads.settlementDays(settlementDays),
    };
  }

  static Map<String, dynamic> bulk(List<BulkDealRow> rows) {
    final sell = <Map<String, dynamic>>[];
    final buy = <Map<String, dynamic>>[];
    for (final row in rows) {
      if (row.price.trim().isEmpty || num.tryParse(row.price.trim()) == 0)
        continue;
      final value = price(row.price);
      if (row.companyId == null || row.companyId! <= 0)
        throw const FormatException('Select a company for every priced row.');
      if (!['sell', 'buy'].contains(row.type))
        throw const FormatException('Choose buy or sell.');
      final min = quantity(row.minimum);
      final total = row.total.trim().isEmpty ? null : quantity(row.total);
      if (total != null && min > total)
        throw const FormatException(
          'Minimum quantity cannot exceed total quantity.',
        );
      final entry = <String, dynamic>{
        'company_id': row.companyId,
        '${row.type}_price': value,
        'min_qty': min,
        'total_qty': total,
      };
      if (row.type == 'sell') {
        entry['settlement_days'] = settlementDays(row.settlementDays);
        sell.add(entry);
      } else {
        buy.add(entry);
      }
    }
    if (sell.isEmpty && buy.isEmpty)
      throw const FormatException('Enter at least one positive price.');
    return {'sell': sell, 'buy': buy};
  }
}

class BulkDealRow {
  const BulkDealRow({
    this.companyId,
    required this.type,
    required this.price,
    required this.minimum,
    this.total = '',
    this.settlementDays,
  });
  final int? companyId;
  final String type, price, minimum, total;
  final int? settlementDays;
}
