import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/investor_filter_dialog.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investor_list_card.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';

class PhoneInvestorsView extends StatelessWidget {
  final InvestorsPageCtrl c = Get.find<InvestorsPageCtrl>();

  PhoneInvestorsView({super.key});

  void _openPortfolio(InvestorModel model) {
    final portfolioCtrl = Get.find<PortfolioPageCtrl>();
    final homeCtrl = Get.find<HomePageCtrl>();
    homeCtrl.currentTab(WTabBarEnum.portfolio);
    portfolioCtrl.selectedInvestor.add(model.id);
    portfolioCtrl.getStartupPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                AppSpace.sm,
                AppSpace.lg,
                AppSpace.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarTextField(
                      onChanged: (p0) => c.search(p0),
                      hintText: 'Search name, email or mobile',
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter',
                    onPressed: () {
                      showCustomDialog(const InvestorFilterDialog());
                    },
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isTrue) {
                  return const Loader();
                }
                if (c.finalList.isEmpty) {
                  return NoDataView(
                    onPressed: c.getInvestorList,
                    isRefreshButton: c.isSearching.isTrue ? false : true,
                  );
                }
                return RefreshIndicator(
                  onRefresh: c.getInvestorList,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.sm,
                      AppSpace.lg,
                      88,
                    ),
                    itemCount: c.finalList.length,
                    itemBuilder: (context, index) {
                      final model = c.finalList[index];
                      return InvestorListCard(
                        investor: model,
                        compact: true,
                        onOpenKyc: () => c.openKyc(context, model),
                        onViewPortfolio: () => _openPortfolio(model),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        Positioned(
          right: AppSpace.lg,
          bottom: AppSpace.lg,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await Get.toNamed(
                Routes.addInvestorPath(
                  "/wealth-manager/${WTabBarEnum.investors.slug}",
                ),
              );
              if (result == true) {
                await c.getInvestorList();
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
