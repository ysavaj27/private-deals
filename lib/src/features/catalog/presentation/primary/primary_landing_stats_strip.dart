import 'package:private_deals/src/features/catalog/presentation/primary/primary_landing_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

/// Live landing statistics from [LandingPageModel.statistics].
class PrimaryLandingStatsStrip extends StatelessWidget {
  const PrimaryLandingStatsStrip({super.key, this.horizontal = false});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryLandingPageCtrl>();
    return Obx(() {
      final s = c.model().statistics;
      final cards = [
        MetricCard(
          title: 'Total Investments',
          value: s.investment.toFormattedPrice,
        ),
        MetricCard(
          title: 'Funded deals',
          value: '${s.funded}',
        ),
        MetricCard(
          title: 'Secondary completed',
          value: '${s.secondary}',
        ),
        MetricCard(
          title: 'Current opportunities',
          value: '${s.current}',
        ),
      ];

      if (horizontal) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpace.sm),
                SizedBox(width: 160, child: cards[i]),
              ],
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
        child: Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpace.md),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    });
  }
}
