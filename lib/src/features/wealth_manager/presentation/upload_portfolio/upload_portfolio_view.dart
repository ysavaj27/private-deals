import 'package:intl/intl.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:searchfield/searchfield.dart';

import 'upload_portfolio_ctrl.dart';

/// A single form keeps desktop and phone selection, validation and review aligned.
class UploadPortfolioView extends StatefulWidget {
  const UploadPortfolioView({super.key});

  @override
  State<UploadPortfolioView> createState() => _UploadPortfolioViewState();
}

class _UploadPortfolioViewState extends State<UploadPortfolioView> {
  final c = Get.find<UploadPortfolioCtrl>();
  final _formKey = GlobalKey<FormState>();

  bool get _hasAccess =>
      app.wUser.isPrimaryAccess ||
      app.wUser.isSecondaryAccess ||
      app.wUser.isPreIpoAccess;

  void _reset() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    c.clearData();
  }

  Future<void> _submit() async {
    if (c.isUploading() || !_hasAccess) return;
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState;
    if (form == null) return;
    final invalidFields = form.validateGranularly();
    if (invalidFields.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalidFields.first.context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.15,
      );
      return;
    }
    // Resolve the current text every time, including custom company names.
    // An earlier selection must never leak into a later submission.
    c.selectedInvestor(
      c.investorList.firstWhere(
        (e) =>
            e.name.trim().toLowerCase() ==
            c.investorCTRL.text.trim().toLowerCase(),
      ),
    );
    c.selectedCompany(
      c.list.firstWhereOrNull(
            (e) =>
                e.brandName.trim().toLowerCase() ==
                c.companyCTRL.text.trim().toLowerCase(),
          ) ??
          CompanyStartup.fromJson({}),
    );
    await c.addData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading()) {
            return const Center(
              key: ValueKey('upload-loading'),
              child: CircularProgressIndicator(),
            );
          }
          if (!_hasAccess) {
            return AppFadeIn(
              child: Center(
                key: const ValueKey('upload-no-access'),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Portfolio upload is not available for your account.',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          final uploading = c.isUploading();
          final fields = _fields(context);
          return AppFadeIn(
            key: const ValueKey('upload-form'),
            child: ExcludeFocus(
            excluding: uploading,
            child: AbsorbPointer(
              absorbing: uploading,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  MediaQuery.sizeOf(context).width < 600 ? 16 : 32,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PORTFOLIO MANAGEMENT',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload portfolio',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add an existing investment to your investor’s portfolio.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Form(
                          key: _formKey,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final summary = _PortfolioSummary(
                                controller: c,
                                onSubmit: _submit,
                                onReset: _reset,
                                uploading: uploading,
                              );
                              if (constraints.maxWidth < 920) {
                                return Column(
                                  children: [
                                    fields,
                                    const SizedBox(height: 20),
                                    summary,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: fields),
                                  const SizedBox(width: 24),
                                  SizedBox(width: 340, child: summary),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          );
        }),
      ),
    );
  }

  Widget _fields(BuildContext context) {
    return Column(
      children: [
        _FormSection(
          number: '01',
          title: 'Investment type',
          description: 'Choose the asset class for this holding.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final options = [
                if (app.wUser.isPrimaryAccess || app.wUser.isSecondaryAccess)
                  _typeOption(
                    DashboardTypeEnum.primary,
                    'Private Equity',
                    'Investments in private businesses',
                    Icons.business_center_outlined,
                  ),
                if (app.wUser.isPreIpoAccess)
                  _typeOption(
                    DashboardTypeEnum.preIpo,
                    'Unlisted Company',
                    'Shares in unlisted companies',
                    Icons.apartment_rounded,
                  ),
              ];
              if (constraints.maxWidth < 540) {
                return Column(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      options[i],
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: options[i]),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _FormSection(
          number: '02',
          title: 'Investor & company',
          description: 'Link this holding to the right investor.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchableTextField<InvestorModel>(
                controller: c.investorCTRL,
                title: 'Investor',
                hint: 'Search by investor name',
                isRequired: true,
                suggestions: c.investorList
                    .map(
                      (e) =>
                          SearchFieldListItem<InvestorModel>(e.name, item: e),
                    )
                    .toList(),
                onSuggestionTap: (data) {
                  c.investorCTRL.text = data.item?.name ?? '';
                  c.selectedInvestor(data.item);
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Select an investor';
                  }
                  if (!c.investorList.any(
                    (e) =>
                        e.name.trim().toLowerCase() ==
                        value.trim().toLowerCase(),
                  )) {
                    return 'Choose an investor from the search results';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SearchableTextField<CompanyStartup>(
                controller: c.companyCTRL,
                title: 'Company',
                hint: c.isStartUp
                    ? 'Search private equity companies'
                    : 'Search unlisted companies',
                isRequired: true,
                suggestions: c.list
                    .map(
                      (e) => SearchFieldListItem<CompanyStartup>(
                        e.brandName,
                        item: e,
                      ),
                    )
                    .toList(),
                onSuggestionTap: (data) {
                  c.companyCTRL.text = data.item?.brandName ?? '';
                  FocusScope.of(context).unfocus();
                },
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a company name'
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Can’t find the company? Enter its full name to add the holding.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _FormSection(
          number: '03',
          title: 'Holding details',
          description: 'Enter the quantity and original purchase price.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final quantity = _LabeledField(
                    label: 'Share quantity',
                    child: TextFormField(
                      key: const ValueKey('portfolio-quantity'),
                      controller: c.qtyCTRL,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: 'e.g. 1,000',
                        suffixText: 'shares',
                      ),
                      validator: (value) {
                        final quantity = int.tryParse(value ?? '');
                        return quantity == null || quantity <= 0
                            ? 'Enter a quantity greater than 0'
                            : null;
                      },
                    ),
                  );
                  final price = _LabeledField(
                    label: 'Price per share',
                    child: TextFormField(
                      key: const ValueKey('portfolio-price'),
                      controller: c.sharePriceCTRL,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) =>
                              RegExp(r'^\d*\.?\d{0,2}$').hasMatch(newValue.text)
                              ? newValue
                              : oldValue,
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixText: '₹ ',
                      ),
                      validator: (value) {
                        final price = double.tryParse(value ?? '');
                        return price == null || !price.isFinite || price <= 0
                            ? 'Enter a price greater than 0'
                            : null;
                      },
                    ),
                  );
                  if (constraints.maxWidth < 440) {
                    return Column(
                      children: [quantity, const SizedBox(height: 20), price],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: quantity),
                      const SizedBox(width: 16),
                      Expanded(child: price),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _LabeledField(
                label: 'Investment date',
                optional: true,
                child: TextFormField(
                  key: const ValueKey('portfolio-date'),
                  controller: c.purchaseDateCTRL,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Select purchase date',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                  onTap: () async {
                    final date = await AppDateTimePicker.date(
                      context: context,
                      title: 'Investment date',
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDate:
                          DateFormat('dd-MM-yyyy')
                              .tryParseStrict(c.purchaseDateCTRL.text) ??
                          DateTime.now(),
                    );
                    if (date != null && mounted && !c.isClosed) {
                      c.purchaseDateCTRL.text = date.showDate;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeOption(
    DashboardTypeEnum type,
    String title,
    String description,
    IconData icon,
  ) {
    final colors = Theme.of(context).colorScheme;
    final selected = c.currentIndex() == type;
    return Semantics(
      selected: selected,
      child: Material(
        color: selected
            ? colors.primaryContainer.withValues(alpha: 0.45)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (selected) return;
            _reset();
            c.changeTab(type);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: colors.primary),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      color: selected ? colors.primary : colors.outline,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.number,
    required this.title,
    required this.description,
    required this.child,
  });
  final String number;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  number,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.optional = false,
  });
  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              TextSpan(
                text: optional ? ' (optional)' : ' *',
                style: TextStyle(
                  color: optional
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        child,
      ],
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.controller,
    required this.onSubmit,
    required this.onReset,
    required this.uploading,
  });
  final UploadPortfolioCtrl controller;
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return AnimatedBuilder(
      animation: Listenable.merge([
        c.investorCTRL,
        c.companyCTRL,
        c.qtyCTRL,
        c.sharePriceCTRL,
        c.purchaseDateCTRL,
      ]),
      builder: (context, _) {
        final quantity = int.tryParse(c.qtyCTRL.text);
        final price = double.tryParse(c.sharePriceCTRL.text);
        final total =
            quantity != null &&
                quantity > 0 &&
                price != null &&
                price.isFinite &&
                price > 0
            ? quantity * price
            : null;
        final hasAmount = total != null && total.isFinite;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [BrandColors.navy, Color(0xFF172B46)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: BrandColors.gold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Investment summary',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'TOTAL INVESTMENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFC3D0E1),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasAmount ? currency.format(total) : '₹ —',
                      key: const ValueKey('portfolio-total'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasAmount
                          ? '${NumberFormat.decimalPattern('en_IN').format(quantity)} shares × ${currency.format(price)}'
                          : 'Enter quantity and price to calculate.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC3D0E1),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _detail(
                      context,
                      'Asset class',
                      c.isStartUp ? 'Private Equity' : 'Unlisted Company',
                    ),
                    _detail(
                      context,
                      'Investor',
                      c.investorCTRL.text.trim().isEmpty
                          ? 'Not selected'
                          : c.investorCTRL.text.trim(),
                    ),
                    _detail(
                      context,
                      'Company',
                      c.companyCTRL.text.trim().isEmpty
                          ? 'Not selected'
                          : c.companyCTRL.text.trim(),
                    ),
                    _detail(
                      context,
                      'Investment date',
                      c.purchaseDateCTRL.text.isEmpty
                          ? 'Not provided'
                          : c.purchaseDateCTRL.text,
                    ),
                    const Divider(),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Review the details before adding this holding to the investor’s portfolio.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: uploading ? null : onSubmit,
                      icon: uploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        uploading ? 'Adding holding…' : 'Add to portfolio',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: uploading ? null : onReset,
                      child: const Text('Clear form'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detail(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
