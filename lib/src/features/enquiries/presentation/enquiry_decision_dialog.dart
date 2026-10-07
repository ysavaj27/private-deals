import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/settlement_days_dropdown.dart';

class EnquiryDecisionDialog extends StatefulWidget {
  const EnquiryDecisionDialog({
    super.key,
    required this.action,
    required this.institution,
    required this.companyName,
    this.sell = false,
  });
  final String action, companyName;
  final bool institution, sell;

  @override
  State<EnquiryDecisionDialog> createState() => _EnquiryDecisionDialogState();
}

class EnquiryDecision {
  const EnquiryDecision({this.reason, this.investorId, this.settlementDays});
  final String? reason;
  final int? investorId;
  final int? settlementDays;
}

class _EnquiryDecisionDialogState extends State<EnquiryDecisionDialog> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  List<InvestorModel> _investors = [];
  int? _investorId;
  int? _settlementDays;
  bool _loading = false;
  String _error = '';
  bool get _pickInvestor => !widget.institution && widget.action == 'accept';
  bool get _pickSettlement =>
      widget.institution && widget.action == 'accept' && !widget.sell;

  /// Sell inquiries require Pre-IPO KYC; buy inquiries do not gate on KYC here.
  bool _canSelectInvestor(InvestorModel investor) =>
      !widget.sell || investor.isPreIpoKycComplete;

  bool get _hasSelectableInvestor =>
      _investors.any(_canSelectInvestor);

  @override
  void initState() {
    super.initState();
    if (_pickInvestor) _loadInvestors();
  }

  Future<void> _loadInvestors() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    final response = await WInvestorsApi.investorsList(
      isKyc: 'All',
      isActive: 'All',
      isAif: 'All',
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (response.isSuccess) {
        _investors = (response.r ?? [])
            .where((investor) => investor.id > 0)
            .toList();
        if (_investorId != null &&
            !_investors.any(
              (investor) =>
                  investor.id == _investorId && _canSelectInvestor(investor),
            )) {
          _investorId = null;
        }
      } else {
        _error = response.m.isEmpty ? 'Unable to load investors.' : response.m;
      }
    });
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (widget.action) {
      'accept' => 'Approve',
      'reject' => 'Reject',
      _ => 'Withdraw',
    };
    final options = app.config.settlementDays;
    return AlertDialog(
      title: Text('$label inquiry'),
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
                const SizedBox(height: 16),
                if (widget.action == 'reject')
                  TextFormField(
                    controller: _reason,
                    maxLength: 1000,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: widget.institution
                          ? 'Reason (optional)'
                          : 'Reason (required)',
                    ),
                    validator: (value) =>
                        !widget.institution && (value?.trim().isEmpty ?? true)
                        ? 'Enter a rejection reason'
                        : null,
                  )
                else if (_pickInvestor) ...[
                  Text(
                    'Select the investor who will ${widget.sell ? 'sell' : 'buy'} the shares. Approval creates a transaction and sends their mandate for signing.',
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error.isNotEmpty) ...[
                    Text(_error),
                    TextButton(
                      onPressed: _loadInvestors,
                      child: const Text('Retry'),
                    ),
                  ] else if (_investors.isEmpty)
                    const Text(
                      'No investors available. Add an investor before approving.',
                    )
                  else ...[
                    if (!_hasSelectableInvestor) ...[
                      const Text(
                        'No investors with completed KYC. Complete KYC before approving a sell inquiry.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Investor'),
                      items: _investors
                          .map(
                            (investor) {
                              final selectable = _canSelectInvestor(investor);
                              return DropdownMenuItem(
                                value: investor.id,
                                enabled: selectable,
                                child: Text(
                                  selectable
                                      ? investor.displayName
                                      : '${investor.displayName} (KYC pending)',
                                  overflow: TextOverflow.ellipsis,
                                  style: selectable
                                      ? null
                                      : TextStyle(
                                          color: Theme.of(context)
                                              .disabledColor,
                                        ),
                                ),
                              );
                            },
                          )
                          .toList(),
                      onChanged: !_hasSelectableInvestor
                          ? null
                          : (value) {
                              if (value == null) return;
                              final investor = _investors.firstWhereOrNull(
                                (item) => item.id == value,
                              );
                              if (investor == null ||
                                  !_canSelectInvestor(investor)) {
                                return;
                              }
                              setState(() => _investorId = value);
                            },
                      validator: (value) {
                        if (value == null) return 'Select an investor';
                        final investor = _investors.firstWhereOrNull(
                          (item) => item.id == value,
                        );
                        if (investor == null ||
                            !_canSelectInvestor(investor)) {
                          return 'Select an investor with completed KYC';
                        }
                        return null;
                      },
                    ),
                  ],
                ] else ...[
                  Text(
                    widget.action == 'accept'
                        ? (_pickSettlement
                              ? 'Choose the settlement cycle for this buy inquiry. It will be locked to you while the wealth manager decides.'
                              : 'This inquiry will be locked to you while the wealth manager makes their decision.')
                        : 'Withdraw this open inquiry?',
                  ),
                  if (_pickSettlement) ...[
                    const SizedBox(height: 16),
                    SettlementDaysDropdown(
                      key: ValueKey('enquiry-settlement-$_settlementDays'),
                      options: options,
                      value: _settlementDays,
                      enabled: options.isNotEmpty,
                      onChanged: (value) =>
                          setState(() => _settlementDays = value),
                      validator: (value) =>
                          value == null ? 'Select a settlement cycle' : null,
                    ),
                  ],
                ],
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
          onPressed:
              _pickInvestor &&
                  (_loading ||
                      _error.isNotEmpty ||
                      _investors.isEmpty ||
                      !_hasSelectableInvestor)
              ? null
              : () {
                  if (_form.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      EnquiryDecision(
                        reason: _reason.text.trim(),
                        investorId: _investorId,
                        settlementDays: _pickSettlement
                            ? _settlementDays
                            : null,
                      ),
                    );
                  }
                },
          child: Text(label),
        ),
      ],
    );
  }
}
