import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_api.dart';
import 'package:private_deals/src/features/enquiries/data/enquiry_model.dart';
import 'package:private_deals/src/features/enquiries/presentation/enquiry_decision_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_order_detail_dialog.dart';

class EnquiriesPage extends StatefulWidget {
  const EnquiriesPage({super.key, this.institution = false});
  final bool institution;

  @override
  State<EnquiriesPage> createState() => _EnquiriesPageState();
}

class _EnquiriesPageState extends State<EnquiriesPage> {
  List<EnquiryModel> _items = [];
  bool _loading = true;
  bool _acting = false;
  bool _submitting = false;
  String _error = '';
  String _status = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final response = await EnquiryApi.list(institution: widget.institution);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.isSuccess) {
        _items = response.r ?? [];
      } else {
        _error = response.m.isEmpty
            ? 'Unable to load inquiries. Please retry.'
            : response.m;
      }
    });
  }

  Future<void> _act(EnquiryModel item, String action) async {
    if (_acting || _loading) return;
    setState(() => _acting = true);
    try {
      final decision = await showDialog<EnquiryDecision>(
        context: context,
        builder: (_) => EnquiryDecisionDialog(
          action: action,
          institution: widget.institution,
          companyName: item.companyName,
          sell: item.dealType == 'sell',
        ),
      );
      if (decision == null || !mounted) return;
      setState(() => _submitting = true);
      PreIpoOrderModel? order;
      final BaseModel response;
      if (!widget.institution && action == 'accept') {
        final result = await EnquiryApi.accept(
          uuid: item.uuid,
          investorId: decision.investorId!,
        );
        response = result;
        if (result.isSuccess) order = result.r;
      } else {
        response = await EnquiryApi.respond(
          institution: widget.institution,
          uuid: item.uuid,
          action: action,
          reason: decision.reason,
          settlementDays: item.isBuy && action == 'accept'
              ? decision.settlementDays
              : null,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.m)));
      // A competing Institution may have locked the inquiry. Always refresh,
      // including business failures, so stale actions cannot remain available.
      await _load();
      if (!mounted) return;
      setState(() => _submitting = false);
      if (order == null) return;
      final createdOrder = order;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Transaction created'),
          content: Text(
            '${createdOrder.transactionInvoiceNo ?? '#${createdOrder.id}'}\n\n${createdOrder.mandateSent == false ? response.m : 'The investor can sign the mandate using the SMS or WhatsApp link.'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _openOrder(createdOrder);
              },
              child: const Text('View transaction'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _acting = false;
          _submitting = false;
        });
      }
    }
  }

  Future<void> _openOrder(PreIpoOrderModel order) async {
    final controller = Get.isRegistered<PreIPOBuyTransactionPageCtrl>()
        ? Get.find<PreIPOBuyTransactionPageCtrl>()
        : Get.put(PreIPOBuyTransactionPageCtrl());
    var current = order;
    await showPreIpoOrderDetailDialog(
      order: current,
      onAction: (action) => controller.handleAction(current, action),
      loadDetail: () async {
        final detail = await controller.loadDetail(order.id);
        if (detail != null) current = detail;
        return detail;
      },
    );
  }

  String _money(double value) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(value);

  @override
  Widget build(BuildContext context) {
    final items = _items
        .where(
          (item) =>
              (_status == 'all' || item.status == _status) &&
              '${item.companyName} ${item.partnerName} ${item.institutionName} ${item.dealType}'
                  .toLowerCase()
                  .contains(_query),
        )
        .toList();
    return RefreshIndicator(
      onRefresh: () async {
        if (!_acting && !_loading) await _load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 600 ? 16 : 28,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.institution ? 'Incoming Inquiries' : 'My Inquiries',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Refresh inquiries',
                onPressed: _loading || _acting ? null : _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search inquiries',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in const {
                'all': 'All',
                'open': 'Open',
                'locked': 'Awaiting decision',
                'rejected': 'Rejected',
                'converted': 'Converted',
                'withdrawn': 'Withdrawn',
              }.entries)
                if (!widget.institution || entry.key != 'withdrawn')
                  ChoiceChip(
                    label: Text(entry.value),
                    selected: _status == entry.key,
                    onSelected: (_) => setState(() => _status = entry.key),
                  ),
            ],
          ),
          const SizedBox(height: 16),
          if (_submitting) const LinearProgressIndicator(),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error.isNotEmpty) ...[
            Text(_error),
            TextButton(
              onPressed: _acting ? null : _load,
              child: const Text('Retry'),
            ),
          ] else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No inquiries found')),
            )
          else
            ...items.map(_card),
        ],
      ),
    );
  }

  Widget _card(EnquiryModel item) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.companyName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(item.typeLabel),
              Text(
                item.statusLabel(widget.institution),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            children: [
              Text(
                'Quantity: ${NumberFormat.decimalPattern('en_IN').format(item.quantity)}',
              ),
              Text('Offered price: ${_money(item.basePrice)}'),
              Text('Customer price: ${_money(item.sharePrice)}'),
              if (item.settlementLabel != null)
                Text('Settlement: ${item.settlementLabel}'),
            ],
          ),
          if (widget.institution) Text('Wealth manager: ${item.partnerName}'),
          if (!widget.institution && item.institutionName.isNotEmpty)
            Text('Seller: ${item.institutionName}'),
          if (item.createdAt.isNotEmpty) Text('Created: ${item.createdAt}'),
          if (item.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Notes: ${item.notes}'),
            ),
          if (item.rejectionReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Rejection reason: ${item.rejectionReason}'),
            ),
          if (widget.institution && item.status == 'converted')
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'The transaction appears in Transactions after the investor signs the mandate.',
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.institution
                  ? item.canSellerRespond
                  : item.canPartnerRespond) ...[
                FilledButton(
                  onPressed: _acting || _loading
                      ? null
                      : () => _act(item, 'accept'),
                  child: const Text('Approve'),
                ),
                OutlinedButton(
                  onPressed: _acting || _loading
                      ? null
                      : () => _act(item, 'reject'),
                  child: const Text('Reject'),
                ),
              ],
              if (!widget.institution && item.canWithdraw)
                OutlinedButton(
                  onPressed: _acting || _loading
                      ? null
                      : () => _act(item, 'withdraw'),
                  child: const Text('Withdraw'),
                ),
              if (item.status == 'converted')
                TextButton(
                  onPressed: _acting
                      ? null
                      : () => Get.offNamed(
                          widget.institution
                              ? '/institution/unlisted-transactions'
                              : '/wealth-manager/investor-transactions',
                        ),
                  child: const Text('View transactions'),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
