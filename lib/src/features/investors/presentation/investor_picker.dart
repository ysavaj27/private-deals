import 'package:private_deals/src/shared/app_exports.dart';

import 'complete_investor_kyc_button.dart';
import 'legacy/add_investor/add_investor_page.dart';

/// Shared investor selection for investments and inquiry approvals.
/// Only server-confirmed KYC can enable a card; editing KYC preserves selection.
class InvestorPicker extends StatefulWidget {
  const InvestorPicker({
    super.key,
    required this.onSelectionChanged,
    this.selectedInvestorIds = const [],
    this.multiple = false,
    this.requirePreIpoAccess = false,
  });

  final ValueChanged<List<InvestorModel>> onSelectionChanged;
  final List<int> selectedInvestorIds;
  final bool multiple;
  final bool requirePreIpoAccess;

  @override
  State<InvestorPicker> createState() => _InvestorPickerState();
}

enum _InvestorFilter { all, ready, pending }

class _InvestorPickerState extends State<InvestorPicker> {
  final _search = TextEditingController();
  List<InvestorModel> _investors = [];
  late Set<int> _selected;
  bool _loading = true;
  String _error = '';
  _InvestorFilter _filter = _InvestorFilter.all;

  bool _canSelect(InvestorModel investor) =>
      investor.isPreIpoKycComplete &&
      (!widget.requirePreIpoAccess || investor.isPreIpoAccess);

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedInvestorIds.toSet();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    if (refresh) widget.onSelectionChanged([]);
    final result = await WInvestorsApi.investorsList(
      isKyc: 'All',
      isActive: 'All',
      isAif: 'All',
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isSuccess && result.r != null) {
        _investors = result.r!.where((item) => item.id > 0).toList();
        _selected.removeWhere(
          (id) => !_investors.any(
            (investor) => investor.id == id && _canSelect(investor),
          ),
        );
        if (!widget.multiple && _selected.length > 1) {
          _selected = {_selected.first};
        }
      } else {
        _error = 'We couldn’t load your investors. Please try again.';
        _investors = [];
        _selected.clear();
      }
    });
    _notifySelection();
  }

  void _notifySelection() => widget.onSelectionChanged(
    _investors
        .where((item) => _selected.contains(item.id) && _canSelect(item))
        .toList(),
  );

  void _toggle(InvestorModel investor) {
    if (!_canSelect(investor) || _loading) return;
    setState(() {
      if (_selected.contains(investor.id)) {
        _selected.remove(investor.id);
      } else {
        if (!widget.multiple) _selected.clear();
        _selected.add(investor.id);
      }
    });
    _notifySelection();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final query = _search.text.trim().toLowerCase();
    final ready = _investors.where(_canSelect).length;
    final pending = _investors
        .where((item) => !item.isPreIpoKycComplete)
        .length;
    final filtered = _investors.where((item) {
      final matches =
          '${item.name} ${item.email} ${item.mobileDisplay} ${item.investorType}'
              .toLowerCase()
              .contains(query);
      return matches &&
          switch (_filter) {
            _InvestorFilter.all => true,
            _InvestorFilter.ready => _canSelect(item),
            _InvestorFilter.pending => !item.isPreIpoKycComplete,
          };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          key: const ValueKey('investor-picker-search'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search name, email or mobile',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear investor search',
                    onPressed: () => setState(_search.clear),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        if (!_loading && _error.isEmpty) ...[
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final entry in [
                (_InvestorFilter.all, 'All investors', _investors.length),
                (_InvestorFilter.ready, 'Ready', ready),
                (_InvestorFilter.pending, 'KYC pending', pending),
              ])
                ChoiceChip(
                  label: Text('${entry.$2}  ${entry.$3}'),
                  selected: _filter == entry.$1,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _filter = entry.$1),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${filtered.length} ${filtered.length == 1 ? 'investor' : 'investors'}',
                  style: text.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (_selected.isNotEmpty)
                Text(
                  '${_selected.length} selected',
                  style: text.labelMedium?.copyWith(color: colors.primary),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error.isNotEmpty)
          _PickerEmpty(
            icon: Icons.cloud_off_outlined,
            title: 'Investors unavailable',
            message: _error,
            action: TextButton.icon(
              onPressed: () => _load(refresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          )
        else if (filtered.isEmpty)
          _PickerEmpty(
            icon: _investors.isEmpty
                ? Icons.people_outline_rounded
                : Icons.search_off_rounded,
            title: _investors.isEmpty
                ? 'Your investor list starts here'
                : 'No matching investors',
            message: _investors.isEmpty
                ? 'Add an investor to get started.'
                : 'Try another name or change the status filter.',
            action: _investors.isEmpty
                ? null
                : TextButton(
                    onPressed: () => setState(() {
                      _search.clear();
                      _filter = _InvestorFilter.all;
                    }),
                    child: const Text('Clear filters'),
                  ),
          )
        else
          for (final investor in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: InvestorSelectionCard(
                key: ValueKey('investor-option-${investor.id}'),
                investor: investor,
                selected: _selected.contains(investor.id),
                multiple: widget.multiple,
                onSelect: _canSelect(investor) ? () => _toggle(investor) : null,
                onKycSaved: () => _load(refresh: true),
                accessRequired:
                    widget.requirePreIpoAccess && !investor.isPreIpoAccess,
              ),
            ),
      ],
    );
  }
}

class InvestorSelectionCard extends StatelessWidget {
  const InvestorSelectionCard({
    super.key,
    required this.investor,
    required this.selected,
    required this.onSelect,
    required this.onKycSaved,
    this.multiple = false,
    this.accessRequired = false,
  });

  final InvestorModel investor;
  final bool selected, multiple, accessRequired;
  final VoidCallback? onSelect;
  final Future<void> Function() onKycSaved;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final name = investor.name.trim().isEmpty
        ? 'Unnamed investor'
        : investor.name.trim();
    final words = name.split(RegExp(r'\s+'));
    final initials = words
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
    final complete = investor.isPreIpoKycComplete;
    final avatar = Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadii.mdAll,
      ),
      child: Text(
        initials,
        style: text.titleMedium?.copyWith(color: colors.onPrimaryContainer),
      ),
    );
    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: .45)
          : colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.lgAll,
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            selected: selected,
            enabled: onSelect != null,
            label: 'Select $name',
            child: InkWell(
              onTap: onSelect,
              child: Padding(
                padding: AppSpace.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: ClipRRect(
                            borderRadius: AppRadii.mdAll,
                            child: investor.profilePhoto.trim().isEmpty
                                ? avatar
                                : CacheImage(
                                    url: investor.profile,
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                    placeholderBuilder: (_) => avatar,
                                    errorWidget: (_, _, _) => avatar,
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: text.titleSmall),
                              const SizedBox(height: AppSpace.xs),
                              Text(
                                [
                                  if (investor.isSelf) 'My account',
                                  if (investor.investorType.trim().isNotEmpty)
                                    investor.investorType,
                                  if (!investor.isSelf &&
                                      investor.investorType.trim().isEmpty)
                                    'Investor',
                                ].join(' · '),
                                style: text.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        ExcludeSemantics(
                          child: Icon(
                            onSelect == null
                                ? Icons.lock_outline_rounded
                                : selected
                                ? Icons.check_circle_rounded
                                : multiple
                                ? Icons.check_box_outline_blank_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 22,
                            color: selected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (investor.email.trim().isNotEmpty ||
                        investor.mobileDisplay.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.md),
                      if (investor.email.trim().isNotEmpty)
                        _ContactLine(
                          icon: Icons.alternate_email_rounded,
                          value: investor.email.trim(),
                        ),
                      if (investor.mobileDisplay.isNotEmpty)
                        _ContactLine(
                          icon: Icons.phone_outlined,
                          value: investor.mobileDisplay,
                        ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: complete
                                ? colors.primaryContainer
                                : colors.secondaryContainer,
                            borderRadius: AppRadii.smAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                complete
                                    ? Icons.verified_user_outlined
                                    : Icons.schedule_rounded,
                                size: 14,
                                color: complete
                                    ? colors.onPrimaryContainer
                                    : colors.onSecondaryContainer,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                complete ? 'KYC complete' : 'KYC pending',
                                style: text.labelSmall?.copyWith(
                                  color: complete
                                      ? colors.onPrimaryContainer
                                      : colors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'Selected',
                              style: text.labelSmall?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!complete || accessRequired) ...[
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final message = Text(
                    !complete
                        ? 'Complete KYC to select this investor.'
                        : 'Unlisted Shares access required.',
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  );
                  final action = !complete
                      ? CompleteInvestorKycButton(
                          investor: investor,
                          onSaved: onKycSaved,
                        )
                      : TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Get.to(
                              () => AddInvestorPage(),
                              arguments: investor,
                            );
                          },
                          child: const Text('Update access'),
                        );
                  if (constraints.maxWidth < 420 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [message, const SizedBox(height: 4), action],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: message),
                      const SizedBox(width: 8),
                      action,
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PickerEmpty extends StatelessWidget {
  const _PickerEmpty({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 36,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ?action,
        ],
      ),
    ),
  );
}

/// Content for the existing app dialog host, with a pinned selection footer.
class InvestorPickerDialog extends StatefulWidget {
  const InvestorPickerDialog({
    super.key,
    this.multiple = false,
    this.requirePreIpoAccess = false,
    this.selectedInvestorIds = const [],
    this.allowRegistration = false,
    this.onContinue,
  });
  final bool multiple, requirePreIpoAccess, allowRegistration;
  final List<int> selectedInvestorIds;
  final ValueChanged<List<InvestorModel>>? onContinue;
  @override
  State<InvestorPickerDialog> createState() => _InvestorPickerDialogState();
}

class _InvestorPickerDialogState extends State<InvestorPickerDialog> {
  List<InvestorModel> _selected = [];
  final _pickerKey = GlobalKey();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final availableHeight =
        (media.size.height -
                media.viewInsets.bottom -
                media.padding.vertical -
                112)
            .clamp(100.0, 760.0);
    final picker = InvestorPicker(
      key: _pickerKey,
      multiple: widget.multiple,
      requirePreIpoAccess: widget.requirePreIpoAccess,
      selectedInvestorIds: widget.selectedInvestorIds,
      onSelectionChanged: (value) => setState(() => _selected = value),
    );
    Widget layout(BoxConstraints constraints) {
      final compact =
          constraints.maxHeight < 420 || media.textScaler.scale(14) > 20;
      final content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: AppSpace.paddingLg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppSpace.paddingMd,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    Icons.people_alt_outlined,
                    color: colors.onPrimaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.multiple
                            ? 'Select investors'
                            : 'Select an investor',
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.multiple
                            ? 'Choose who you’re investing for.'
                            : 'Choose an account for this investment.',
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close investor selection',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          if (compact)
            Padding(padding: AppSpace.paddingLg, child: picker)
          else
            Flexible(
              child: Scrollbar(
                controller: _scroll,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scroll,
                  padding: AppSpace.paddingLg,
                  child: picker,
                ),
              ),
            ),
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: AppSpace.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _selected.isEmpty
                      ? 'Select an investor to continue'
                      : '${_selected.length} ${_selected.length == 1 ? 'investor' : 'investors'} selected',
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (widget.allowRegistration)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Get.to(() => AddInvestorPage());
                        },
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                          size: 18,
                        ),
                        label: const Text('Add investor'),
                      )
                    else
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    FilledButton.icon(
                      onPressed: _selected.isEmpty
                          ? null
                          : () {
                              if (widget.onContinue != null) {
                                widget.onContinue!(_selected);
                              } else {
                                Navigator.of(context).pop(
                                  widget.multiple
                                      ? _selected
                                      : _selected.single,
                                );
                              }
                            },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      iconAlignment: IconAlignment.end,
                      label: Text(
                        widget.multiple
                            ? 'Continue (${_selected.length})'
                            : 'Continue',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      return compact
          ? Scrollbar(
              controller: _scroll,
              child: SingleChildScrollView(controller: _scroll, child: content),
            )
          : content;
    }

    return Container(
      width: 640,
      constraints: BoxConstraints(maxHeight: availableHeight),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: LayoutBuilder(builder: (_, constraints) => layout(constraints)),
    );
  }
}
