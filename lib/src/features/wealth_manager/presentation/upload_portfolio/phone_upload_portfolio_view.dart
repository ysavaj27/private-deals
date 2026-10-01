import 'package:private_deals/src/shared/app_exports.dart';
import 'package:searchfield/searchfield.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/upload_portfolio/upload_portfolio_ctrl.dart';

class PhoneUploadPortfolioView extends StatelessWidget {
  final UploadPortfolioCtrl c = Get.find<UploadPortfolioCtrl>();

  PhoneUploadPortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              TabBar(
                splashBorderRadius: BorderRadius.circular(50),
                onTap: (v) => c.changeTab(DashboardTypeEnum.values[v]),
                tabs: [
                  const Tab(text: 'Startup'),
                  const Tab(text: 'Company'),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Expanded(
                      child: TabBarView(
                        children: [
                          MainView(formKey: c.phoneStartupKey),
                          MainView(formKey: c.phoneCompanyKey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainView extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final UploadPortfolioCtrl c = Get.find<UploadPortfolioCtrl>();

  MainView({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.isFalse) {
        return SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              spacing: 15,
              children: [
                SearchableTextField<InvestorModel>(
                  controller: c.investorCTRL,
                  hint: 'Search Investors...',
                  title: 'Select Investor',
                  isRequired: true,
                  suggestions: c.investorList
                      .map((e) =>
                          SearchFieldListItem<InvestorModel>(e.name, item: e))
                      .toList(),
                  onSuggestionTap: (SearchFieldListItem<InvestorModel> data) {
                    c.investorCTRL.text = data.item?.name ?? "";
                    c.selectedInvestor(data.item);
                  },
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Please select investor';
                    }
                    if (!c.investorList.any((company) =>
                        company.name.toLowerCase() == p0.toLowerCase())) {
                      return 'Invalid Investor selected';
                    }
                    return null;
                  },
                ),
                SearchableTextField<CompanyStartup>(
                  controller: c.companyCTRL,
                  hint: 'Search ${c.isStartUp ? "Startup" : "Company"}...',
                  title: 'Select ${c.isStartUp ? "Startup" : "Company"}',
                  isRequired: true,
                  suggestions: c.list
                      .map((e) => SearchFieldListItem<CompanyStartup>(
                          e.brandName,
                          item: e))
                      .toList(),
                  onSuggestionTap: (SearchFieldListItem<CompanyStartup> data) {
                    c.companyCTRL.text = data.item?.brandName ?? "";
                  },
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Please enter a company/startup name';
                    }
                    return null;
                  },
                ),
                TitleTextField(
                  controller: c.qtyCTRL,
                  name: "Enter Shares quantity",
                  isRequired: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      if (formKey.currentState?.validate() ?? false) {
                        /// search startup/company from list
                        var data = c.list.firstWhereOrNull((e) =>
                            e.brandName.trim().toLowerCase() ==
                            c.companyCTRL.text.trim().toLowerCase());
                        logger.d('Company Name :${data?.brandName}');
                        if (data != null) c.selectedCompany(data);

                        /// search investor from investor list
                        var investor = c.investorList.firstWhereOrNull((e) =>
                            e.name.trim().toLowerCase() ==
                            c.investorCTRL.text.trim().toLowerCase());
                        logger.d('Investor Name :${investor?.name}');
                        if (investor != null) c.selectedInvestor(investor);
                        await c.addData();
                      }
                    },
                  );
                })
              ],
            ),
          ),
        );
      } else {
        return Loader();
      }
    });
  }
}
