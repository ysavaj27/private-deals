import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/channel_partner_page_ctrl.dart';

class DesktopChannelPartnerView extends StatelessWidget {
  final ChannelPartnerPageCtrl c = Get.find<ChannelPartnerPageCtrl>();

  DesktopChannelPartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  const TitleText("Channel Partner"),
                  const Spacer(),
                  CustomElevatedButton(
                    width: 150,
                    onPressed: () async {
                      var res = await showCustomDialog(
                        AddChannelPartnerDialog(),
                      );
                      Get.delete<AddChannelPartnerDialogCtrl>();
                      if (res == true) {
                        c.getData();
                      }
                    },
                    child: const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Obx(() {
                if (c.isLoading.isFalse) {
                  if (c.list.isNotEmpty) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: c.list.map((model) {
                            return SizedBox(
                              height: 300,
                              width: 450,
                              child: CustomCardWidget(
                                radius: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 24),
                                        Container(
                                          height: 100,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: context
                                                .theme
                                                .scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: context.theme.disabledColor
                                                  .withValues(alpha: 0.1),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: CacheImage(
                                            url: model.profile,
                                            placeHolderImage:
                                                model.placeholderImage,
                                            // url:
                                            //     "https://s3-ap-south-1.amazonaws.com/shuruup-main/public/startup/banner/1667892234.6323.png",
                                            // height: 97,
                                            // width: 97,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              model.name.capitalFirst,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            // const SizedBox(height: 4),
                                            Text(
                                              model.email.toLowerCase(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: context
                                                    .theme
                                                    .disabledColor
                                                    .withValues(alpha: 0.5),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(model.type),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Mobile : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context
                                                        .theme
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "${model.mobileNumber}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Total Investors : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context
                                                        .theme
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "${model.investorCount}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Amount Invested : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context
                                                        .theme
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  model
                                                      .totalInvested
                                                      .toFormattedPrice,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "No. of Startup : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context
                                                        .theme
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "${model.noOfStartups}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Commission Earned : ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: context
                                                        .theme
                                                        .disabledColor
                                                        .withValues(alpha: 0.5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  model
                                                      .commissionEarned
                                                      .toFormattedPrice,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  } else {
                    return NoDataView(onPressed: c.getData);
                  }
                } else {
                  return const Loader();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
