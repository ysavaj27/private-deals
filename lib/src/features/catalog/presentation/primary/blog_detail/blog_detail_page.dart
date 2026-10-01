import 'package:flutter_html/flutter_html.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/blog_detail/blog_detail_page_ctrl.dart';

class BlogDetailPage extends StatelessWidget {
  final BlogDetailPageCtrl c = Get.put(BlogDetailPageCtrl());

  BlogDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // iconTheme: IconThemeData(color: context.theme.shadowColor),
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.symmetric(
              vertical: 40,
              horizontal: context.isPhone ? 0 : context.width * 0.15),
          child: Stack(
            children: [
              Container(
                height: context.isPhone ? 300 : 400,
                width: context.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: context.theme.dividerColor.withValues(alpha: 0.02),
                  border: Border.all(color: context.theme.dividerColor),
                ),
                child: Obx(() {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: "${c.model().id}",
                      child: CacheImage(
                        url: c.model().banner,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
              ),
              CustomCardWidget(
                margin: EdgeInsets.only(
                    top: context.isPhone ? 240 : 350,
                    right: context.isPhone ? 20 : 60,
                    left: context.isPhone ? 20 : 60),
                radius: 20,
                color: context.theme.scaffoldBackgroundColor,
                child: Container(
                  width: Get.width,
                  padding: EdgeInsets.all(context.isPhone ? 20 : 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: context.theme.disabledColor,
                          ),
                          SizedBox(width: 5),
                          Obx(() {
                            return Text(
                              c.model().createdAt.dateWithSortMonthYear,
                              style: TextStyle(
                                fontSize: context.isPhone ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                color: context.theme.disabledColor,
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: context.isPhone ? 10 : 20),
                      Divider(thickness: 0.5),
                      SizedBox(height: context.isPhone ? 20 : 40),
                      Obx(() {
                        return Text(
                          c.model().title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: context.isPhone ? 22 : 30,
                          ),
                        );
                      }),
                      SizedBox(height: context.isPhone ? 30 : 50),
                      Obx(() {
                        return Html(data: c.model().longDescription);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
