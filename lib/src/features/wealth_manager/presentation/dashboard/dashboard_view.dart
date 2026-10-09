import 'package:intl/intl.dart';
// import 'package:flutter/foundation.dart' show kDebugMode; // Re-enable with preview checkbox.
import 'package:private_deals/src/shared/app_exports.dart';

import 'dashboard_page_ctrl.dart';
import 'dashboard_sections.dart';
import 'dashboard_charts.dart';

class WealthDashboardView extends StatelessWidget {
  const WealthDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardPageCtrl>();
    final theme = Theme.of(context);
    return Obx(() {
      final preview = c.isShowingDummyData;
      final loading = !preview && c.isLoading();
      final data = c.displayedModel;
      final hasData = preview || c.isData();
      final error = preview ? '' : c.error();
      final updated = preview ? null : c.lastUpdated();
      final hasInvestments =
          data.totalAmountInvested != 0 ||
          data.sectors.isNotEmpty ||
          data.investmentGrowth.isNotEmpty ||
          data.investments.monthly.isNotEmpty ||
          data.investments.quarterly.isNotEmpty;
      return RefreshIndicator(
        onRefresh: c.getData,
        child: SingleChildScrollView(
          controller: c.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: Padding(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final heading = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Portfolio overview',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your investments, exposure and investor priorities.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                        final controls = Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (app.wUser.isPreIpoAccess)
                              TabButton(
                                title: 'Unlisted',
                                type: DashboardTypeEnum.preIpo,
                                currentIndex: c.currentIndex,
                                onTap: () =>
                                    c.changeTab(DashboardTypeEnum.preIpo),
                              ),
                            if (app.wUser.isPrimaryAccess ||
                                app.wUser.isSecondaryAccess)
                              TabButton(
                                title: 'Private Equity',
                                type: DashboardTypeEnum.primary,
                                currentIndex: c.currentIndex,
                                onTap: () =>
                                    c.changeTab(DashboardTypeEnum.primary),
                              ),
                            IconButton.outlined(
                              tooltip: 'Refresh dashboard',
                              onPressed: loading || preview ? null : c.getData,
                              icon: const Icon(Icons.refresh_rounded),
                            ),
                          ],
                        );
                        if (constraints.maxWidth < 980) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heading,
                              const SizedBox(height: 16),
                              controls,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: heading),
                            const SizedBox(width: 20),
                            controls,
                          ],
                        );
                      },
                    ),
                    // Debug preview checkbox temporarily hidden.
                    // if (kDebugMode) ...[
                    //   const SizedBox(height: 12),
                    //   CheckboxListTile(
                    //     contentPadding: EdgeInsets.zero,
                    //     controlAffinity: ListTileControlAffinity.leading,
                    //     title: const Text('Show dummy data'),
                    //     subtitle: preview
                    //         ? const Text(
                    //             'Sample data preview. KYC and task actions are disabled.',
                    //           )
                    //         : null,
                    //     value: preview,
                    //     onChanged: (value) =>
                    //         c.setShowDummyData(value ?? false),
                    //   ),
                    // ],
                    const SizedBox(height: 16),
                    Text(
                      '${c.isPrimary ? 'Private Equity' : 'Unlisted'} portfolio${preview
                          ? ' · Sample data'
                          : updated == null
                          ? ''
                          : ' · Updated ${DateFormat('d MMM, h:mm a').format(updated)}'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (loading) ...[
                      const LinearProgressIndicator(minHeight: 3),
                      const SizedBox(height: 20),
                    ],
                    if (error.isNotEmpty) ...[
                      CustomCardWidget(
                        padding: const EdgeInsets.all(16),
                        borderColor: theme.colorScheme.error,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasData
                                  ? 'Showing the last loaded data'
                                  : 'Unable to load dashboard',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 6),
                            Text(error),
                            TextButton.icon(
                              onPressed: loading ? null : c.getData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    AnimatedSwitcher(
                      duration: AppMotion.duration(context, AppMotion.normal),
                      switchInCurve: AppMotion.easeOut,
                      switchOutCurve: AppMotion.easeInOut,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: !hasData && loading
                          ? const Padding(
                              key: ValueKey('dashboard-loading'),
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Center(
                                child: Text('Loading your portfolio…'),
                              ),
                            )
                          : !hasData
                          ? const SizedBox.shrink(key: ValueKey('dashboard-idle'))
                          : Column(
                              key: ValueKey(
                                'dashboard-content-${c.currentIndex()}-$preview',
                              ),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DashboardOverview(
                                  model: data,
                                  isPrimary: c.isPrimary,
                                ),
                                const SizedBox(height: 20),
                                DashboardPriorities(
                                  model: data,
                                  readOnly: preview,
                                ),
                                const SizedBox(height: 24),
                                if (!hasInvestments) ...[
                                  DashboardGettingStarted(
                                    isPrimary: c.isPrimary,
                                  ),
                                  const SizedBox(height: 20),
                                  DashboardInvestorChart(
                                    model: data,
                                    readOnly: preview,
                                  ),
                                ] else ...[
                                  _DashboardPair(
                                    first: DashboardActivityChart(
                                      key: ValueKey(
                                        'activity-${c.currentIndex()}-$preview',
                                      ),
                                      model: data,
                                    ),
                                    second: DashboardSectorChart(
                                      key: ValueKey(
                                        'sectors-${c.currentIndex()}-$preview',
                                      ),
                                      model: data,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _DashboardPair(
                                    first: DashboardPerformanceChart(
                                      key: ValueKey(
                                        'performance-${c.currentIndex()}-$preview',
                                      ),
                                      model: data,
                                    ),
                                    second: DashboardInvestorChart(
                                      model: data,
                                      readOnly: preview,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                if (hasInvestments ||
                                    data.investors.isNotEmpty ||
                                    data.topInvestors.isNotEmpty)
                                  DashboardTopInvestors(model: data),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _DashboardPair extends StatelessWidget {
  const _DashboardPair({required this.first, required this.second});
  final Widget first;
  final Widget second;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 1050 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.3) {
        return Column(children: [first, const SizedBox(height: 20), second]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: first),
          const SizedBox(width: 20),
          Expanded(flex: 5, child: second),
        ],
      );
    },
  );
}
