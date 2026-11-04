import 'package:private_deals/src/shared/app_exports.dart';

import 'primary_detail_page_ctrl.dart';
import 'primary_detail_sections.dart';

class PrimaryInvestmentPanel extends StatelessWidget {
  const PrimaryInvestmentPanel({super.key, required this.c});
  final PrimaryDetailPageCtrl c;

  @override
  Widget build(BuildContext context) {
    final model = c.model;
    final round = model.raisingRound;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return PrimaryDetailSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Investment summary', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryDetailBadge(
              label: round.roundStatus.isEmpty
                  ? 'Round status unavailable'
                  : c.canInvest
                  ? 'Raising now'
                  : round.roundStatus.replaceAll('_', ' ').capitalFirst,
              accent: c.canInvest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share price',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            primaryMoney(round.sharePrice),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1),
          ),
          for (final fact in [
            (
              'Instrument',
              round.instrument.isEmpty ? '—' : round.instrument.instrumentName,
            ),
            if (round.name.isNotEmpty) ('Round', round.name),
            if (model.isEquity)
              ('Valuation', primaryMoney(round.floor))
            else ...[
              ('Valuation floor', primaryMoney(round.floor)),
              ('Valuation cap', primaryMoney(round.cap)),
            ],
            (
              'Equity offered',
              round.equityOffered > 0
                  ? '${round.equityOffered.formattedDecimal}%'
                  : '—',
            ),
            ('Private Deals round size', primaryMoney(round.fundRequirement)),
            ('Total round size', primaryMoney(round.totalFundRequirement)),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      fact.$1,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      fact.$2,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.control),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Minimum investment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  primaryMoney(round.minimumInvestment),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (c.canInvest)
            Obx(
              () => FilledButton.icon(
                key: const ValueKey('primary-invest-now'),
                onPressed: c.isOpeningInvestment.value
                    ? null
                    : c.startInvestment,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                iconAlignment: IconAlignment.end,
                label: Text(
                  c.isOpeningInvestment.value
                      ? 'Opening investment…'
                      : 'Invest Now',
                ),
              ),
            )
          else
            Text(
              'Investment is not available for this round.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
