import 'package:flutter/material.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiries_page.dart';

class SellEnquiriesPage extends StatelessWidget {
  const SellEnquiriesPage({super.key});

  /// Incoming buy and sell enquiries use the Institution inbox and decisions.
  @override
  Widget build(BuildContext context) =>
      const EnquiriesPage(institution: true, title: 'All Enquiries');
}

class SellerMyEnquiriesPage extends StatelessWidget {
  const SellerMyEnquiriesPage({super.key});

  /// Own enquiries retain the partner API and investor-based approval flow.
  @override
  Widget build(BuildContext context) => const EnquiriesPage(ownOnly: true);
}
