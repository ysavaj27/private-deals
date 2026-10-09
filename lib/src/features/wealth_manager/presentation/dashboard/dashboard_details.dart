import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/investors/presentation/complete_investor_kyc_button.dart';

import 'dashboard_components.dart';
import 'dashboard_page_ctrl.dart';
import 'dashboard_insights.dart';

Future<void> _showDetails(
  BuildContext context,
  String title,
  String subtitle,
  List<Widget> rows,
) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 700,
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close details',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (_, _) => const Divider(height: 28),
                itemBuilder: (_, index) => rows[index],
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

void showDashboardSector(BuildContext context, WSector sector) {
  _showDetails(
    context,
    sector.name.isEmpty ? 'Sector details' : sector.name,
    'Invested capital ${dashboardMoney(sector.totalInvestment, full: true)} · ${sector.startups.length} investment records',
    [
      if (sector.startups.isEmpty)
        const DashboardEmpty(
          title: 'No company breakdown available',
          message: 'This sector has a reported total, but no investment records were returned.',
        ),
      for (final row in sector.startups)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              row.startupName.isEmpty ? 'Unnamed company' : row.startupName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (row.investorName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(row.investorName),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Invested ${dashboardMoney(row.investmentAmount, full: true)}',
                ),
                if (row.shares > 0)
                  Text(
                    '${row.shares.toStringAsFixed(row.shares % 1 == 0 ? 0 : 2)} shares',
                  ),
                if (row.purchasePrice > 0)
                  Text(
                    'Purchase price ${dashboardMoney(row.purchasePrice, full: true)}',
                  ),
              ],
            ),
          ],
        ),
    ],
  );
}

void showDashboardInvestors(
  BuildContext context,
  String title,
  List<Active> investors, {
  bool pendingKyc = false,
  bool readOnly = false,
}) {
  _showDetails(
    context,
    title,
    '${readOnly ? 'Sample data · ' : ''}${investors.length} investors',
    [
      for (final investor in investors)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              investor.name.isEmpty ? 'Unnamed investor' : investor.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (investor.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              SelectableText(investor.email),
            ],
            if (investor.mobileNumber > 0) ...[
              const SizedBox(height: 4),
              Text('${investor.mobileNumber}'),
            ],
            if (pendingKyc && !readOnly) ...[
              const SizedBox(height: 10),
              CompleteInvestorKycButton(
                investor: InvestorModel(
                  id: investor.id,
                  name: investor.name,
                  email: investor.email,
                ),
                onSaved: () async {
                  if (context.mounted) Navigator.of(context).pop();
                  await Get.find<DashboardPageCtrl>().getData();
                },
              ),
            ],
          ],
        ),
    ],
  );
}

void showDashboardInvestorDirectory(
  BuildContext context,
  List<WInvestorModel> investors,
) {
  final sorted = [...investors]
    ..sort((a, b) => b.amountInvested.compareTo(a.amountInvested));
  _showDetails(
    context,
    'Investor directory',
    'Ranked by invested capital · ${sorted.length} investors',
    [
      for (final investor in sorted)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              investor.name.isEmpty ? 'Unnamed investor' : investor.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${dashboardMoney(investor.amountInvested, full: true)} invested · ${investor.totalStartups} companies',
            ),
          ],
        ),
    ],
  );
}
