import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'mis_page_ctrl.dart';
import '../widgets/workspace_widgets.dart';

class MisView extends StatefulWidget {
  const MisView({super.key});
  @override
  State<MisView> createState() => _MisViewState();
}

class _MisViewState extends State<MisView> {
  final c = Get.find<MISPageCtrl>();
  String _query = '';
  bool _onlyWithReports = false;

  @override
  Widget build(BuildContext context) => Obx(() {
    final reports = c.list.expand((company) => company.misList).toList();
    final companies =
        c.list
            .where(
              (company) =>
                  (!_onlyWithReports || company.misList.isNotEmpty) &&
                  (company.startupName.toLowerCase().contains(_query) ||
                      company.misList.any(
                        (report) => '${report.title} ${report.description}'
                            .toLowerCase()
                            .contains(_query),
                      )),
            )
            .toList()
          ..sort(
            (a, b) => a.startupName.toLowerCase().compareTo(
              b.startupName.toLowerCase(),
            ),
          );
    final unavailable = c.isLoading() || c.error().isNotEmpty;
    return WorkspacePage(
      title: 'MIS',
      subtitle: 'Company updates and management reports, all in one place.',
      onRefresh: c.getData,
      loading: c.isLoading(),
      error: c.error(),
      header: [
        WorkspaceMetrics(
          children: [
            WorkspaceMetric(
              label: 'Companies',
              value: unavailable ? '—' : '${c.list.length}',
              icon: Icons.business_outlined,
            ),
            WorkspaceMetric(
              label: 'Available reports',
              value: unavailable ? '—' : '${reports.length}',
              icon: Icons.description_outlined,
              selected: true,
            ),
            WorkspaceMetric(
              label: 'Companies with reports',
              value: unavailable
                  ? '—'
                  : '${c.list.where((item) => item.misList.isNotEmpty).length}',
              icon: Icons.folder_open_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        Text('Report library', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpace.md),
        WorkspaceSearch(
          hint: 'Search companies or reports',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: AppSpace.md),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          children: [
            ChoiceChip(
              label: const Text('All companies'),
              selected: !_onlyWithReports,
              showCheckmark: false,
              onSelected: (_) => setState(() => _onlyWithReports = false),
            ),
            ChoiceChip(
              label: const Text('With reports'),
              selected: _onlyWithReports,
              showCheckmark: false,
              onSelected: (_) => setState(() => _onlyWithReports = true),
            ),
          ],
        ),
      ],
      itemCount: companies.length,
      empty: WorkspaceEmpty(
        icon: Icons.folder_open_outlined,
        title: _query.isNotEmpty || _onlyWithReports
            ? 'No matching reports'
            : 'No reports yet',
        message: _query.isNotEmpty || _onlyWithReports
            ? 'Try another search or select all companies.'
            : 'Company reports will appear here once they are available.',
      ),
      itemBuilder: (context, index) {
        final company = companies[index];
        final companyMatches = company.startupName.toLowerCase().contains(
          _query,
        );
        final visibleReports =
            company.misList
                .where(
                  (report) =>
                      companyMatches ||
                      '${report.title} ${report.description}'
                          .toLowerCase()
                          .contains(_query),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final colors = Theme.of(context).colorScheme;
        final shape = RoundedRectangleBorder(
          borderRadius: AppRadii.lgAll,
          side: BorderSide(color: colors.outlineVariant),
        );
        return ExpansionTile(
          key: ValueKey('${company.startupId}-${company.startupName}-$_query'),
          initiallyExpanded: _query.isNotEmpty,
          shape: shape,
          collapsedShape: shape,
          backgroundColor: colors.surface,
          collapsedBackgroundColor: colors.surface,
          tilePadding: AppSpace.paddingLg,
          childrenPadding: AppSpace.paddingLg,
          leading: LogoImage(
            url: company.startupLogo,
            height: 44,
            width: 44,
            radius: 10,
          ),
          title: Text(
            company.startupName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            '${visibleReports.length} ${visibleReports.length == 1 ? 'report' : 'reports'}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          children: [
            if (visibleReports.isEmpty)
              const Padding(
                padding: AppSpace.paddingLg,
                child: Text('No reports available for this company.'),
              ),
            for (final report in visibleReports)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpace.sm),
                padding: AppSpace.paddingLg,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: colors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Text(
                            report.title.isEmpty
                                ? 'Company report'
                                : report.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    if (report.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(
                        report.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Wrap(
                      spacing: AppSpace.lg,
                      runSpacing: AppSpace.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          report.createdAt.year > 0
                              ? DateFormat(
                                  'dd MMM yyyy',
                                ).format(report.createdAt)
                              : 'Date unavailable',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        OutlinedButton.icon(
                          onPressed: report.document.isEmpty
                              ? null
                              : () => DownloadFile.downloadFromUrl(
                                  url: report.document,
                                  fileName: report.title,
                                ),
                          icon: const Icon(Icons.download_outlined, size: 18),
                          label: Text(
                            report.document.isEmpty
                                ? 'File unavailable'
                                : 'Download report',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  });
}
