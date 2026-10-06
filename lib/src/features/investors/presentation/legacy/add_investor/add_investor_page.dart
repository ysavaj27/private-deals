import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

/// Allowed values for `investor_type` on POST v2/business/investor.
const List<String> kInvestorTypes = [
  'Individual',
  'Hindu Undivided Family',
  'Private Limited',
  'Public Limited',
  'Partnership',
  'Proprietorship',
  'Limited Liability Partnership',
];

/// Allowed values for optional `gender` on create.
const List<String> kInvestorGenders = ['Male', 'Female', 'Other'];

class AddInvestorPage extends StatefulWidget {
  const AddInvestorPage({super.key});

  @override
  State<AddInvestorPage> createState() => _AddInvestorPageState();
}

class _AddInvestorPageState extends State<AddInvestorPage> {
  final _desktopFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();
  final _nameCTRL = TextEditingController();
  final _emailCTRL = TextEditingController();
  final _phoneNoCTRL = TextEditingController();

  late final InvestorModel _investor;
  late String _investorType;
  String? _gender;
  bool _saving = false;

  bool get _isEdit => _investor.id != 0;

  @override
  void initState() {
    super.initState();
    final user = Get.arguments;
    if (user is InvestorModel) {
      _investor = user;
      _investorType = user.investorType.isNotEmpty
          ? user.investorType
          : kInvestorTypes.first;
      _gender = user.gender.isNotEmpty ? user.gender : null;
      _nameCTRL.text = user.name;
      _phoneNoCTRL.text =
          user.mobileNumber == 0 ? '' : user.mobileNumber.toString();
      _emailCTRL.text = user.email;
    } else {
      _investor = InvestorModel.fromJson({});
      _investorType = kInvestorTypes.first;
      _gender = null;
    }
  }

  @override
  void dispose() {
    _nameCTRL.dispose();
    _emailCTRL.dispose();
    _phoneNoCTRL.dispose();
    super.dispose();
  }

  Future<void> _submit(GlobalKey<FormState> formKey) async {
    if (_saving || !(formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final res = await WInvestorsApi.addInvestor(
      id: _investor.id,
      investorType: _investorType,
      name: _nameCTRL.text.trim(),
      mobileNumber: _phoneNoCTRL.text.trim(),
      email: _emailCTRL.text.trim(),
      gender: _gender ?? '',
    );
    if (!mounted) return;
    if (res.isSuccess) {
      Get.back(result: true);
      toast(res.m, MessageEnum.success);
      return;
    }
    setState(() => _saving = false);
    toast(res.m, MessageEnum.error);
  }

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return _PhoneAddInvestorView(
        formKey: _phoneFormKey,
        nameCTRL: _nameCTRL,
        emailCTRL: _emailCTRL,
        phoneNoCTRL: _phoneNoCTRL,
        investorType: _investorType,
        gender: _gender,
        isEdit: _isEdit,
        saving: _saving,
        onTypeChanged: (v) {
          if (v != null) setState(() => _investorType = v);
        },
        onGenderChanged: (v) => setState(() => _gender = v),
        onSubmit: () => _submit(_phoneFormKey),
      );
    }
    return _DesktopAddInvestorView(
      formKey: _desktopFormKey,
      nameCTRL: _nameCTRL,
      emailCTRL: _emailCTRL,
      phoneNoCTRL: _phoneNoCTRL,
      investorType: _investorType,
      gender: _gender,
      isEdit: _isEdit,
      saving: _saving,
      onTypeChanged: (v) {
        if (v != null) setState(() => _investorType = v);
      },
      onGenderChanged: (v) => setState(() => _gender = v),
      onSubmit: () => _submit(_desktopFormKey),
    );
  }
}

