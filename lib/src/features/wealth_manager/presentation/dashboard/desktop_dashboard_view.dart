import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_sections.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/investor_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/phone_dashboard_view.dart';

class DesktopDashboardView extends StatelessWidget {
  final DashboardPageCtrl c = Get.find<DashboardPageCtrl>();

  DesktopDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
        () {
          if (c.isLoading.isFalse && c.isData.isTrue) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Visibility(
                        visible: app.wUser.isPreIpoAccess,
                        child: TabButton(
                          title: "Unlisted",
                          type: DashboardTypeEnum.preIpo,
                          onTap: () {
                            c.changeTab(DashboardTypeEnum.preIpo);
                          },
                          currentIndex: c.currentIndex,
                          // size: context,
                        ),
                      ),
                      Visibility(
                        visible: app.wUser.isPreIpoAccess &&
                            (app.wUser.isSecondaryAccess ||
                                app.wUser.isPrimaryAccess),
                        child: const SizedBox(width: 10),
                      ),
                      Visibility(
                        visible: app.wUser.isSecondaryAccess ||
                            app.wUser.isPrimaryAccess,
                        child: TabButton(
                          title: "Private Equity",
                          type: DashboardTypeEnum.primary,
                          onTap: () {
                            c.changeTab(DashboardTypeEnum.primary);
                          },
                          currentIndex: c.currentIndex,
                          // size: context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const DashboardHeroCard(),
                  const SizedBox(height: AppSpace.lg),
                  const DashboardKpiStrip(),
                  const SizedBox(height: AppSpace.lg),
                  const DashboardPendingStrip(),
                  const SizedBox(height: AppSpace.lg),
                  DashboardTopInvestors(
                    onViewAll: () => showCustomDialog(InvestorDialog()),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  const DashboardSectionHeader(
                    title: 'Insights',
                    subtitle: 'Sectors, investors & growth',
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: c.numberPieChartList.isNotEmpty ||
                              c.investmentPieChartList.isNotEmpty,
                          child: CustomCardWidget(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: context.theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Sector Bifurcation",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: NumberPieChartWidget(),
                                      ),
                                      Expanded(
                                        child: InvestmentPieChart(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Visibility(
                          visible: c.columnList().isNotEmpty,
                          child: CustomCardWidget(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: context.theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Investment growth",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(height: 300, child: ColumnChart()),
                                  // SizedBox(
                                  //   height: 300,
                                  //   child: BarChartSample2(),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: c.kycInvestorList.isNotEmpty ||
                              c.activeInvestorList.isNotEmpty,
                          child: CustomCardWidget(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: context.theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        "Investors",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: KycInvestorPieChart(),
                                      ),
                                      Expanded(
                                        child: ActiveInvestorPieChart(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(child: SizedBox()),
                      // const Expanded(
                      //   child: InvestmentChart(),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (c.isLoading.isTrue) {
            return const Loader();
          } else {
            return ErrorView(
              title: 'Unable to load dashboard',
              message: 'Try again to reload your dashboard.',
              onRetry: c.getData,
            );
          }
        },
    );
  }
}

class DCardWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  const DCardWidget({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 14),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: context.theme.disabledColor,
              ),
            ),
            const SizedBox(height: 27),
            Text(
              subTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
