import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/investors/presentation/legacy/show_more_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/portfolio/portfolio_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/investors_page_ctrl.dart';

class PhoneInvestorsView extends StatelessWidget {
  final InvestorsPageCtrl c = Get.find<InvestorsPageCtrl>();

  PhoneInvestorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (c.isLoading.isFalse) {
            if (c.investorList.isNotEmpty) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: c.finalList.length,
                itemBuilder: (context, index) {
                  var model = c.finalList[index];
                  // if(index ==0)logger.d(model.toJson());
                  return CustomCardWidget(
                    margin: EdgeInsets.only(bottom: 25),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LogoImage(
                              url: model.profile,
                              placeHolderImage: model.placeholderImage,
                              radius: 4,
                              height: 46,
                              width: 46,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    model.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    model.email,
                                    style: TextStyle(
                                      color: context.theme.disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Align(
                            //   alignment: Alignment.topCenter,
                            //   child: CustomElevatedButton(
                            //     radius: 8,
                            //     padding: EdgeInsets.zero,
                            //     text: 'More',
                            //     width: 84,
                            //     height: 28,
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //     onPressed: () async {},
                            //   ),
                            // ),
                          ],
                        ),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Get.toNamed('/investors/${model.id}/cml'), child: const Text('CML'))),
                        SizedBox(height: 16),
                        CustomCardWidget(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 22,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "No of startups",
                                    style: TextStyle(
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${model.noOfStartups}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 26),
                              Row(
                                children: [
                                  Text(
                                    "Total Invested",
                                    style: TextStyle(
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${model.totalInvested.toFormattedPrice}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 26),
                              Row(
                                children: [
                                  Text(
                                    "Commission Earned",
                                    style: TextStyle(
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${model.commissionEarned.toFormattedPrice}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 26),
                              Row(
                                children: [
                                  Text(
                                    "Mobile",
                                    style: TextStyle(
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${model.mobileNumber}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 26),
                              Row(
                                children: [
                                  Text(
                                    "City",
                                    style: TextStyle(
                                      color: context
                                          .theme
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    "${model.city.name}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Visibility(
                          visible: model.startupList.isNotEmpty,
                          child: Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  var portfolioCtrl =
                                      Get.find<PortfolioPageCtrl>();
                                  var homeCtrl = Get.find<HomePageCtrl>();
                                  homeCtrl.currentTab(WTabBarEnum.portfolio);
                                  portfolioCtrl.selectedInvestor.add(model.id);
                                  portfolioCtrl.getStartupPortfolio();
                                },
                                child: Text(
                                  "View Portfolio",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showCustomDialog(ShowMoreDialog(user: model));
                                },
                                child: Text(
                                  "Show More",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return NoDataView();
            }
          } else {
            return Loader();
          }
        }),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () {
              Get.toNamed(
                Routes.addInvestorPath(
                  "/wealth-manager/${WTabBarEnum.investors.slug}",
                ),
              );
            },
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
