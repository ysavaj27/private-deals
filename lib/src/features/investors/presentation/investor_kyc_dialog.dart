import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:private_deals/src/features/investors/data/cml_api.dart';
import 'package:private_deals/src/features/investors/data/investor_model.dart';

Future<bool?> showInvestorKycDialog(
  BuildContext context,
  InvestorModel investor,
) => showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => InvestorKycDialog(investor: investor),
);

class InvestorKycDialog extends StatefulWidget {
  const InvestorKycDialog({
    super.key,
    required this.investor,
    this.pickDocument,
  });

  final InvestorModel investor;
  final Future<CmlDocument?> Function()? pickDocument;

  @override
  State<InvestorKycDialog> createState() => _InvestorKycDialogState();
}

class _InvestorKycDialogState extends State<InvestorKycDialog> {
  final _form = GlobalKey<FormState>();
  final _fields = {
    for (final field in [...CmlApi.requiredFields, ...CmlApi.optionalFields])
      field: TextEditingController(),
  };
  CmlDocument? _document;
  bool _working = false;
  String _message = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fields['name']!.text = widget.investor.name;
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<CmlDocument?> _pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    if (file.size > 10 * 1024 * 1024) {
      throw const FormatException('CML must be 10 MB or smaller.');
    }
    return CmlDocument(file.name, await file.readAsBytes());
  }

  Future<void> _read() async {
    if (_working) return;
    setState(() {
      _working = true;
      _message = '';
      _hasError = false;
    });
    try {
      final document = await (widget.pickDocument ?? _pickDocument)();
      if (!mounted || document == null) return;
      document.validate();
      setState(() {
        _document = document;
        // A replacement PDF must never retain details from the previous PDF.
        for (final controller in _fields.values) {
          controller.clear();
        }
      });
      final result = await CmlApi.read(widget.investor.id, document);
      if (!mounted) return;
      setState(() {
        if (result.isSuccess && result.r != null) {
          final data = result.r!;
          for (final entry in _fields.entries) {
            final key = entry.key == 'name' ? 'account_holder_name' : entry.key;
            entry.value.text = data[key]?.toString() ?? '';
          }
          _message =
              'Review the details below and fill in any missing fields, then save to complete KYC.';
        } else {
          _hasError = true;
          _message = result.m.isNotEmpty
              ? result.m
              : 'Unable to read the PDF. Please retry or enter the details below.';
        }
      });
    } on FormatException catch (error) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _message = error.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _message = 'Unable to read this file. Please retry.';
        });
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _save() async {
    if (_working || !_form.currentState!.validate()) return;
    setState(() {
      _working = true;
      _message = '';
      _hasError = false;
    });
    final result = await CmlApi.save(widget.investor, {
      for (final entry in _fields.entries) entry.key: entry.value.text,
    }, _document);
    if (!mounted) return;
    if (result.isSuccess) {
      // Reload the investor list after closing to use the server's KYC status.
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _working = false;
      _hasError = true;
      _message = result.m.isNotEmpty
          ? result.m
          : 'Unable to save KYC. Please retry.';
    });
  }

  Widget _field(String key, String label) {
    final required = CmlApi.requiredFields.contains(key);
    return TextFormField(
      key: ValueKey('kyc_$key'),
      controller: _fields[key],
      enabled: !_working,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ' (optional)'}',
        hintText: key == 'dob' ? 'dd-mm-yyyy' : null,
        border: const OutlineInputBorder(),
      ),
      textCapitalization: ['dp_id', 'pan_no', 'ifsc_code'].contains(key)
          ? TextCapitalization.characters
          : TextCapitalization.none,
      validator: (value) {
        final text = (value ?? '').trim();
        if (required && text.isEmpty) return 'Enter $label';
        if (key == 'dob' && text.isNotEmpty) {
          final match = RegExp(
            r'^(\d{1,2})-(\d{1,2})-(\d{4})$',
          ).firstMatch(text);
          if (match == null) return 'Use dd-mm-yyyy';
          final day = int.parse(match[1]!);
          final month = int.parse(match[2]!);
          final year = int.parse(match[3]!);
          final date = DateTime(year, month, day);
          if (year < 1 ||
              date.day != day ||
              date.month != month ||
              date.year != year ||
              date.isAfter(DateTime.now())) {
            return 'Enter a valid date of birth';
          }
        }
        return null;
      },
    );
  }

  Widget _section(String title, Map<String, String> fields) => Padding(
    padding: const EdgeInsets.only(top: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 500
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final entry in fields.entries)
                  SizedBox(width: width, child: _field(entry.key, entry.value)),
              ],
            );
          },
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_working,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Row(
          children: [
            const Expanded(child: Text('Investor KYC')),
            IconButton(
              tooltip: 'Close KYC',
              onPressed: _working
                  ? null
                  : () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.investor.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload a CML PDF to fill in the details, or enter them manually. Review all required fields before saving. Saving also updates the investor’s name.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _working ? null : _read,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                      _document == null ? 'Upload CML PDF' : 'Replace CML PDF',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_document?.name ?? 'PDF only · Maximum 10 MB'),
                  if (_working)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color: _hasError
                              ? colors.error
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  _section('Demat details', {
                    'dp_id': 'DP ID',
                    'client_id': 'Client ID',
                  }),
                  _section('Personal details', {
                    'pan_no': 'PAN',
                    'name': 'Account holder name',
                    'dob': 'Date of birth',
                  }),
                  _section('Bank details', {
                    'account_number': 'Bank account number',
                    'ifsc_code': 'IFSC',
                    'bank_name': 'Bank name',
                  }),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _working ? null : () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _working ? null : _save,
            child: Text(_working ? 'Please wait…' : 'Save KYC'),
          ),
        ],
      ),
    );
  }
}
