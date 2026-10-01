import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page_ctrl.dart';

class PhoneAddInvestorView extends StatelessWidget {
  final AddInvestorPageCtrl c = Get.find<AddInvestorPageCtrl>();

  PhoneAddInvestorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          c.investor().id.isNotEmpty ? "Edit Investor" : "Add Investor",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: c.phoneFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Investor Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TitleTextField(
                name: "Mobile Number",
                hintText: 'Enter mobile number',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                isRequired: true,
                maxLength: 10,
                controller: c.phoneNoCTRL,
                validator: (p0) {
                  if (p0 == null || p0.isEmpty) {
                    return 'Enter mobile number';
                  }
                  if (!GetUtils.isPhoneNumber(p0)) {
                    return 'Enter valid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Obx(() {
                return Visibility(
                  visible: c.investor().id.isEmpty,
                  child: TitleTextField(
                    isRequired: true,
                    controller: c.passwordCTRL,
                    obscureText: c.isObscure.value,
                    name: "Enter 4 Digit PIN",
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9+]')),
                    ],
                    textInputAction: TextInputAction.next,
                    maxLines: 1,
                    // prefixIcon: const Icon(Icons.vpn_key, size: 20),
                    suffixIcon: IconButton(
                      iconSize: 20,
                      splashRadius: 20,
                      onPressed: () => c.isObscure.toggle(),
                      icon: Icon(
                        c.isObscure.isTrue
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return 'Please enter 4 digit PIN';
                      } else if (p0.trim().length != 4) {
                        return 'PIN must be 4 digit in length';
                      }
                      if (!GetUtils.isNumericOnly(p0)) {
                        return 'Please enter valid PIN';
                      }
                      return null;
                    },
                  ),
                );
              }),
              Visibility(
                visible: c.investor().id.isEmpty,
                child: const SizedBox(height: 15),
              ),
              TitleTextField(
                isRequired: true,
                controller: c.nameCTRL,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                name: 'Investors Name',
                hintText: 'Enter investors name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter investor name';
                  }
                  if (value.length < 3) {
                    return 'Investors name must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Obx(() {
                return CustomLabelDropDown<String>(
                  label: "Investor Type",
                  hintText: 'Select investor type',
                  isRequired: true,
                  value: c.investorType.value,
                  items: [
                    DropdownMenuItem(
                      value: app.config.enumValues.investorType.individual,
                      child: Text(
                        app.config.enumValues.investorType.individual,
                      ),
                    ),
                    DropdownMenuItem(
                      value: app
                          .config
                          .enumValues
                          .investorType
                          .hinduundividedfamily,
                      child: Text(
                        app.config.enumValues.investorType.hinduundividedfamily,
                      ),
                    ),
                    DropdownMenuItem(
                      value: app.config.enumValues.investorType.privatelimited,
                      child: Text(
                        app.config.enumValues.investorType.privatelimited,
                      ),
                    ),
                    DropdownMenuItem(
                      value: app.config.enumValues.investorType.publiclimited,
                      child: Text(
                        app.config.enumValues.investorType.publiclimited,
                      ),
                    ),
                    DropdownMenuItem(
                      value: app.config.enumValues.investorType.partnership,
                      child: Text(
                        app.config.enumValues.investorType.partnership,
                      ),
                    ),
                    DropdownMenuItem(
                      value: app
                          .config
                          .enumValues
                          .investorType
                          .limitedliabilitypartnership,
                      child: Text(
                        app
                            .config
                            .enumValues
                            .investorType
                            .limitedliabilitypartnership,
                      ),
                    ),
                  ],
                  onChanged: (v) => c.investorType(v),
                  validator: (value) {
                    if (value == null) {
                      return "Please select investor type";
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 15),
              TitleTextField(
                controller: c.emailCTRL,
                isRequired: false,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                name: 'Email',
                hintText: 'Enter Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Obx(() {
                return CustomLabelDropDown<String>(
                  label: "Gender",
                  hintText: 'Select gender',
                  value: c.gender.value,
                  isRequired: false,
                  items: [
                    DropdownMenuItem(
                      value: app.config.enumValues.gender.male,
                      child: Text(app.config.enumValues.gender.male),
                    ),
                    DropdownMenuItem(
                      value: app.config.enumValues.gender.female,
                      child: Text(app.config.enumValues.gender.female),
                    ),
                    DropdownMenuItem(
                      value: app.config.enumValues.gender.other,
                      child: Text(app.config.enumValues.gender.other),
                    ),
                  ],
                  onChanged: (v) => c.gender(v),
                  // validator: (value) {
                  //   if (value == null) {
                  //     return "Please select your gender";
                  //   }
                  //   return null;
                  // },
                );
              }),
              const SizedBox(height: 15),
              TitleTextField(
                controller: c.addressCTRL,
                isRequired: false,
                minLines: 2,
                maxLines: 3,
                name: 'Registered Address',
                hintText: 'Enter registered address',
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter registered address';
                //   }
                //   if (value.length < 14) {
                //     return 'Registered address must be at least 15 characters long';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 15),
              Obx(() {
                return CustomLabelDropDown<MasterTypeModel>(
                  isRequired: false,
                  label: "Country",
                  hintText: 'Select country',
                  value: c.country.value,
                  items: c.countryList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.capitalizeFirst ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    c.country(v);
                    c.cityList.clear();
                    c.state.value = null;
                    c.city.value = null;
                    c.getState(v.id);
                  },
                  // validator: (value) {
                  //   if (value == null) {
                  //     return "Please select country first";
                  //   }
                  //   return null;
                  // },
                );
              }),
              const SizedBox(height: 15),
              Obx(() {
                return CustomLabelDropDown<MasterTypeModel>(
                  isRequired: false,
                  label: "State",
                  hintText: 'Select state',
                  value: c.state.value,
                  items: c.stateList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.capitalizeFirst ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    c.state(v);
                    c.getCity(v.id);
                  },
                  // validator: (value) {
                  //   if (value == null) {
                  //     return "Please select state first";
                  //   }
                  //   return null;
                  // },
                );
              }),
              const SizedBox(height: 15),
              Obx(() {
                return CustomLabelDropDown<MasterTypeModel>(
                  isRequired: false,
                  label: "City",
                  hintText: 'Select city',
                  value: c.city.value,
                  items: c.cityList
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name.capitalizeFirst ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => c.city(v),
                  // validator: (value) {
                  //   if (value == null) {
                  //     return "Please select city first";
                  //   }
                  //   return null;
                  // },
                );
              }),
              const SizedBox(height: 15),
              TitleTextField(
                controller: c.pinCodeCTRL,
                isRequired: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                name: 'PinCode',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9``]')),
                ],
                hintText: 'Enter pin-code',
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter pin-code';
                //   }
                //   if (int.tryParse(value) == null) {
                //     return 'Enter a valid pin-code';
                //   }
                //   if (value.length > 6) {
                //     return 'Pin-code not be more then 6 digit';
                //   }
                //   return null;
                // },
              ),
              const SizedBox(height: 68),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomElevatedButton(
            isLoading: c.isLoading.value,
            // width: 180,
            onPressed: () {
              if (c.phoneFormKey.currentState?.validate() ?? false) {
                c.onPress();
              }
            },
            text: c.investor().id.isNotEmpty ? "Update" : 'Register',
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
