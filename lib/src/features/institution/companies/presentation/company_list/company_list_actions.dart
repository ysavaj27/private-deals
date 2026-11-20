import 'package:flutter/material.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/data/models/company/company_model.dart';

class CompanyListActionsMenu extends StatelessWidget {
  const CompanyListActionsMenu({
    super.key,
    required this.controller,
    required this.company,
  });

  final CompanyListPageCtrl controller;
  final CompanyModel company;

  @override
  Widget build(BuildContext context) {
    if (!company.isEditable) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Manage company',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            controller.openEdit(company);
          case 'events':
            controller.openEvents(company);
          case 'promoters':
            controller.openPromoters(company);
          case 'shareholders':
            controller.openShareholders(company);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit company'),
        ),
        PopupMenuItem(
          value: 'events',
          child: Text('Manage events'),
        ),
        PopupMenuItem(
          value: 'promoters',
          child: Text('Manage promoters'),
        ),
        PopupMenuItem(
          value: 'shareholders',
          child: Text('Manage shareholders'),
        ),
      ],
    );
  }
}
