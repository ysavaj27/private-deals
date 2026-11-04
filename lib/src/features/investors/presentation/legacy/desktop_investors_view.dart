import 'package:private_deals/src/features/investors/presentation/legacy/investor_list_card.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

import 'investors_toolbar.dart';

class DesktopInvestorsView extends StatelessWidget {
  final InvestorsPageCtrl c = Get.find<InvestorsPageCtrl>();

  DesktopInvestorsView({super.key});

  void _openPortfolio(InvestorModel model) {
    final portfolioCtrl = Get.find<PortfolioPageCtrl>();
    final homeCtrl = Get.find<HomePageCtrl>();
    homeCtrl.currentTab(WTabBarEnum.portfolio);
    portfolioCtrl.selectedInvestor.add(model.id);
    portfolioCtrl.getStartupPortfolio();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        body: Padding(
          padding: AppPagePadding.of(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: 'Investors',
                subtitle: 'Clients linked to this account. Open KYC to verify investor details.',
              ),
              const SizedBox(height: AppSpace.xl),
              const InvestorsToolbar(),
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
                      itemCount: c.finalList.length,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.md,
                      ),
                      itemBuilder: (context, index) {
                        final model = c.finalList[index];
                        return InvestorListCard(
                          investor: model,
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
        ),
      ),
    );
  }
}
