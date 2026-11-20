import 'package:flutter/material.dart';
import 'package:private_deals/src/core/session/auth_session.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/deal_payloads.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

Future<bool?> editDealDialog(BuildContext context, DealModel deal) {
  if (!deal.isMine) return Future.value(false);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EditDealDialog(deal: deal),
  );
}

class _EditDealDialog extends StatefulWidget {
  const _EditDealDialog({required this.deal});
  final DealModel deal;
  @override
  State<_EditDealDialog> createState() => _EditDealState();
}

class _EditDealState extends State<_EditDealDialog> {
  late final price = TextEditingController(
    text: _baseText(widget.deal.basePrice),
  );
  late final minimum = TextEditingController(
    text: widget.deal.minimumQty.toInt().toString(),
  );
  late final total = TextEditingController(
    text: widget.deal.availableQuantity > 0
        ? widget.deal.availableQuantity.toInt().toString()
        : '',
  );
  late int? settlementDays = widget.deal.settlementDays;
  bool saving = false;
  String error = '';

  bool get requiresSettlement =>
      !widget.deal.isBuyDeal &&
      widget.deal.company.type.toLowerCase() != 'secondary';

  static String _baseText(double? value) {
    if (value == null || value <= 0) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  @override
  void dispose() {
    price.dispose();
    minimum.dispose();
    total.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      if (requiresSettlement &&
          (settlementDays == null ||
              !app.config.settlementDays.any(
                (option) => option.value == settlementDays,
              ))) {
        setState(() => error = 'Select a settlement cycle');
        return;
      }
      final payload = DealPayloads.update(
        uuid: widget.deal.uuid,
        basePrice: price.text,
        minimumQuantity: minimum.text,
        totalQuantity: total.text,
        dealType: widget.deal.dealType,
        status: widget.deal.status,
        isHotDeal: widget.deal.isHotDeal,
        settlementDays: requiresSettlement ? settlementDays : null,
      );
      setState(() {
        saving = true;
        error = '';
      });
      final result = await DealApi.updateDeal(payload);
      if (!mounted) return;
      if (result.isSuccess) {
        Navigator.pop(context, true);
        return;
      }
      setState(() {
        saving = false;
        error = result.m;
      });
    } on FormatException catch (e) {
      setState(() {
        saving = false;
        error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !saving,
    child: AlertDialog(
      title: const Text('Edit deal'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.deal.company.brandName),
              const SizedBox(height: 12),
              const Text(
                'Enter your base price. Landing price is calculated for each partner.',
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !saving,
                controller: price,
                decoration: const InputDecoration(labelText: 'Base price (₹)'),
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !saving,
                controller: minimum,
                decoration: const InputDecoration(
                  labelText: 'Minimum quantity',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !saving,
                controller: total,
                decoration: const InputDecoration(labelText: 'Total quantity'),
              ),
              if (requiresSettlement) ...[
                const SizedBox(height: 12),
                SettlementDaysDropdown(
                  key: ValueKey('edit-settlement-$settlementDays'),
                  options: app.config.settlementDays,
                  value: settlementDays,
                  enabled: !saving && app.config.settlementDays.isNotEmpty,
                  onChanged: (value) => setState(() {
                    settlementDays = value;
                    error = '';
                  }),
                ),
              ],
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : save,
          child: Text(saving ? 'Saving…' : 'Save'),
        ),
      ],
    ),
  );
}
