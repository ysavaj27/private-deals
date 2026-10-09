import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';

import 'dashboard_components.dart';
import 'dashboard_details.dart';
import 'dashboard_insights.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({
    super.key,
    required this.model,
    required this.isPrimary,
  });
  final WDashboardModel model;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (
        'Total invested',
        dashboardMoney(model.totalAmountInvested),
        Icons.account_balance_wallet_outlined,
        'Invested capital',
      ),
      (
        'Average ticket',
        dashboardMoney(model.averageTicketSize),
        Icons.payments_outlined,
        'Per investment',
      ),
      (
        'Investors',
        '${model.totalInvestors}',
        Icons.people_outline_rounded,
        'In this portfolio',
      ),
      (
        isPrimary ? 'Startups' : 'Companies',
        '${model.totalStartups}',
        Icons.apartment_rounded,
        'In this portfolio',
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >=
                  MediaQuery.textScalerOf(context).scale(300)
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: width,
                child: CustomCardWidget(
                  padding: const EdgeInsets.all(20),
                  color: i == 0 ? theme.colorScheme.primaryContainer : null,
                  borderColor: i == 0
                      ? theme.colorScheme.primary.withValues(alpha: .35)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        items[i].$3,
                        size: 21,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Tooltip(
                        message: i < 2
                            ? dashboardMoney(
                                i == 0
                                    ? model.totalAmountInvested
                                    : model.averageTicketSize,
                                full: true,
                              )
                            : items[i].$2,
                        child: Text(
                          items[i].$2,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(items[i].$1, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$4,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DashboardPriorities extends StatelessWidget {
  const DashboardPriorities({
    super.key,
    required this.model,
    this.readOnly = false,
  });
  final WDashboardModel model;
  final bool readOnly;

  void _open(PendingTaskEnum type) {
    Get.find<HomePageCtrl>().onTap(WTabBarEnum.pendingTasks);
    // Select on the destination page after its route has created the controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<KycPendingInvestorPageCtrl>() &&
          Get.isRegistered<HomePageCtrl>() &&
          Get.find<HomePageCtrl>().currentTab() == WTabBarEnum.pendingTasks) {
        Get.find<KycPendingInvestorPageCtrl>().selectType(type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clear =
        model.pendingKyc == 0 &&
        model.pendingDocumentSign == 0 &&
        model.pendingPayment == 0;
    final items = [
      (
        'KYC pending',
        '${model.pendingKyc}',
        model.pendingKyc > 0,
        PendingTaskEnum.kyc,
      ),
      (
        'Documents to sign',
        '${model.pendingDocumentSign}',
        model.pendingDocumentSign > 0,
        PendingTaskEnum.document,
      ),
      // The dashboard payment field has no confirmed count/amount contract.
      // Keep its actionable state without adding it to task totals.
      (
        'Fund transfers',
        model.pendingPayment > 0 ? 'Review' : 'Clear',
        model.pendingPayment > 0,
        PendingTaskEnum.fundTransfer,
      ),
    ];
    return CustomCardWidget(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                clear ? Icons.check_circle_outline : Icons.task_alt_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              Text('Investor priorities', style: theme.textTheme.titleSmall),
              Text(
                clear
                    ? 'No pending actions reported'
                    : 'Follow up to move investments forward',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 640 ? 3 : 1;
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    SizedBox(
                      width:
                          (constraints.maxWidth - (columns - 1) * 12) / columns,
                      child: Material(
                        color: theme.colorScheme.surfaceContainerHigh
                            .withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: readOnly ? null : () => _open(item.$4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.$1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.$2,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: item.$3
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardTopInvestors extends StatelessWidget {
  const DashboardTopInvestors({super.key, required this.model});
  final WDashboardModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = [...model.topInvestors]
      ..sort((a, b) => b.amountInvested.compareTo(a.amountInvested));
    return DashboardPanel(
      title: 'Leading investors',
      subtitle: 'Ranked by invested capital in this portfolio.',
      trailing: model.investors.isEmpty
          ? null
          : TextButton.icon(
              onPressed: () =>
                  showDashboardInvestorDirectory(context, model.investors),
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('View investor directory'),
            ),
      child: list.isEmpty
          ? const DashboardEmpty(
              title: 'No leading investors yet',
              message: 'Investor contributions will appear here when investment data is available.',
              icon: Icons.people_outline,
            )
          : Column(
              children: [
                for (var i = 0; i < list.take(5).length; i++) ...[
                  if (i > 0) const Divider(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${i + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              list[i].name.isEmpty
                                  ? 'Unnamed investor'
                                  : list[i].name,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 5),
                            Wrap(
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                DashboardAmount(
                                  list[i].amountInvested,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  '${list[i].totalStartups} companies',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (list[i].commissionEarned > 0)
                                  Text(
                                    'Commission ${dashboardMoney(list[i].commissionEarned)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (list.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton(
                      onPressed: () =>
                          showDashboardInvestorDirectory(context, list),
                      child: Text('View all ${list.length} leading investors'),
                    ),
                  ),
              ],
            ),
    );
  }
}

class DashboardGettingStarted extends StatelessWidget {
  const DashboardGettingStarted({super.key, required this.isPrimary});
  final bool isPrimary;
  @override
  Widget build(BuildContext context) => DashboardPanel(
    title: 'A clear view, from your first investment',
    subtitle: 'Your portfolio insights will build as investments are recorded.',
    child: Column(
      children: [
        const DashboardEmpty(
          title: 'No investments to show yet',
          message: 'Explore opportunities for your investors. Once investments are available, you will see activity, sector exposure and company performance here.',
          icon: Icons.account_balance_wallet_outlined,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Get.find<HomePageCtrl>().onTap(
                isPrimary ? WTabBarEnum.primary : WTabBarEnum.preIPO,
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Explore opportunities'),
            ),
            TextButton(
              onPressed: () =>
                  Get.find<HomePageCtrl>().onTap(WTabBarEnum.investors),
              child: const Text('View investors'),
            ),
          ],
        ),
      ],
    ),
  );
}
