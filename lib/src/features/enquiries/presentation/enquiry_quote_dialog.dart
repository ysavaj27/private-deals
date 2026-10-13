import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_model.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

class EnquiryQuoteDraft {
  const EnquiryQuoteDraft({
    required this.quantity,
    required this.sharePrice,
    required this.settlementDays,
  });

  final int quantity;
  final double sharePrice;
  final int settlementDays;
}

class EnquiryQuoteDialog extends StatefulWidget {
  const EnquiryQuoteDialog({
    super.key,
    required this.companyName,
    required this.replace,
    this.enquiry,
    this.existing,
  });

  final String companyName;
  final bool replace;
  final EnquiryModel? enquiry;
  final EnquiryQuote? existing;

  @override
  State<EnquiryQuoteDialog> createState() => _EnquiryQuoteDialogState();
}

class _EnquiryQuoteDialogState extends State<EnquiryQuoteDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  int? _settlementDays;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final enquiry = widget.enquiry;
    _quantity = TextEditingController(
      text: (existing?.quantity ?? enquiry?.quantity)?.toString() ?? '',
    );
    final seedPrice = existing?.basePrice ?? enquiry?.basePrice;
    _price = TextEditingController(
      text: seedPrice == null || seedPrice <= 0
          ? ''
          : seedPrice.toStringAsFixed(
              seedPrice.truncateToDouble() == seedPrice ? 0 : 2,
            ),
    );
    final seedDays = existing?.settlementDays ?? enquiry?.settlementDays;
    final allowed = app.config.settlementDays.map((e) => e.value).toSet();
    if (seedDays != null && allowed.contains(seedDays)) {
      _settlementDays = seedDays;
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = app.config.settlementDays;
    final label = widget.replace ? 'Replace quote' : 'Send quote';
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Expanded(child: Text(label)),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.companyName),
                const SizedBox(height: 8),
                Text(
                  widget.replace
                      ? 'Update quantity, offer price, and settlement for your counter-offer. The price you type is the base; the transaction price includes the processing fee.'
                      : 'Propose different terms. The price you type is the base; the transaction price includes the processing fee.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  validator: (value) {
                    final qty = int.tryParse(value?.trim() ?? '');
                    if (qty == null || qty < 1) {
                      return 'Quantity must be at least 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Offer price (base)',
                  ),
                  validator: (value) {
                    final price = double.tryParse(value?.trim() ?? '');
                    if (price == null || !price.isFinite || price < 0.01) {
                      return 'Offer price must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SettlementDaysDropdown(
                  key: ValueKey('enquiry-quote-settlement-$_settlementDays'),
                  options: options,
                  value: _settlementDays,
                  enabled: options.isNotEmpty,
                  labelText: 'Settlement cycle *',
                  onChanged: (value) => setState(() => _settlementDays = value),
                  validator: (value) =>
                      value == null ? 'Select a settlement cycle' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              EnquiryQuoteDraft(
                quantity: int.parse(_quantity.text.trim()),
                sharePrice: double.parse(_price.text.trim()),
                settlementDays: _settlementDays!,
              ),
            );
          },
          child: Text(label),
        ),
      ],
    );
  }
}
