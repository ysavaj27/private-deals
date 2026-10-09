import 'package:private_deals/src/features/catalog/presentation/pre_ipo/pre_ipo_investment/select_investor_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'pre_ipo_detail_page_ctrl.dart';
import 'pre_ipo_investor_card.dart';

/// Keeps investor selection and order review in the same dialog route.
class PreIPOInvestmentDialog extends StatefulWidget {
  const PreIPOInvestmentDialog({super.key, required this.controller});

  final PreIPODetailPageCtrl controller;

  @override
  State<PreIPOInvestmentDialog> createState() => _PreIPOInvestmentDialogState();
}

class _PreIPOInvestmentDialogState extends State<PreIPOInvestmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late bool _review = widget.controller.investorList.isNotEmpty;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _back() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _review = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Obx(() {
      final submitting = c.investing.value;
      return PopScope(
        canPop: !submitting,
        child: !_review
            ? SelectInvestorDialog(
                selectedInvestorIds: c.investorList
                    .map((investor) => investor.investorId)
                    .toList(),
                onContinue: (investors) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  c.setInvestors(investors);
                  setState(() => _review = true);
                },
              )
            : _buildReview(context, submitting),
      );
    });
  }

  Widget _buildReview(BuildContext context, bool submitting) {
    final c = widget.controller;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);
    final offer = c.selectedOffer.value;
    final availableHeight =
        (media.size.height -
                media.viewInsets.bottom -
                media.padding.vertical -
                112)
            .clamp(100.0, 760.0);
    final investors = c.investorList.toList();
    final total = investors.fold<double>(
      0,
      (sum, investor) => sum + investor.totalPrice.value,
    );

    final header = Padding(
      padding: AppSpace.paddingLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review investment', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Step 2 of 2 · Confirm quantity and price for each investor.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close investment',
            onPressed: submitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
    final form = AbsorbPointer(
      absorbing: submitting,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offer != null) ...[
              Text('Seller: ${offer.name}', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                '${offer.price.toCurrency} per share · Min. ${offer.minimumQty} shares',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],
            AnimatedSize(
              duration: AppMotion.duration(context, AppMotion.normal),
              curve: AppMotion.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (investors.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No investors selected. Go back to choose investors.',
                      ),
                    ),
                  for (final investor in investors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.md),
                      child: PreIPOInvestorCard(
                        key: ObjectKey(investor),
                        model: investor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final footer = Padding(
      padding: AppSpace.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 4,
            children: [
              Text(
                '${investors.length} ${investors.length == 1 ? 'investor' : 'investors'}',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                'Total: ${total.toCurrency}',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: submitting ? null : _back,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: FilledButton(
                  onPressed: submitting || investors.isEmpty
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState?.validate() ?? false) {
                            c.onPress();
                          }
                        },
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Invest'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      width: 640,
      constraints: BoxConstraints(maxHeight: availableHeight),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On short viewports, let the header scroll so the actions still fit.
          final compact =
              constraints.maxHeight < 420 || media.textScaler.scale(14) > 20;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact) ...[
                header,
                Divider(height: 1, color: colors.outlineVariant),
              ],
              Flexible(
                child: Scrollbar(
                  controller: _scroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    key: const ValueKey('pre-ipo-investment-review-scroll'),
                    controller: _scroll,
                    child: Column(
                      children: [
                        if (compact) header,
                        Padding(padding: AppSpace.paddingLg, child: form),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: colors.outlineVariant),
              footer,
            ],
          );
        },
      ),
    );
  }
}
