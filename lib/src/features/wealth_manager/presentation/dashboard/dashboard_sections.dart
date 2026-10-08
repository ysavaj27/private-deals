import 'package:private_deals/src/features/wealth_manager/presentation/dashboard/dashboard_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/home_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/kyc_pending_investor/kyc_pending_investor_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

/// Section label used across dashboard blocks.
class DashboardSectionHeader extends StatelessWidget {
  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleMedium),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Hero: total AUM + avg ticket — primary visual focus from [WDashboardModel].
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardPageCtrl>();
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final m = c.model();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        decoration: BoxDecoration(
          borderRadius: AppRadii.lgAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    BrandColors.navyContainerDark,
                    Color(0xFF0D1117),
                    Color(0xFF1A2E48),
                  ]
                : const [
                    BrandColors.navy,
                    BrandColors.navyAction,
                    Color(0xFF3D7AB5),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: BrandColors.navy.withValues(alpha: isDark ? 0.35 : 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: AppRadii.pill,
                  ),
                  child: Text(
                    'Assets under management',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up_rounded,
                  color: BrandColors.gold.withValues(alpha: 0.95),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              m.totalAmountInvested.toFormattedPrice,
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Avg ticket  ·  ${m.averageTicketSize.toFormattedPrice}',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            const SizedBox(height: 16),
            Row(
              children: [
                _HeroStat(label: 'Investors', value: '${m.totalInvestors}'),
                _HeroStat(
                  label: c.isPrimary ? 'Startups' : 'Companies',
                  value: '${m.totalStartups}',
                ),
                _HeroStat(
                  label: 'Pending',
                  value:
                      '${m.pendingKyc + m.pendingDocumentSign + m.pendingPayment.toInt()}',
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact secondary KPIs under the hero (same model fields, quieter UI).
class DashboardKpiStrip extends StatelessWidget {
  const DashboardKpiStrip({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardPageCtrl>();
    return Obx(() {
      final m = c.model();
      final items = [
        _KpiTileData(
          icon: Icons.payments_outlined,
          title: 'Avg ticket',
          value: m.averageTicketSize.toFormattedPrice,
          accent: BrandColors.gold,
        ),
        _KpiTileData(
          icon: Icons.groups_outlined,
          title: 'Investors',
          value: '${m.totalInvestors}',
          accent: BrandColors.navyAction,
        ),
        _KpiTileData(
          icon: Icons.apartment_outlined,
          title: c.isPrimary ? 'Startups' : 'Companies',
          value: '${m.totalStartups}',
          accent: const Color(0xFF0F766E),
        ),
      ];

      if (compact) {
        return Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpace.sm),
              Expanded(child: _KpiTile(data: items[i])),
            ],
          ],
        );
      }

      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpace.md),
            Expanded(child: _KpiTile(data: items[i], tall: true)),
          ],
        ],
      );
    });
  }
}

class _KpiTileData {
  const _KpiTileData({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.data, this.tall = false});

  final _KpiTileData data;
  final bool tall;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomCardWidget(
      padding: EdgeInsets.all(tall ? 18 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.12),
              borderRadius: AppRadii.smAll,
            ),
            child: Icon(data.icon, size: 18, color: data.accent),
          ),
          SizedBox(height: tall ? 16 : 12),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            data.title,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pending KYC / Document / Fund Transfer — navigates to Pending Tasks tab.
class DashboardPendingStrip extends StatelessWidget {
  const DashboardPendingStrip({super.key});

  void _open(PendingTaskEnum type) {
    final home = Get.find<HomePageCtrl>();
    home.onTap(WTabBarEnum.pendingTasks);
    final taskCtrl = Get.put(KycPendingInvestorPageCtrl());
    taskCtrl.type(type);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardPageCtrl>();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Obx(() {
      final m = c.model();
      final total =
          m.pendingKyc + m.pendingDocumentSign + m.pendingPayment.toInt();
      final tiles = [
        (
          'KYC',
          '${m.pendingKyc}',
          Icons.badge_outlined,
          PendingTaskEnum.kyc,
          colors.primary,
        ),
        (
          'Documents',
          '${m.pendingDocumentSign}',
          Icons.description_outlined,
          PendingTaskEnum.document,
          BrandColors.gold,
        ),
        (
          'Fund transfer',
          '${m.pendingPayment.toInt()}',
          Icons.account_balance_wallet_outlined,
          PendingTaskEnum.fundTransfer,
          const Color(0xFFDB2777),
        ),
      ];

      return CustomCardWidget(
        padding: AppSpace.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DashboardSectionHeader(
                    title: 'Action required',
                    subtitle: total == 0
                        ? 'You are all caught up'
                        : '$total items need attention',
                  ),
                ),
                if (total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadii.pill,
                    ),
                    child: Text(
                      '$total',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: _PendingTile(
                      title: tiles[i].$1,
                      value: tiles[i].$2,
                      icon: tiles[i].$3,
                      accent: tiles[i].$5,
                      onTap: () => _open(tiles[i].$4),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(height: 12),
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ranked top investors from [WDashboardModel.topInvestors].
class DashboardTopInvestors extends StatelessWidget {
  const DashboardTopInvestors({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DashboardPageCtrl>();
    final colors = Theme.of(context).colorScheme;

    return Obx(() {
      final list = c.model().topInvestors;
      if (list.isEmpty) return const SizedBox.shrink();

      return CustomCardWidget(
        padding: AppSpace.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardSectionHeader(
              title: 'Top investors',
              subtitle: 'Most active by amount invested',
              trailing: onViewAll != null && c.model().investors.isNotEmpty
                  ? TextButton(
                      onPressed: onViewAll,
                      child: const Text('View all'),
                    )
                  : null,
            ),
            const SizedBox(height: AppSpace.md),
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) Divider(height: 20, color: colors.outlineVariant),
              _InvestorRankRow(
                rank: i + 1,
                name: list[i].name,
                photo: list[i].profilePhoto,
                amount: list[i].amountInvested.toFormattedPrice,
                startups: list[i].totalStartups,
                commission: list[i].commissionEarned,
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _InvestorRankRow extends StatelessWidget {
  const _InvestorRankRow({
    required this.rank,
    required this.name,
    required this.photo,
    required this.amount,
    required this.startups,
    required this.commission,
  });

  final int rank;
  final String name;
  final String photo;
  final String amount;
  final int startups;
  final double commission;

  Color _rankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return BrandColors.gold;
      case 2:
        return const Color(0xFF94A3B8);
      case 3:
        return const Color(0xFFB45309);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();
    final accent = _rankColor(context);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpace.md),
        CircleAvatar(
          radius: 20,
          backgroundColor: colors.primaryContainer,
          foregroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo.isEmpty
              ? Text(
                  initial,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
              if (startups > 0 || commission > 0) ...[
                const SizedBox(height: 2),
                Text(
                  [
                    if (startups > 0) '$startups deals',
                    if (commission > 0) 'Comm ${commission.toFormattedPrice}',
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
