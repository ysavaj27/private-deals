import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/institution/institution_routes.dart';
import 'package:private_deals/src/features/institution/support/plugins/cache_image.dart';
import 'package:private_deals/src/features/institution/support/plugins/loader.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/app_text_field.dart';

import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';

class PhoneCompanyListView extends StatelessWidget {
  final CompanyListPageCtrl c;

  const PhoneCompanyListView({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  // controller: c.searchController,
                  onChanged: c.updateSearch,
                  hint: 'Search companies...',
                  prefixIcon: Icons.search_rounded,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: () {
                      final routes = InstitutionRoutes.createCompany(
                        Get.currentRoute,
                      );
                      Get.toNamed(routes);
                    },
                    icon: Icons.add_rounded,
                    label: "Create company",
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          if (c.isLoading.value) {
            return const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(40), child: Loader()),
            );
          }

          if (c.errorMessage.value.isNotEmpty) {
            return SliverToBoxAdapter(
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

          if (companies.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('No companies found')),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final company = companies[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              LogoImage(url: company.logo, radius: 12),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company.brandName,
                                      style: context.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      company.category,
                                      style: context.textTheme.bodySmall
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
                              if (company.isEditable)
                                PopupMenuButton<String>(
                                  tooltip: 'Manage company',
                                  onSelected: (value) {
                                    if (value == 'promoters') {
                                      c.openPromoters(company);
                                    } else {
                                      c.openShareholders(company);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'promoters',
                                      child: Text('Manage promoters'),
                                    ),
                                    PopupMenuItem(
                                      value: 'shareholders',
                                      child: Text('Manage shareholders'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            company.companyName,
                            style: context.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company.sector.name,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  company.category,
                                  style: context.textTheme.bodySmall,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: Text(
                                  '₹${company.sharePrice.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: context.textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }, childCount: companies.length),
            ),
          );
        }),
        SliverToBoxAdapter(child: CompanyPagination(c: c)),
      ],
    );
  }
}
