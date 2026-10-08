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
  String _type = 'all';
  String _query = '';

  static const _filters = {
    'all': 'All statuses',
    'open': 'Open',
    'locked': 'Awaiting decision',
    'rejected': 'Rejected',
    'converted': 'Converted',
    'withdrawn': 'Withdrawn',
  };

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
            ? 'Unable to load enquiries. Please retry.'
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response.m)));
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

  Iterable<EnquiryModel> get _searched => _items.where(
    (item) =>
        '${item.companyName} ${item.partnerName} ${item.institutionName} ${item.dealType}'
            .toLowerCase()
            .contains(_query),
  );

  Iterable<EnquiryModel> get _typed =>
      _searched.where((item) => _type == 'all' || item.dealType == _type);

  List<EnquiryModel> get _filtered => _typed
      .where((item) => _status == 'all' || item.status == _status)
      .toList();

  int _countFor(String key) =>
      _typed.where((item) => key == 'all' || item.status == key).length;

  int _typeCountFor(String key) =>
      _searched.where((item) => key == 'all' || item.dealType == key).length;

  Widget _typeFilter(String type, String label) {
    final colors = Theme.of(context).colorScheme;
    final appearance = _InquiryTypeAppearance.forType(type, colors);
    final selected = _type == type;
    return ChoiceChip(
      key: ValueKey('inquiry-type-$type'),
      avatar: Icon(appearance.icon, size: 18, color: appearance.foreground),
      label: Text(_loading ? label : '$label (${_typeCountFor(type)})'),
      labelStyle: TextStyle(
        color: selected ? appearance.foreground : colors.onSurface,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: appearance.background,
      backgroundColor: colors.surfaceContainerLow,
      side: BorderSide(
        color: selected ? appearance.border : colors.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.sm,
      ),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _type = type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final phone = MediaQuery.sizeOf(context).width < 600;
    final items = _filtered;

    return RefreshIndicator(
      onRefresh: () async {
        if (!_acting && !_loading) await _load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          phone ? AppSpace.lg : AppSpace.xxl,
          phone ? AppSpace.lg : AppSpace.xl,
          phone ? AppSpace.lg : AppSpace.xxl,
          AppSpace.xxl,
        ),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.institution
                          ? 'Incoming Enquiries'
                          : 'My Enquiries',
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      widget.institution
                          ? 'Review buy and sell requests from wealth managers.'
                          : 'Track enquiries you raised and respond once a seller locks them.',
                      style: text.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Refresh enquiries',
                onPressed: _loading || _acting ? null : _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              _typeFilter('all', 'All'),
              _typeFilter('buy', 'Buy'),
              _typeFilter('sell', 'Sell'),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.institution
                      ? 'Search company or wealth manager'
                      : 'Search company or seller',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                ),
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final entry in _filters.entries)
                if (!widget.institution || entry.key != 'withdrawn')
                  ChoiceChip(
                    label: Text(
                      _loading
                          ? entry.value
                          : '${entry.value} (${_countFor(entry.key)})',
                    ),
                    selected: _status == entry.key,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _status = entry.key),
                  ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          if (_submitting) ...[
            const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: AppSpace.md),
          ],
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 72),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error.isNotEmpty)
            _EmptyPanel(
              icon: Icons.error_outline_rounded,
              title: 'Could not load enquiries',
              message: _error,
              actionLabel: 'Retry',
              onAction: _acting ? null : _load,
            )
          else if (items.isEmpty)
            _EmptyPanel(
              icon: Icons.inbox_outlined,
              title: 'No enquiries found',
              message: _query.isNotEmpty || _status != 'all' || _type != 'all'
                  ? 'Try another search, enquiry type, or status filter.'
                  : widget.institution
                  ? 'New buy and sell enquiries from wealth managers will appear here.'
                  : 'Enquiries you submit for companies will appear here.',
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                child: _EnquiryCard(
                  item: item,
                  institution: widget.institution,
                  acting: _acting || _loading,
                  onApprove: () => _act(item, 'accept'),
                  onReject: () => _act(item, 'reject'),
                  onWithdraw: () => _act(item, 'withdraw'),
                  onViewTransactions: () => Get.offNamed(
                    Routes.unlistedTransactionsPath(
                      institution: widget.institution,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EnquiryCard extends StatelessWidget {
  const _EnquiryCard({
    required this.item,
    required this.institution,
    required this.acting,
    required this.onApprove,
    required this.onReject,
    required this.onWithdraw,
    required this.onViewTransactions,
  });

  final EnquiryModel item;
  final bool institution;
  final bool acting;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onWithdraw;
  final VoidCallback onViewTransactions;

  static final _qty = NumberFormat.decimalPattern('en_IN');
  static final _money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  bool get _canRespond =>
      institution ? item.canSellerRespond : item.canPartnerRespond;

  ({Color fg, Color bg}) _statusColors(ColorScheme colors) {
    return switch (item.status) {
      'open' => (
        fg: colors.onSecondaryContainer,
        bg: colors.secondaryContainer,
      ),
      'locked' => (fg: colors.onPrimaryContainer, bg: colors.primaryContainer),
      'converted' => (fg: colors.onPrimary, bg: colors.primary),
      'rejected' => (fg: colors.onErrorContainer, bg: colors.errorContainer),
      'withdrawn' => (
        fg: colors.onSurfaceVariant,
        bg: colors.surfaceContainerHighest,
      ),
      _ => (fg: colors.onSurfaceVariant, bg: colors.surfaceContainerHighest),
    };
  }

  String _formatCreated(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value.replaceFirst(' ', 'T'));
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appearance = _InquiryTypeAppearance.forType(item.dealType, colors);
    final status = _statusColors(colors);
    final created = _formatCreated(item.createdAt);
    final counterparty = institution
        ? (item.partnerName.isEmpty
              ? null
              : 'Wealth manager · ${item.partnerName}')
        : (item.institutionName.isEmpty
              ? null
              : 'Seller · ${item.institutionName}');

    final metrics = <({String label, String value})>[
      (label: 'Qty', value: _qty.format(item.quantity)),
      (label: 'Offered', value: _money.format(item.basePrice)),
      (label: 'Customer', value: _money.format(item.sharePrice)),
      if (item.settlementLabel != null)
        (label: 'Settlement', value: item.settlementLabel!),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: appearance.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: appearance.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.md,
            ),
            child: Row(
              children: [
                Icon(appearance.icon, color: appearance.foreground, size: 22),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    item.typeLabel,
                    style: text.titleSmall?.copyWith(
                      color: appearance.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompanyLogo(url: item.companyLogo, name: item.companyName),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.companyName.isEmpty
                                ? 'Unknown company'
                                : item.companyName,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _Chip(
                                label: item.statusLabel(institution),
                                foreground: status.fg,
                                background: status.bg,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_canRespond) ...[
                  const SizedBox(height: AppSpace.md),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      OutlinedButton(
                        onPressed: acting ? null : onReject,
                        child: const Text('Reject'),
                      ),
                      FilledButton(
                        onPressed: acting ? null : onApprove,
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
                if (counterparty != null || created.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  Text(
                    [
                      ?counterparty,
                      if (created.isNotEmpty) created,
                    ].join(' · '),
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.md,
                    vertical: AppSpace.md,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Wrap(
                    spacing: AppSpace.xl,
                    runSpacing: AppSpace.md,
                    children: [
                      for (final metric in metrics)
                        _MetricInline(label: metric.label, value: metric.value),
                    ],
                  ),
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  _InfoBanner(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    body: item.notes,
                  ),
                ],
                if (item.rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.md),
                  _InfoBanner(
                    icon: Icons.info_outline_rounded,
                    label: 'Rejection reason',
                    body: item.rejectionReason,
                    tone: _InfoTone.warning,
                  ),
                ],
                if (institution && item.status == 'converted') ...[
                  const SizedBox(height: AppSpace.md),
                  _InfoBanner(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Next step',
                    body: 'The transaction appears in Transactions after the investor signs the mandate.',
                    tone: _InfoTone.success,
                  ),
                ],
                if ((!institution && item.canWithdraw) ||
                    item.status == 'converted') ...[
                  const SizedBox(height: AppSpace.md),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      if (!institution && item.canWithdraw)
                        OutlinedButton(
                          onPressed: acting ? null : onWithdraw,
                          child: const Text('Withdraw'),
                        ),
                      if (item.status == 'converted')
                        TextButton.icon(
                          onPressed: acting ? null : onViewTransactions,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: const Text('View transactions'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The same type colors and icons identify filters and cards in both workspaces.
class _InquiryTypeAppearance {
  const _InquiryTypeAppearance(this.background, this.foreground, this.icon);

  final Color background;
  final Color foreground;
  Color get border => foreground.withValues(alpha: 0.25);
  final IconData icon;

  factory _InquiryTypeAppearance.forType(String type, ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    return switch (type) {
      'buy' => _InquiryTypeAppearance(
        dark ? const Color(0xFF263442) : const Color(0xFFEAF0F6),
        dark ? const Color(0xFFB5C5D6) : const Color(0xFF455F7A),
        Icons.south_west_rounded,
      ),
      'sell' => _InquiryTypeAppearance(
        dark ? const Color(0xFF3B322B) : const Color(0xFFF4EEE7),
        dark ? const Color(0xFFD4BFAC) : const Color(0xFF7B6048),
        Icons.north_east_rounded,
      ),
      _ => _InquiryTypeAppearance(
        colors.surfaceContainerHighest,
        colors.onSurfaceVariant,
        Icons.inbox_outlined,
      ),
    };
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (url.isNotEmpty) {
      return LogoImage(url: url, width: 48, height: 48, radius: 12);
    }
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricInline extends StatelessWidget {
  const _MetricInline({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadii.smAll,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum _InfoTone { neutral, warning, success }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.label,
    required this.body,
    this.tone = _InfoTone.neutral,
  });

  final IconData icon;
  final String label;
  final String body;
  final _InfoTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (Color bg, Color fg) = switch (tone) {
      _InfoTone.warning => (colors.errorContainer, colors.onErrorContainer),
      _InfoTone.success => (colors.primaryContainer, colors.onPrimaryContainer),
      _InfoTone.neutral => (
        colors.surfaceContainerLow,
        colors.onSurfaceVariant,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadii.mdAll),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: text.bodyMedium?.copyWith(color: fg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppSpace.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.xl,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.onSurfaceVariant),
          const SizedBox(height: AppSpace.md),
          Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpace.lg),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
