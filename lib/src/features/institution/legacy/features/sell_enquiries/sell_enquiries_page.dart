import 'package:flutter/material.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';

class SellEnquiriesPage extends StatelessWidget {
  const SellEnquiriesPage({super.key});

  /// Seller My Enquiries uses the same partner create/list APIs as wealth
  /// managers (`v2/business/enquiries/deals`), not the institution inbox.
  @override
  Widget build(BuildContext context) => const EnquiriesPage();
}
