import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:private_deals/src/features/investors/data/w_investors_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';

class CmlPage extends StatefulWidget {
  const CmlPage({super.key});
  @override
  State<CmlPage> createState() => _CmlState();
}

class _CmlState extends State<CmlPage> {
  InvestorModel? investor;
  CmlDocument? document;
  bool loading = true, working = false;
  String message = '', loadError = '';
  final form = GlobalKey<FormState>();
  static const labels = {
    'dp_id': 'DP ID',
    'client_id': 'Client ID',
    'pan_no': 'PAN',
    'name': 'Name on CML',
    'account_number': 'Bank account number',
    'ifsc_code': 'IFSC',
    'bank_name': 'Bank name',
    'dob': 'Date of birth (dd-mm-yyyy)',
  };
  final fields = {
    for (final field in [...CmlApi.requiredFields, ...CmlApi.optionalFields])
      field: TextEditingController(),
  };
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      loadError = '';
    });
    final id = int.tryParse(Get.parameters['id'] ?? '');
    // Reload authorized list on a direct link. Never trust a query parameter for is_self.
    final result = await WInvestorsApi.investorsList(
      isKyc: 'All',
      isActive: 'All',
      isAif: 'All',
    );
    if (!mounted) return;
    final found = result.r?.firstWhereOrNull((item) => item.id == id);
    setState(() {
      loading = false;
      investor = found;
      loadError = !result.isSuccess
          ? result.m
          : found == null
          ? 'Investor not found in your accessible clients.'
          : '';
      if (found != null) fields['name']!.text = found.name;
    });
  }

  Future<void> read() async {
    if (working || investor == null) return;
    setState(() {
      working = true;
      message = '';
    });
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty || !mounted) return;
      final file = picked.files.single;
      if (file.bytes == null)
        throw const FormatException('Unable to read this PDF.');
      final next = CmlDocument(file.name, file.bytes!);
      next.validate();
      document = next;
      final result = await CmlApi.read(investor!.id, next);
      if (!mounted) return;
      setState(() {
        message = result.m;
        if (result.isSuccess && result.r != null) {
          for (final entry in fields.entries) {
            final value = result.r![entry.key];
            if (value != null) entry.value.text = value.toString();
          }
          message =
              'Review the extracted details. Reading a CML does not complete KYC.';
        }
      });
    } on FormatException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (_) {
      if (mounted)
        setState(() => message = 'Unable to read this file. Please retry.');
    } finally {
      if (mounted) setState(() => working = false);
    }
  }

  Future<void> save() async {
    if (working ||
        investor == null ||
        CmlApi.isSelf(investor!) ||
        !form.currentState!.validate())
      return;
    setState(() {
      working = true;
      message = '';
    });
    final result = await CmlApi.save(investor!, {
      for (final entry in fields.entries) entry.key: entry.value.text,
    }, document);
    if (!mounted) return;
    setState(() {
      working = false;
      message = result.m;
      if (result.isSuccess) investor!.preipoKycStatus = 1;
    });
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PartnerShell(
    title: 'CML verification',
    child: loading
        ? const Center(child: CircularProgressIndicator())
        : investor == null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loadError),
                TextButton(onPressed: load, child: const Text('Retry')),
              ],
            ),
          )
        : Form(
            key: form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  investor!.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  investor!.preipoKycStatus == 1
                      ? 'Pre-IPO KYC complete'
                      : 'Pre-IPO KYC pending',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload a CML PDF up to 10 MB, review the details, then save to complete client KYC. Saving also updates the investor’s name.',
                ),
                if (CmlApi.isSelf(investor!))
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'You can read your own CML. Saving your own KYC is not available yet.',
                    ),
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: working ? null : read,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose PDF and read'),
                  ),
                ),
                if (document != null) Text(document!.name),
                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(message),
                  ),
                ...fields.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      controller: entry.value,
                      enabled: !working && !CmlApi.isSelf(investor!),
                      decoration: InputDecoration(
                        labelText:
                            '${labels[entry.key]}${CmlApi.requiredFields.contains(entry.key) ? ' *' : ' (optional)'}',
                      ),
                      validator: (value) {
                        if (CmlApi.requiredFields.contains(entry.key) &&
                            (value ?? '').trim().isEmpty)
                          return 'Required';
                        if (entry.key == 'dob' &&
                            value != null &&
                            value.trim().isNotEmpty) {
                          final match = RegExp(
                            r'^(\d{1,2})-(\d{1,2})-(\d{4})$',
                          ).firstMatch(value.trim());
                          if (match == null) return 'Use dd-mm-yyyy';
                          final day = int.parse(match[1]!),
                              month = int.parse(match[2]!),
                              year = int.parse(match[3]!);
                          final date = DateTime(year, month, day);
                          if (date.day != day ||
                              date.month != month ||
                              date.year != year ||
                              date.isAfter(DateTime.now()))
                            return 'Enter a valid date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: working || CmlApi.isSelf(investor!)
                        ? null
                        : save,
                    child: Text(working ? 'Please wait…' : 'Save client KYC'),
                  ),
                ),
              ],
            ),
          ),
  );
}
