import 'dart:ui';

import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/investor_list_dialog/investor_list_dialog_ctrl.dart';

class InvestorListDialog extends StatelessWidget {
  final InvestorListDialogCtrl c = Get.put(InvestorListDialogCtrl());

  InvestorListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      width: 600,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Investors",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints.fromViewConstraints(ViewConstraints(
                maxHeight: context.height * 0.6, minHeight: 100)),
            child: Obx(() {
              if (c.isLoading.isFalse) {
                if (c.investorList.isNotEmpty) {
                  return SingleChildScrollView(
                    child: Wrap(
                      children: c.investorList.map((model) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  model.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              CustomElevatedButton(
                                padding:context.isPhone? const EdgeInsets.symmetric(horizontal: 8, vertical: 4):null,
                                width: 80,
                                height: 35,
                                text: "Invest now",
                                onPressed: () {
                                  Get.back(result: model);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: 200,
                    child: InlineEmptyView(height: 200),
                  );
                }
              } else {
                return const SizedBox(
                  height: 200,
                  child: Loader(),
                );
              }
            }),
          )
        ],
      ),
    );
  }
}
