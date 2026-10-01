import 'package:private_deals/src/features/wealth_manager/presentation/home_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/notification/notification_page.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';
import 'package:private_deals/src/features/catalog/presentation/primary/primary_list_page/primary_list_page.dart';

class DashboardDrawer extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.put(PrimaryLandingPageCtrl());

  DashboardDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: context.height,
        width: 271,
        decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
        child: Column(
          children: [
            Container(
              height: 19,
              width: Get.width,
              decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(16))),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    // ListTile(
                    //   leading: const SVGImage(AppAssets.homeIc),
                    //   title: const Text("Home"),
                    //   onTap: () {
                    //     Get.back();
                    //   },
                    // ),

                    Visibility(
                      visible: app.isUserLogin,
                      child: ListTile(
                        leading: SVGImage(
                          AppAssets.dashboardIc2,
                          height: 18,
                          width: 18,
                          colorFilter: ColorFilter.mode(
                            context.theme.primaryColorLight,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: const Text("Dashboard"),
                        onTap: () {
                          Get.back();
                          Get.offAll(() => HomePage());
                          // Get.back();
                        },
                      ),
                    ),
                    const Divider(height: 5),
                    ExpansionTile(
                      textColor: context.theme.primaryColor,
                      iconColor: context.theme.primaryColor,
                      shape:
                          const RoundedRectangleBorder(side: BorderSide.none),
                      title: const Text("Invest"),
                      leading: const SizedBox(
                        height: 20,
                        child: SVGImage(AppAssets.investIc),
                      ),
                      children: [
                        Column(
                          children: [
                            SubPTableTileWidget(
                              onTap: () {
                                Get.back();
                                Get.to(() => PrimaryListPage(),
                                    arguments: c.model().comingSoon);
                              },
                              icon: AppAssets.timerIc,
                              title: "Launching soon",
                              subTitle:
                                  "View the start-ups which will be launched soon on the platform and get a glance of the start-up’s product video.",
                            ),
                            const SizedBox(height: 10),
                            SubPTableTileWidget(
                              onTap: () {
                                Get.back();
                                Get.to(() => PrimaryListPage(),
                                    arguments: c.model().raisingNow);
                              },
                              icon: AppAssets.raiseNowIc,
                              title: "Raising Now",
                              subTitle:
                                  "Jump into the details of the start-ups of your interest and start your investment journey with a few clicks.",
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),
                    Visibility(
                      visible: app.isUserLogin,
                      child: const Divider(height: 5),
                    ),
                    Visibility(
                      visible: app.isUserLogin,
                      child: ListTile(
                        leading: const SVGImage(AppAssets.notificationIc2),
                        title: const Text('Notification'),
                        onTap: () {
                          Get.back();
                          Get.to(() => const NotificationPage());
                        },
                      ),
                    ),
                    const Divider(height: 5),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.support_agent,
                    //     color: context.theme.primaryColor,
                    //   ),
                    //   title: const Text("Inquiry"),
                    //   onTap: () {
                    //     Get.to(() => InquiryPage());
                    //   },
                    // ),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              height: 19,
              width: Get.width,
              decoration: BoxDecoration(
                  color: context.theme.primaryColor,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(16))),
            ),
          ],
        ),
      ),
    );
  }
}

class SubPTableTileWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String subTitle;
  final void Function()? onTap;

  const SubPTableTileWidget(
      {super.key,
      required this.icon,
      required this.title,
      required this.subTitle,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 45),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SVGImage(icon),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 3),
                  Text(
                    subTitle,
                    style: TextStyle(
                        color: context.theme.disabledColor, fontSize: 12),
                    maxLines: 4,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
