import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'package:private_deals/src/features/investors/presentation/legacy/add_investor/add_investor_page_ctrl.dart';

class DesktopAddInvestorView extends StatelessWidget {
  final AddInvestorPageCtrl c = Get.find<AddInvestorPageCtrl>();

  DesktopAddInvestorView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Investor"),
          shape: const RoundedRectangleBorder(),
        ),
        body: Form(
          key: c.desktopFormKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 53, vertical: 30),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: CustomCardWidget(
                margin: EdgeInsets.zero,
                radius: 12,
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Investors Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: TitleTextField(
                            name: "Mobile Number",
                            hintText: 'Enter mobile number',
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
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: Obx(() {
                            return Visibility(
                              visible: c.investor().id.isEmpty,
                              child: TitleTextField(
                                isRequired: true,
                                controller: c.passwordCTRL,
                                obscureText: c.isObscure.value,
                                name: "Enter 4 Digit PIN",
                                maxLength: 4,
                                maxLines: 1,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp('[0-9+]'),
                                  ),
                                ],
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: TitleTextField(
                            isRequired: true,
                            controller: c.nameCTRL,
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
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: Obx(() {
                            return CustomLabelDropDown<String>(
                              label: "Investor Type",
                              hintText: 'Select investor type',
                              isRequired: true,
                              value: c.investorType.value,
                              items: [
                                DropdownMenuItem(
                                  value: app
                                      .config
                                      .enumValues
                                      .investorType
                                      .individual,
                                  child: Text(
                                    app
                                        .config
                                        .enumValues
                                        .investorType
                                        .individual,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app
                                      .config
                                      .enumValues
                                      .investorType
                                      .hinduundividedfamily,
                                  child: Text(
                                    app
                                        .config
                                        .enumValues
                                        .investorType
                                        .hinduundividedfamily,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app
                                      .config
                                      .enumValues
                                      .investorType
                                      .privatelimited,
                                  child: Text(
                                    app
                                        .config
                                        .enumValues
                                        .investorType
                                        .privatelimited,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app
                                      .config
                                      .enumValues
                                      .investorType
                                      .publiclimited,
                                  child: Text(
                                    app
                                        .config
                                        .enumValues
                                        .investorType
                                        .publiclimited,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app
                                      .config
                                      .enumValues
                                      .investorType
                                      .partnership,
                                  child: Text(
                                    app
                                        .config
                                        .enumValues
                                        .investorType
                                        .partnership,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: TitleTextField(
                            controller: c.emailCTRL,
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
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: Obx(() {
                            return CustomLabelDropDown<String>(
                              label: "Gender",
                              hintText: 'Select gender',
                              value: c.gender.value,
                              items: [
                                DropdownMenuItem(
                                  value: app.config.enumValues.gender.male,
                                  child: Text(
                                    app.config.enumValues.gender.male,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app.config.enumValues.gender.female,
                                  child: Text(
                                    app.config.enumValues.gender.female,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: app.config.enumValues.gender.other,
                                  child: Text(
                                    app.config.enumValues.gender.other,
                                  ),
                                ),
                              ],
                              onChanged: (v) => c.gender(v),
                              // validator: (value) {
                              // if (value == null) {
                              //   return "Please select your gender";
                              // }
                              // return null;
                              // },
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TitleTextField(
                      controller: c.addressCTRL,
                      minLines: 2,
                      maxLines: 3,
                      name: 'Registered Address',
                      hintText: 'Enter registered address',
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return null;
                      //   }
                      //   if (value.length < 14) {
                      //     return 'Registered address must be at least 15 characters long';
                      //   }
                      //   return null;
                      // },
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return CustomLabelDropDown<MasterTypeModel>(
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
                            );
                          }),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: Obx(() {
                            return CustomLabelDropDown<MasterTypeModel>(
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
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            return CustomLabelDropDown<MasterTypeModel>(
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
                            );
                          }),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: TitleTextField(
                            controller: c.pinCodeCTRL,
                            maxLength: 6,
                            name: 'PinCode',
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp('[0-9``]'),
                              ),
                            ],
                            hintText: 'Enter pin-code',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return null;
                              }
                              if (int.tryParse(value) == null) {
                                return 'Enter a valid pin-code';
                              }
                              if (value.length > 6) {
                                return 'Pin-code not be more then 6 digit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 60),
                    // Text(
                    //   "KYC Documents (optional)",
                    //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    // ),
                    // SizedBox(height: 40),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: PhoneProfileTextField(
                    //         name: "Aadhar card front image",
                    //         controller: c.aadharCTRL,
                    //         readOnly: true,
                    //         onTap: () async {
                    //           var res = await FilePickers().pickSingleImage();
                    //           if (res != null) {
                    //             c.aadhar(res);
                    //             c.aadharCTRL.text = res.name;
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //     SizedBox(width: 80),
                    //     Expanded(
                    //       child: PhoneProfileTextField(
                    //         controller: c.aadharBackCTRL,
                    //         name: 'Aadhar card back image',
                    //         readOnly: true,
                    //         onTap: () async {
                    //           var res = await FilePickers().pickSingleImage();
                    //           if (res != null) {
                    //             c.aadharBack(res);
                    //             c.aadharBackCTRL.text = res.name;
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 30),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: PhoneProfileTextField(
                    //         name: "Pan card image",
                    //         controller: c.panCardCTRL,
                    //         readOnly: true,
                    //         onTap: () async {
                    //           var res = await FilePickers().pickSingleImage();
                    //           if (res != null) {
                    //             c.panCard(res);
                    //             c.panCardCTRL.text = res.name;
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //     SizedBox(width: 80),
                    //     Expanded(child: SizedBox()),
                    //   ],
                    // ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return CustomElevatedButton(
                            isLoading: c.isLoading.value,
                            width: 180,
                            onPressed: () {
                              if (c.desktopFormKey.currentState?.validate() ??
                                  false) {
                                c.onPress();
                              }
                            },
                            text: 'Register',
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
