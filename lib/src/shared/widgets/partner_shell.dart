import 'package:flutter/material.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/core/permissions/partner_role.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page.dart'
    as seller;
import 'package:private_deals/src/features/wealth_manager/presentation/home_page.dart'
    as partner;

/// Shared pages retain the authenticated user's original workspace navigation.
class PartnerShell extends StatelessWidget {
  const PartnerShell({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => app.role == PartnerRole.institution
      ? seller.HomePage(child: child)
      : partner.HomePage(child: child);
}
