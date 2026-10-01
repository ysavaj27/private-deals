import 'package:flutter/material.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';
import '../../legacy/features/company/update_share_price/update_share_price_page.dart';

class BulkDealsPage extends StatelessWidget {
  const BulkDealsPage({super.key});
  @override
  Widget build(BuildContext context) => PartnerShell(
    title: 'Update Unlisted Share Price',
    child: UpdateSharePricePage(),
  );
}
