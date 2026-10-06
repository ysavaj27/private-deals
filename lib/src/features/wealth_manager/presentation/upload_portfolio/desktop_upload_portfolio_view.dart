import 'package:searchfield/searchfield.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';

class DesktopUploadPortfolioView extends StatelessWidget {
  final UploadPortfolioCtrl c = Get.find<UploadPortfolioCtrl>();

  DesktopUploadPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const TitleText("Upload Portfolio"),
            SizedBox(height: 10),
            // Divider(),
            Expanded(child: Obx(() {
              if (c.isLoading.isTrue) {
                return Loader();
              }
              return SingleChildScrollView(
                child: SizedBox(
                  width: 550,
                  child: Form(
                    key: c.desktopKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 15,
                      children: [
                        SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: context
                                    .theme.colorScheme.onSurfaceVariant,
                                fontSize: 16),
                            children: [
                              TextSpan(text: "Select type"),
                              TextSpan(
                                text: '*',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          final tiles = <Widget>[
                            if (app.wUser.isPrimaryAccess ||
                                app.wUser.isSecondaryAccess)
                              CustomCardWidget(
                                radius: 4,
                                child: RadioListTile<DashboardTypeEnum>(
                                  title: const Text('Private Equity'),
                                  value: DashboardTypeEnum.primary,
                                  groupValue: c.currentIndex(),
                                  onChanged: (DashboardTypeEnum? v) {
                                    c.currentIndex(v);
                                    c.clearData();
                                  },
                                ),
                              ),
                            if (app.wUser.isPreIpoAccess)
                              CustomCardWidget(
                                radius: 4,
                                child: RadioListTile<DashboardTypeEnum>(
                                  title: const Text('Unlisted Company'),
                                  value: DashboardTypeEnum.preIpo,
                                  groupValue: c.currentIndex(),
                                  onChanged: (DashboardTypeEnum? v) {
                                    c.currentIndex(v);
                                    c.clearData();
                                  },
                                ),
                              ),
                          ];

                          if (tiles.isEmpty) return const SizedBox.shrink();

                          return Row(
                            children: [
                              for (int i = 0; i < tiles.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                Expanded(child: tiles[i]),
                              ],
                            ],
                          );
                        }),
                        SearchableTextField<InvestorModel>(
                          controller: c.investorCTRL,
                          hint: 'Search Investors...',
                          title: 'Select Investor',
                          isRequired: true,
                          suggestions: c.investorList
                              .map((e) =>
                                  SearchFieldListItem<InvestorModel>(e.name,
                                      item: e))
                              .toList(),
                          onSuggestionTap:
                              (SearchFieldListItem<InvestorModel> data) {
                            c.investorCTRL.text = data.item?.name ?? "";
                            c.selectedInvestor(data.item);
                          },
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Please select investor';
                            }
                            if (!c.investorList.any((company) =>
                                company.name.toLowerCase() ==
                                p0.toLowerCase())) {
                              return 'Invalid Investor selected';
                            }
                            return null;
                          },
                        ),
                        SearchableTextField<CompanyStartup>(
                          controller: c.companyCTRL,
                          hint:
                              'Search ${c.isStartUp ? "Private Equity" : "Unlisted Company"}...',
                          title:
                              'Select ${c.isStartUp ? "Private Equity" : "Unlisted Company"}',
                          isRequired: true,
                          suggestions: c.list
                              .map((e) =>
                                  SearchFieldListItem<CompanyStartup>(
                                      e.brandName,
                                      item: e))
                              .toList(),
                          onSuggestionTap:
                              (SearchFieldListItem<CompanyStartup> data) {
                            c.companyCTRL.text = data.item?.brandName ?? "";
                          },
                          validator: (p0) {
                            if (p0 == null || p0.isEmpty) {
                              return 'Please enter a company/Private Equity name';
                            }
                            return null;
                          },
                        ),
                        TitleTextField(
                          controller: c.qtyCTRL,
                          name: "Enter Shares quantity",
                          isRequired: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Shares Quantity is required";
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null) {
                              return "Quantity must be a valid number";
                            }
                            if (quantity <= 0) {
                              return "Quantity must be greater than 0";
                            }
                            return null;
                          },
                        ),
                        TitleTextField(
                          controller: c.sharePriceCTRL,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          name: "Enter Share Price",
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Share Price";
                            }
                            final quantity = double.tryParse(value);
                            if (quantity == null) {
                              return "Price must be a valid number";
                            }
                            if (quantity <= 0) {
                              return "Price must be greater than 0";
                            }
                            return null;
                          },
                        ),
                        TitleTextField(
                          controller: c.purchaseDateCTRL,
                          textInputAction: TextInputAction.done,
                          name: "Date Of Investment",
                          isRequired: false,
                          readOnly: true,
                          onTap: () async {
                            var res = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: DateTime.now(),
                              lastDate: DateTime.now(),
                            );
                            if (res != null) {
                              c.purchaseDateCTRL.text = res.showDate;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        Obx(() {
                          return CustomElevatedButton(
                            isLoading: c.isUploading.value,
                            text: 'Upload',
                            onPressed: () async {
                              if (c.desktopKey.currentState?.validate() ??
                                  false) {
                                /// search startup/company from list
                                var data = c.list.firstWhereOrNull((e) =>
                                    e.brandName.trim().toLowerCase() ==
                                    c.companyCTRL.text
                                        .trim()
                                        .toLowerCase());
                                logger
                                    .d('Company Name :${data?.brandName}');
                                if (data != null) c.selectedCompany(data);

                                /// search investor from investor list
                                var investor = c.investorList
                                    .firstWhereOrNull((e) =>
                                        e.name.trim().toLowerCase() ==
                                        c.investorCTRL.text
                                            .trim()
                                            .toLowerCase());
                                logger
                                    .d('Investor Name :${investor?.name}');
                                if (investor != null) {
                                  c.selectedInvestor(investor);
                                }
                                await c.addData();
                              }
                            },
                          );
                        })
                      ],
                    ),
                  ),
                ),
              );
            })),
/*
            Expanded(
              child: CustomCardWidget(
                radius: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(40, 0, 40, 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: HeadingText("No"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Starup"),
                            ),
                            Expanded(
                              flex: 2,
                              child: HeadingText("Updated At"),
                            ),
                            Expanded(
                                child: Center(child: HeadingText("Action"))),
                          ],
                        ),
                      ),
                      Divider(
                        color: context.theme.disabledColor.withValues(alpha: 0.2),
                        thickness: 0.7,
                        height: 1,
                      ),
                      Expanded(
                        child: Obx(() {
                          if (c.isLoading.isFalse) {
                            if (c.list.isNotEmpty) {
                              return ListView.builder(
                                itemCount: c.list.length,
                                physics: const BouncingScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                itemBuilder: (context, index) {
                                  var model = c.list[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${index + 1}",
                                            style: const TextStyle(),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              LogoImage(
                                                url: model.startupLogo,
                                                height: 45,
                                                width: 45,
                                                radius: 2,
                                              ),
                                              const SizedBox(width: 20),
                                              Text(
                                                model.startupName,
                                                style: TextStyle(
                                                    color: context
                                                        .theme.disabledColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            model.uat.dateWithSortMonthYear,
                                            style: const TextStyle(),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: DownloadButton(
                                              onTap: () async {
                                                await DownloadFile
                                                    .downloadFromUrl(
                                                        url: model.docPath);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
              ),
            ),
*/
          ],
        ),
      ),
    );
  }
}
