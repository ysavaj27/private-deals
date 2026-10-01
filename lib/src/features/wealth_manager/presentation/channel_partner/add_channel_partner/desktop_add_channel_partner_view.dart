import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/channel_partner/add_channel_partner/add_channel_partner_dialog_ctrl.dart';

class DesktopAddChannelPartnerView extends StatelessWidget {
  final AddChannelPartnerDialogCtrl c = Get.find<AddChannelPartnerDialogCtrl>();

  DesktopAddChannelPartnerView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      width: 800,
      color: context.theme.scaffoldBackgroundColor,
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 20),
      child: Form(
        key: c.desktopFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TitleText("Channel Partner"),
                IconButton(
                  onPressed: Get.back,
                  splashRadius: 25,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: context.theme.disabledColor.withValues(alpha: 0.2)),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TitleTextField(
                    isRequired: true,
                    controller: c.nameCTRL,
                    name: 'Name',
                    hintText: 'Enter name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TitleTextField(
                    controller: c.mobileCTRL,
                    isRequired: true,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9``]')),
                    ],
                    name: 'Mobile',
                    hintText: 'Enter mobile no',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      if (int.tryParse(value) == null || value.length != 10) {
                        return 'Enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TitleTextField(
                    controller: c.emailCTRL,
                    isRequired: true,
                    name: 'Email',
                    hintText: 'Enter Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TitleTextField(
                    controller: c.passwordCTRL,
                    isRequired: true,
                    name: 'Password',
                    hintText: 'Enter password',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 5) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    List<DropdownMenuItem<String>>? item = [];
                    item.add(
                      DropdownMenuItem(
                        value:
                            app.config.enumValues.partnerType.relationManager,
                        child: Text(
                            app.config.enumValues.partnerType.relationManager),
                      ),
                    );
                    item.addAllIf(
                        app.config.enumValues.partnerType.wealthmanager ==
                            app.wUser.type,
                        [
                          DropdownMenuItem(
                            value: app.config.enumValues.partnerType.retailer,
                            child: Text(
                                app.config.enumValues.partnerType.retailer),
                          ),
                          DropdownMenuItem(
                            value:
                                app.config.enumValues.partnerType.distributor,
                            child: Text(
                                app.config.enumValues.partnerType.distributor),
                          ),
                        ]);
                    item.addAllIf(
                        app.config.enumValues.partnerType.distributor ==
                            app.wUser.type,
                        [
                          DropdownMenuItem(
                            value: app.config.enumValues.partnerType.retailer,
                            child: Text(
                                app.config.enumValues.partnerType.retailer),
                          ),
                        ]);

                    return CustomLabelDropDown<String>(
                      label: "Partner Type",
                      hintText: 'Select partner type',
                      isRequired: true,
                      value: c.partnerType.value,
                      items: item,
                      onChanged: (v) => c.partnerType(v),
                      validator: (value) {
                        if (value == null) {
                          return "Please select partner type";
                        }
                        return null;
                      },
                    );
                  }),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Obx(() {
                    return CustomLabelDropDown<String>(
                      label: "Gender",
                      hintText: 'Select gender',
                      value: c.gender.value,
                      isRequired: true,
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
                      validator: (value) {
                        if (value == null) {
                          return "Please select your gender";
                        }
                        return null;
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return Visibility(
                      visible:
                          app.config.enumValues.partnerType.relationManager !=
                              c.partnerType.value,
                      child: TitleTextField(
                        controller: c.commissionCTRL,
                        isRequired: true,
                        name: 'Commission',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                        ],
                        hintText: 'Enter commission',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter commission';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a valid commission';
                          }
                          if (double.parse(value) >= 100) {
                            return 'Commission not be given more then 100%';
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 20),
                const Expanded(child: SizedBox()),
              ],
            ),
            Obx(() {
              return Visibility(
                visible: app.config.enumValues.partnerType.relationManager !=
                    c.partnerType.value,
                child: const SizedBox(height: 20),
              );
            }),
            Material(
              color: Colors.transparent,
              child: Obx(() {
                final tiles = <Widget>[
                  if (app.wUser.isPrimaryAccess)
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      fillColor: WidgetStateProperty.resolveWith((Set states) {
                        if (states.contains(WidgetState.selected)) {
                          return context.theme.primaryColor;
                        } else {
                          return context.theme.scaffoldBackgroundColor;
                        }
                      }),
                      side: BorderSide(
                          color: context.theme.iconTheme.color ?? Colors.white),
                      value: c.isPrimary.value,
                      onChanged: (v) => c.isPrimary(v),
                      title: const Text("Private Equity"),
                    ),
                  if (app.wUser.isSecondaryAccess)
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      fillColor: WidgetStateProperty.resolveWith((Set states) {
                        if (states.contains(WidgetState.selected)) {
                          return context.theme.primaryColor;
                        } else {
                          return context.theme.scaffoldBackgroundColor;
                        }
                      }),
                      side: BorderSide(
                          color: context.theme.iconTheme.color ?? Colors.white),
                      checkboxSemanticLabel: "Lp Secondary",
                      value: c.isSecondary.value,
                      onChanged: (v) => c.isSecondary(v),
                      title: const Text("Lp Secondary"),
                    ),
                  if (app.wUser.isPreIpoAccess)
                    CheckboxListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      fillColor: WidgetStateProperty.resolveWith((Set states) {
                        if (states.contains(WidgetState.selected)) {
                          return context.theme.primaryColor;
                        } else {
                          return context.theme.scaffoldBackgroundColor;
                        }
                      }),
                      side: BorderSide(
                          color: context.theme.iconTheme.color ?? Colors.white),
                      checkboxSemanticLabel: "Unlisted Shares",
                      value: c.isPreIpo.value,
                      onChanged: (v) => c.isPreIpo(v),
                      title: const Text("Unlisted Shares"),
                    ),
                ];

                if (tiles.isEmpty) return const SizedBox.shrink();

                return Row(
                  children: [for (final tile in tiles) Expanded(child: tile)],
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() {
                  return CustomElevatedButton(
                    isLoading: c.isLoading.value,
                    width: 130,
                    onPressed: () {
                      if (c.desktopFormKey.currentState?.validate() ?? false) {
                        c.onPress();
                      }
                    },
                    text: 'Save',
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
