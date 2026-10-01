import 'package:flutter/material.dart';
import 'package:private_deals/src/features/institution/data/api/deal_api.dart';
import 'package:private_deals/src/features/institution/data/deal_payloads.dart';
import 'package:private_deals/src/features/institution/data/models/deal/deal_model.dart';

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
    text: widget.deal.sharePrice.toString(),
  );
  late final minimum = TextEditingController(
    text: widget.deal.minimumQty.toInt().toString(),
  );
  late final total = TextEditingController(
    text: widget.deal.availableQuantity > 0
        ? widget.deal.availableQuantity.toInt().toString()
        : '',
  );
  bool saving = false;
  String error = '';
  @override
  void dispose() {
    price.dispose();
    minimum.dispose();
    total.dispose();
    super.dispose();
  }

  Future<void> save() async {
    try {
      final payload = DealPayloads.update(
        uuid: widget.deal.uuid,
        finalPrice: price.text,
        minimumQuantity: minimum.text,
        totalQuantity: total.text,
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
      setState(() => error = e.message);
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
                'Enter the final customer price. The processing fee will not be added again; the original base price stays unchanged.',
              ),
              const SizedBox(height: 12),
              TextField(
                enabled: !saving,
                controller: price,
                decoration: const InputDecoration(
                  labelText: 'Final customer price (₹)',
                ),
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
