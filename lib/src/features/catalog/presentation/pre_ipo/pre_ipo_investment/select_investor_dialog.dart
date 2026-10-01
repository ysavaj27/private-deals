import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page.dart';
import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_detail_page/pre_ipo_detail_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class SelectInvestorDialog extends StatefulWidget {
  const SelectInvestorDialog({super.key});

  @override
  State<SelectInvestorDialog> createState() => _SelectInvestorDialogState();
}

class _SelectInvestorDialogState extends State<SelectInvestorDialog> {
  final PreIPODetailPageCtrl c = Get.find<PreIPODetailPageCtrl>();

  late final Future<BaseModel<List<InvestorModel>>> _investorsFuture;

  final List<InvestorModel> selectedInvestors = [];

  @override
  void initState() {
    super.initState();

    _investorsFuture = WInvestorsApi.investorsList(
      isKyc: FilterTypeEnum.All.name,
      isActive: FilterTypeEnum.All.name,
      isAif: FilterTypeEnum.All.name,
    ).then((response) {
      final investors = response.r ?? [];

      // Initialize already-selected investors.
      for (final model in investors) {
        final exists = c.investorList.any(
          (e) => e.investorId == model.id,
        );

        if (exists && !selectedInvestors.contains(model)) {
          selectedInvestors.add(model);
        }
      }

      return response;
    });
  }

  void _toggleInvestor(
    InvestorModel model,
    bool? isSelected,
  ) {
    setState(() {
      if (isSelected == true) {
        if (!selectedInvestors.contains(model)) {
          selectedInvestors.add(model);
        }
      } else {
        selectedInvestors.remove(model);
      }
    });
  }

  void _registerInvestor() {
    Get.back();

    Get.to(
      () => AddInvestorPage(),
    );
  }

  void _selectInvestors() {
    Get.back(
      result: selectedInvestors,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;

    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      width: isPhone ? context.width * 0.9 : 600,
      padding: isPhone
          ? const EdgeInsets.all(10)
          : const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------------------------------------------------
          // Header
          // ------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Investors",
                style: TextStyle(
                  fontSize: isPhone ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.borderColor(context),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Divider(height: 1),

          const SizedBox(height: 10),

          // ------------------------------------------------------------
          // Investor List
          // ------------------------------------------------------------
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: isPhone ? context.height * 0.5 : context.height * 0.6,
              minHeight: 100,
            ),
            child: FutureBuilder<BaseModel<List<InvestorModel>>>(
              future: _investorsFuture,
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // No response
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final investors = snapshot.data?.r;

                // Empty response
                if (investors == null || investors.isEmpty) {
                  return const Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // ------------------------------------------------------
                // IMPORTANT:
                // Do NOT modify selectedInvestors here.
                //
                // FutureBuilder.builder should only build/read UI.
                // ------------------------------------------------------

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: investors.map((model) {
                      return InkWell(
                        mouseCursor: SystemMouseCursors.click,

                        // If investor does not have Pre-IPO access,
                        // open AddInvestorPage.
                        onTap: !model.isPreIpoAccess
                            ? () {
                                Get.back();

                                Get.to(
                                  () => AddInvestorPage(),
                                  arguments: model,
                                );
                              }
                            : null,

                        // Long press always opens AddInvestorPage.
                        onLongPress: () {
                          Get.back();

                          Get.to(
                            () => AddInvestorPage(),
                            arguments: model,
                          );
                        },

                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          clipBehavior: Clip.antiAlias,
                          child: CheckboxListTile(
                            dense: isPhone,
                            enabled: model.isPreIpoAccess,
                            value: selectedInvestors.contains(model),
                            onChanged: (bool? isSelected) {
                              _toggleInvestor(
                                model,
                                isSelected,
                              );
                            },
                            title: Text(
                              model.name,
                              style: TextStyle(
                                fontSize: isPhone ? 14 : 16,
                              ),
                            ),
                            subtitle: model.isPreIpoAccess
                                ? null
                                : Text(
                                    "Investor don't have "
                                    "Unlisted Shares access",
                                    style: TextStyle(
                                      fontSize: isPhone ? 10 : 13,
                                    ),
                                  ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------------
          // Bottom Buttons
          // ------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: selectedInvestors.isEmpty,
                child: CustomElevatedButton(
                  width: isPhone ? 120 : 120,
                  height: isPhone ? 35 : 40,
                  text: 'Register',
                  onPressed: _registerInvestor,
                ),
              ),
              // const SizedBox(width: 20),
              Visibility(
                visible: selectedInvestors.isNotEmpty,
                child: CustomElevatedButton(
                  width: isPhone ? 120 : 120,
                  height: isPhone ? 35 : 40,
                  text: "Select",
                  onPressed: _selectInvestors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
