import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:private_deals/src/features/institution/companies/presentation/company_list/company_list_page_ctrl.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/desktop_company_list_view.dart';
import 'package:private_deals/src/features/institution/companies/presentation/company_list/phone_company_list_view.dart';

class CompanyListPage extends StatefulWidget {
  const CompanyListPage({super.key});

  @override
  State<CompanyListPage> createState() => _CompanyListPageState();
}

class _CompanyListPageState extends State<CompanyListPage> {
  final CompanyListPageCtrl c = CompanyListPageCtrl();

  @override
  void initState() {
    super.initState();
    c.onStart();
  }

  @override
  void dispose() {
    c.onDelete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return context.isPhone
        ? PhoneCompanyListView(c: c)
        : DesktopCompanyListView(c: c);
  }
}

/// Filters the company list. Sits with search, under the page title.
class CompanySubmissionFilter extends StatelessWidget {
  final CompanyListPageCtrl c;
  final bool expanded;

  const CompanySubmissionFilter({
    super.key,
    required this.c,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mine = c.mySubmissions();
      final loading = c.isLoading();

      final button = SegmentedButton<bool>(
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        segments: const [
          ButtonSegment(
            value: false,
            label: Text('All companies'),
            tooltip: 'Every company in this list',
          ),
          ButtonSegment(
            value: true,
            label: Text('Created by me'),
            tooltip: 'Only companies you submitted',
          ),
        ],
        selected: {mine},
        onSelectionChanged: loading
            ? null
            : (values) {
                final next = values.first;
                if (next == mine) return;
                c.mySubmissions(next);
                c.fetchCompanies(page: 0);
              },
      );

      if (!expanded) return button;
      return SizedBox(width: double.infinity, child: button);
    });
  }
}

class CompanyPagination extends StatelessWidget {
  final CompanyListPageCtrl c;

  const CompanyPagination({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = c.currentPage.value;
      final count = c.companies.length;
      final hasNext = c.hasNextPage.value;
      final start = page * CompanyListPageCtrl.pageSize;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
              count == 0
                  ? 'No companies'
                  : 'Showing ${start + 1}–${start + count}',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: c.isLoading.isFalse && page > 0
                      ? c.previousPage
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Page ${page + 1}',
                    style: context.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: c.isLoading.isFalse && hasNext ? c.nextPage : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
