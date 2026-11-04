import 'package:private_deals/src/shared/app_exports.dart';

import 'portfolio_page_ctrl.dart';
import 'startup_portfolio_view.dart';
import 'unlisted_portfolio_view.dart';

class PhonePortfolioView extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  PhonePortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPagePadding.of(context, bottom: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: !app.wUser.isPreIPOOnly,
            child: TabBar(
              controller: c.tabController,
              splashBorderRadius: AppRadii.tabAll,
              tabs: c.tabs,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: c.tabController,
              children: c.tabViews,
            ),
          ),
        ],
      ),
    );
  }
}

class PreIpoListWidget extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();
  PreIpoListWidget({super.key});
  @override
  Widget build(BuildContext context) => Obx(() {
    final child = c.isLoading.isTrue
        ? const Loader(key: ValueKey('portfolio-preipo-loading'))
        : UnlistedPortfolioView(
            key: const ValueKey('portfolio-preipo-content'),
            list: c.preIpoList.toList(),
            onRefresh: c.getStartupPortfolio,
          );
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.normal),
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeInOut,
      child: child,
    );
  });
}

class ListWidget extends StatelessWidget {
  ListWidget(this.data, {super.key, required this.type});

  final RxList<StartupPortfolioListModel> data;
  final EquityTypeEnum type;
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  @override
  Widget build(BuildContext context) => Obx(() {
    final child = c.isLoading.isTrue
        ? const Loader(key: ValueKey('portfolio-loading'))
        : StartupPortfolioView(
            key: ValueKey('phone-portfolio-${type.name}'),
            type: type,
            list: data.toList(),
            onRefresh: c.getStartupPortfolio,
          );
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, AppMotion.normal),
      switchInCurve: AppMotion.easeOut,
      switchOutCurve: AppMotion.easeInOut,
      child: child,
    );
  });
}
