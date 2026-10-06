import 'package:private_deals/src/features/investors/presentation/legacy/investor_list_card.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/investor_filter/investor_filter_dialog.dart';

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
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const TitleText("Investors"),
                  const Spacer(),
                  CustomOutlinedButton(
                    color: context.theme.iconTheme.color,
                    width: 100,
                    height: 45,
                    onPressed: () {
                      showCustomDialog(const InvestorFilterDialog());
                    },
                    child: const Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  CustomElevatedButton(
                    width: 100,
                    height: 45,
                    onPressed: () async {
                      final result = await Get.toNamed(
                        Routes.addInvestorPath(Get.currentRoute),
                      );
                      if (result == true) {
                        await c.getInvestorList();
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Clients linked to this account. Open KYC to verify investor details.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              SearchBarTextField(
                onChanged: (p0) => c.search(p0),
                hintText: 'Search name, email or mobile',
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
