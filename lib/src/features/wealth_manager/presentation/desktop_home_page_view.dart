import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_appbar.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/desktop_sidebar.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/notification/notification_page.dart';

class DesktopHomePageView extends StatelessWidget {
  final Widget? child;
  final HomePageCtrl c = Get.find<HomePageCtrl>();

  DesktopHomePageView({super.key, this.child});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const NotificationDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 66),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 260),
                        Expanded(child: child ?? MainWidgets()),
                      ],
                    ),
                    DSideBarWidget(),
                  ],
                ),
              ),
            ],
          ),
          CustomAppBar(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
