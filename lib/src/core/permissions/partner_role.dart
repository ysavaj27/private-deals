/// Exact API values from data.enum.partner_type. Unknown values fail closed.
enum PartnerRole {
  wealthManager('Wealth Manager'),
  distributor('Distributor'),
  retailer('Retailer'),
  relationManager('Relation Manager'),
  institution('Institution'),
  unknown('');

  const PartnerRole(this.apiValue);
  final String apiValue;
  static PartnerRole parse(String? value) => PartnerRole.values.firstWhere(
    (role) => role != unknown && role.apiValue == value,
    orElse: () => unknown,
  );
  bool get isBusinessWorkspace => this != institution && this != unknown;
}