class _PhoneAddInvestorView extends StatelessWidget {
  const _PhoneAddInvestorView({
    required this.formKey,
    required this.nameCTRL,
    required this.emailCTRL,
    required this.phoneNoCTRL,
    required this.investorType,
    required this.gender,
    required this.isEdit,
    required this.saving,
    required this.onTypeChanged,
    required this.onGenderChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCTRL;
  final TextEditingController emailCTRL;
  final TextEditingController phoneNoCTRL;
  final String investorType;
  final String? gender;
  final bool isEdit;
  final bool saving;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBackPressed),
        title: Text(isEdit ? 'Edit Investor' : 'Add Investor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Investor Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              CustomLabelDropDown<String>(
                label: 'Investor Type',
                hintText: 'Select investor type',
                isRequired: true,
                value: investorType,
                items: kInvestorTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: saving ? null : onTypeChanged,
                validator: (value) {
                  if (value == null) return 'Please select investor type';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TitleTextField(
                isRequired: true,
                controller: nameCTRL,
                enabled: !saving,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                name: 'Investors Name',
                hintText: 'Enter investors name',
                maxLength: 255,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter investor name';
                  }
                  if (value.trim().length > 255) {
                    return 'Name must be at most 255 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TitleTextField(
                name: 'Mobile Number',
                hintText: 'Enter mobile number',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                isRequired: true,
                maxLength: 10,
                enabled: !saving,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: phoneNoCTRL,
                validator: (p0) {
                  if (p0 == null || p0.trim().isEmpty) {
                    return 'Enter mobile number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(p0.trim())) {
                    return 'Enter a 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TitleTextField(
                controller: emailCTRL,
                isRequired: false,
                enabled: !saving,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                name: 'Email (optional)',
                hintText: 'Enter email',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  if (!GetUtils.isEmail(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              CustomLabelDropDown<String>(
                label: 'Gender (optional)',
                hintText: 'Select gender',
                value: gender,
                isRequired: false,
                items: kInvestorGenders
                    .map(
                      (g) => DropdownMenuItem(value: g, child: Text(g)),
                    )
                    .toList(),
                onChanged: saving ? null : onGenderChanged,
              ),
              const SizedBox(height: 68),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomElevatedButton(
          isLoading: saving,
          onPressed: saving ? null : onSubmit,
          text: isEdit ? 'Update' : 'Register',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _DesktopAddInvestorView extends StatelessWidget {
  const _DesktopAddInvestorView({
    required this.formKey,
    required this.nameCTRL,
    required this.emailCTRL,
    required this.phoneNoCTRL,
    required this.investorType,
    required this.gender,
    required this.isEdit,
    required this.saving,
    required this.onTypeChanged,
    required this.onGenderChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCTRL;
  final TextEditingController emailCTRL;
  final TextEditingController phoneNoCTRL;
  final String investorType;
  final String? gender;
  final bool isEdit;
  final bool saving;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: onBackPressed),
          title: Text(isEdit ? 'Edit Investor' : 'Add Investor'),
          shape: const RoundedRectangleBorder(),
        ),
        body: Form(
          key: formKey,
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
                      'Investors Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: CustomLabelDropDown<String>(
                            label: 'Investor Type',
                            hintText: 'Select investor type',
                            isRequired: true,
                            value: investorType,
                            items: kInvestorTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: saving ? null : onTypeChanged,
                            validator: (value) {
                              if (value == null) {
                                return 'Please select investor type';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: TitleTextField(
                            isRequired: true,
                            controller: nameCTRL,
                            enabled: !saving,
                            name: 'Investors Name',
                            hintText: 'Enter investors name',
                            maxLength: 255,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter investor name';
                              }
                              if (value.trim().length > 255) {
                                return 'Name must be at most 255 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: TitleTextField(
                            name: 'Mobile Number',
                            hintText: 'Enter mobile number',
                            isRequired: true,
                            maxLength: 10,
                            enabled: !saving,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: phoneNoCTRL,
                            validator: (p0) {
                              if (p0 == null || p0.trim().isEmpty) {
                                return 'Enter mobile number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(p0.trim())) {
                                return 'Enter a 10-digit mobile number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 80),
                        Expanded(
                          child: TitleTextField(
                            controller: emailCTRL,
                            enabled: !saving,
                            name: 'Email (optional)',
                            hintText: 'Enter email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              if (!GetUtils.isEmail(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: CustomLabelDropDown<String>(
                            label: 'Gender (optional)',
                            hintText: 'Select gender',
                            value: gender,
                            items: kInvestorGenders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                            onChanged: saving ? null : onGenderChanged,
                          ),
                        ),
                        const SizedBox(width: 80),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomElevatedButton(
                          isLoading: saving,
                          width: 180,
                          onPressed: saving ? null : onSubmit,
                          text: isEdit ? 'Update' : 'Register',
                        ),
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
