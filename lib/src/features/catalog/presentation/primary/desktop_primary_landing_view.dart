import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';

part 'primary_landing_content.dart';
part 'primary_deal_sections.dart';
part 'primary_startup_card.dart';

class DesktopPrimaryLandingView extends StatelessWidget {
  final PrimaryLandingPageCtrl c = Get.find<PrimaryLandingPageCtrl>();

  DesktopPrimaryLandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: c.scaffoldKey,
      // appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      // endDrawer: const NotificationDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        controller: c.scrollController,
        // physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            LiveDealWidget(),
            const SizedBox(height: 90),
            Visibility(
              visible: c.model().comingSoon.isNotEmpty,
              child: ComingSoonWidget(),
            ),
            Visibility(
              visible: c.model().comingSoon.isNotEmpty,
              child: const SizedBox(height: 90),
            ),
            CompletedWidget(),
            const SizedBox(height: 90),
            FeaturedWidget(),
            const SizedBox(height: 90),
            BlogWidget(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
