import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';

class PartnerInvestorsPage extends StatefulWidget {
  const PartnerInvestorsPage({super.key});
  @override
  State<PartnerInvestorsPage> createState() => _InvestorsState();
}

class _InvestorsState extends State<PartnerInvestorsPage> {
  List<InvestorModel> investors = [];
  String isKyc = 'All', isActive = 'All', isAif = 'All', query = '', error = '';
  bool loading = true;
  int requestId = 0;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final request = ++requestId;
    setState(() {
      loading = true;
      error = '';
    });
    final result = await WInvestorsApi.investorsList(
      isKyc: isKyc,
      isActive: isActive,
      isAif: isAif,
    );
    if (!mounted || request != requestId) return;
    setState(() {
      loading = false;
      investors = result.r ?? [];
      if (!result.isSuccess) error = result.m;
    });
  }

  Widget filter(String label, String value, void Function(String) update) =>
      SizedBox(
        width: 175,
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          items: ['All', 'Yes', 'No']
              .map(
                (value) => DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              update(value);
              load();
            }
          },
        ),
      );
  @override
  Widget build(BuildContext context) => PartnerShell(
    title: 'Investors & CML',
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            filter('KYC', isKyc, (value) => isKyc = value),
            filter('Active', isActive, (value) => isActive = value),
            filter('AIF', isAif, (value) => isAif = value),
            FilledButton.icon(
              onPressed: () async {
                await Get.toNamed('/investors/create');
                if (mounted) load();
              },
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add client'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search name, email or mobile',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) =>
              setState(() => query = value.toLowerCase().trim()),
        ),
        const SizedBox(height: 20),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (error.isNotEmpty)
          Column(
            children: [
              Text(error),
              TextButton(onPressed: load, child: const Text('Retry')),
            ],
          )
        else if (investors.isEmpty)
          const Text('No investors match these filters.')
        else
          ...investors
              .where(
                (item) => '${item.name} ${item.email} ${item.mobileNumber}'
                    .toLowerCase()
                    .contains(query),
              )
              .map(
                (item) => Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      CmlApi.isSelf(item)
                          ? Icons.account_circle
                          : Icons.person_outline,
                    ),
                    title: Text(
                      '${item.name}${CmlApi.isSelf(item) ? ' · My account' : ''}',
                    ),
                    subtitle: Text(
                      '${item.mobileNumber} · ${item.preipoKycStatus == 1 ? 'Pre-IPO KYC complete' : 'Pre-IPO KYC pending'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Get.toNamed('/investors/${item.id}/cml');
                      if (mounted) load();
                    },
                  ),
                ),
              ),
      ],
    ),
  );
}

class CreateInvestorPage extends StatefulWidget {
  const CreateInvestorPage({super.key});
  @override
  State<CreateInvestorPage> createState() => _CreateInvestorState();
}

class _CreateInvestorState extends State<CreateInvestorPage> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController(),
      mobile = TextEditingController(),
      email = TextEditingController();
  String type = 'Individual', gender = '', message = '';
  bool saving = false;
  Future<void> save() async {
    if (saving || !key.currentState!.validate()) return;
    setState(() {
      saving = true;
      message = '';
    });
    final result = await WInvestorsApi.addInvestor(
      id: 0,
      investorType: type,
      name: name.text.trim(),
      mobileNumber: mobile.text.trim(),
      email: email.text.trim(),
      gender: gender,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      Get.offNamed('/investors');
      return;
    }
    setState(() {
      saving = false;
      message = result.m;
    });
  }

  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PartnerShell(
    title: 'Add client',
    child: Form(
      key: key,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Investor type'),
            items:
                [
                      'Individual',
                      'Hindu Undivided Family',
                      'Private Limited',
                      'Public Limited',
                      'Partnership',
                      'Proprietorship',
                      'Limited Liability Partnership',
                    ]
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
            onChanged: saving
                ? null
                : (value) => setState(() => type = value ?? type),
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !saving,
            controller: name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !saving,
            controller: mobile,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile number'),
            validator: (value) =>
                value == null || !RegExp(r'^\d{10}$').hasMatch(value.trim())
                ? 'Enter a 10-digit mobile number'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !saving,
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email (optional)'),
            validator: (value) =>
                value != null &&
                    value.isNotEmpty &&
                    !RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())
                ? 'Enter a valid email'
                : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: gender,
            decoration: const InputDecoration(labelText: 'Gender (optional)'),
            items: ['', 'Male', 'Female', 'Other']
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.isEmpty ? 'Not specified' : value),
                  ),
                )
                .toList(),
            onChanged: saving
                ? null
                : (value) => setState(() => gender = value ?? ''),
          ),
          const SizedBox(height: 16),
          if (message.isNotEmpty) Text(message),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Creating…' : 'Create client'),
            ),
          ),
        ],
      ),
    ),
  );
}
