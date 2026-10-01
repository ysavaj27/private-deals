import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/features/institution/support/plugins/logger.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';

import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';

// Add your Company model and LogoImage imports.

class DesktopCompanyListView extends StatelessWidget {
  final CompanyListPageCtrl c;

  const DesktopCompanyListView({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Text(c.companyRoute.title, style: context.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Browse and manage your companies.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AppTextField(
                    // controller: c.searchController,
                    onChanged: c.updateSearch,
                    hint: 'Search companies...',
                    prefixIcon: Icons.search_rounded,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            AppButton(
              onPressed: () {
                var routes = InstitutionRoutes.createCompany(Get.currentRoute);
                logger.d(routes);
                Get.toNamed(routes);
              },
              icon: Icons.add_rounded,
              label: 'Create company',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Obx(() {
            if (c.isLoading.isTrue) {
              return SizedBox(height: context.height * 0.4, child: Loader());
            }
            if (c.errorMessage.value.isNotEmpty) {
              return SizedBox(
                height: context.height * 0.5,
                child: Column(
                  children: [
                    Text(c.errorMessage.value),
                    TextButton(
                      onPressed: c.fetchCompanies,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final companies = c.filteredCompanies;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '${companies.length} companies',
                    style: context.textTheme.titleMedium,
                  ),
                ),
                if (companies.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('No companies found')),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                              context.theme.colorScheme.surfaceContainerLow,
                            ),
                            headingTextStyle: context.textTheme.titleSmall,
                            dataTextStyle: context.textTheme.bodyMedium,
                            horizontalMargin: 20,
                            columnSpacing: 28,
                            dataRowMinHeight: 80,
                            dataRowMaxHeight: 100,
                            columns: const [
                              DataColumn(label: Text('Brand')),
                              DataColumn(label: Text('Company name')),
                              DataColumn(label: Text('Category')),
                              DataColumn(
                                label: Text('Share price'),
                                numeric: true,
                              ),
                              DataColumn(
                                label: Text('Action'),
                                headingRowAlignment: MainAxisAlignment.center,
                              ),
                            ],
                            rows: companies.map((company) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 220,
                                      child: Row(
                                        children: [
                                          LogoImage(
                                            url: company.logo,
                                            radius: 12,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  company.brandName,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: context
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  company.category,
                                                  style: context
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: context
                                                            .theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 280,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            company.companyName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            company.sector.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: context
                                                      .theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(company.category)),
                                  DataCell(
                                    Text(
                                      '₹${company.sharePrice.toStringAsFixed(2)}',
                                      style: context.textTheme.titleSmall,
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,

                                      children: [
                                        if (company.isEditable)
                                          IconButton(
                                            tooltip: 'Manage promoters',
                                            icon: const Icon(
                                              Icons.groups_outlined,
                                            ),
                                            onPressed: () =>
                                                c.openPromoters(company),
                                          ),
                                        if (company.isEditable)
                                          IconButton(
                                            tooltip: 'Manage shareholders',
                                            icon: const Icon(
                                              Icons.pie_chart_outline,
                                            ),
                                            onPressed: () =>
                                                c.openShareholders(company),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                const Divider(height: 1),
                CompanyPagination(c: c),
              ],
            );
          }),
        ),
      ],
    );
  }
}
