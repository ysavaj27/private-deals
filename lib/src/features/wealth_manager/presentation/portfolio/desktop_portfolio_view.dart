import 'unlisted_portfolio_view.dart';
import 'startup_portfolio_view.dart';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';

class DesktopPortfolioView extends StatelessWidget {
  final PortfolioPageCtrl c = Get.find<PortfolioPageCtrl>();

  DesktopPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: AppPagePadding.of(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const TitleText('Portfolio'),
                const Spacer(),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: TabButton(
                    title: 'Unlisted',
                    type: EquityTypeEnum.preIpo,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.preIpo);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible: app.wUser.isPreIpoAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: 'Equity',
                    type: EquityTypeEnum.equity,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.equity);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: 'CCPS',
                    type: EquityTypeEnum.ccps,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.ccps);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: const SizedBox(width: 10),
                ),
                Visibility(
                  visible:
                      app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess,
                  child: TabButton(
                    title: 'CCD',
                    type: EquityTypeEnum.ccd,
                    onTap: () {
                      c.changeTab(EquityTypeEnum.ccd);
                    },
                    currentIndex: c.currentIndex,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            Expanded(
              child: Obx(() {
                final Widget child;
                if (c.isLoading.isFalse) {
                  if (c.currentIndex() == EquityTypeEnum.preIpo) {
                    child = UnlistedPortfolioView(
                      key: const ValueKey('desktop-portfolio-preipo'),
                      list: c.preIpoList.toList(),
                      onRefresh: c.getStartupPortfolio,
                    );
                  } else {
                    child = StartupPortfolioView(
                      key: ValueKey(
                        'desktop-portfolio-${c.currentIndex().name}',
                      ),
                      type: c.currentIndex(),
                      list: c.currentList.toList(),
                      onRefresh: c.getStartupPortfolio,
                    );
                  }
                } else {
                  child = const Loader(
                    key: ValueKey('desktop-portfolio-loading'),
                  );
                }
                return AnimatedSwitcher(
                  duration: AppMotion.duration(context, AppMotion.normal),
                  switchInCurve: AppMotion.easeOut,
                  switchOutCurve: AppMotion.easeInOut,
                  child: child,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
