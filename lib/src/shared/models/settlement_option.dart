import 'package:private_deals/src/shared/functions/parse.dart';

/// One T+N option from `GET /api/get-config` → `data.settlement_days`.
class SettlementOption {
  const SettlementOption({required this.value, required this.label});

  final int value;
  final String label;

  factory SettlementOption.fromJson(Map<String, dynamic> json) {
    final value = Parse.toInt(json['value']);
    final label = Parse.toStrings(json['label']);
    return SettlementOption(
      value: value,
      label: label.isEmpty && value > 0 ? 'T+$value' : label,
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'label': label};
}
