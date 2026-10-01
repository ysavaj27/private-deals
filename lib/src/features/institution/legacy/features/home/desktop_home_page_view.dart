import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:private_deals/src/features/institution/legacy/features/home/custom_appbar.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/desktop_sidebar.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page.dart';
import 'package:private_deals/src/features/institution/legacy/features/home/home_page_ctrl.dart';

class DesktopHomePageView extends StatelessWidget {
  final Widget? child;
  final SellerHomePageCtrl c = Get.find<SellerHomePageCtrl>();

  DesktopHomePageView({super.key, this.child});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SizedBox(),
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
