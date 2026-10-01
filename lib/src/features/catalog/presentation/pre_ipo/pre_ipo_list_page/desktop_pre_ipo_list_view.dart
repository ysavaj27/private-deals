import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_landing_page/desktop_pre_ipo_landing_view.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/secondary/desktop_secondary_landing_view.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_list_page/pre_ipo_list_page_ctrl.dart';

class DesktopPreIPOListView extends StatelessWidget {
  final PreIPOListPageCtrl c = Get.find<PreIPOListPageCtrl>();

  DesktopPreIPOListView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: onBackPressed,
          ),
          title: Text(
              "${(Get.parameters['type'] ?? "").toString().capitalizeFirst}"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            physics: const CustomScrollPhysics(),
            controller: c.scrollController,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: SliverAppBarDelegate(
                  minHeight: 60.0,
                  maxHeight: 80.0,
                  child: Container(
                    color: context.theme.scaffoldBackgroundColor,
                    child: SearchBarTextField(
                      radius: 6,
                      focusNode: c.searchFocusNode,
                      hintText: "Search Company's",
                      onChanged: (p0) => c.search(p0),
                    ),
                  ),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  const cardWidth = 340.0;
                  const spacing = 20.0;

                  final crossAxisCount =
                      ((constraints.crossAxisExtent + spacing) /
                              (cardWidth + spacing))
                          .floor()
                          .clamp(1, 10);

                  return Obx(() {
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var model = c.list[index];
                          return CustomCompanyCard(
                            company: model,
                            onTap: () {
                              if (c.isSecondary) {
                                var route = Routes.preIPODetailPath(
                                    "/wealth-manager/${WTabBarEnum.secondary.slug}",
                                    model.slug);
                                logger.d(route);
                                Get.toNamed(route);
                              } else {
                                var route = Routes.preIPODetailPath(
                                    "/wealth-manager/${WTabBarEnum.preIPO.slug}",
                                    model.slug);
                                logger.d(route);
                                Get.toNamed(route);
                              }
                            },
                          );
                        },
                        childCount: c.list.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        mainAxisExtent: 120,
                      ),
                    );
                  });
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class CustomCompanyCard extends StatelessWidget {
  final CompanyModel model;
  final void Function()? onTap;

  const CustomCompanyCard(this.model, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        context.isDarkMode ? const Color(0xff101010) : Colors.white;

    final textColor = context.theme.iconTheme.color;

    return Column(
      children: [
        Clickable(
          onTap: onTap,
          child: SizedBox(
            width: 340,
            height: 262,
            child: Container(
              width: 340,
              height: 262,
              color: baseColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 38,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CacheImage(url: model.logo),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    model.brandName,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${model.sharePrice.toCurrency} ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Text(
                        model.profitLossString,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          height: 3,
          width: 340,
          color: context.theme.iconTheme.color,
        ),
      ],
    );
  }
}
*/
