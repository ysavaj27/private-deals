import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/widgets/custom_progressbar.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/secondary_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/transaction_slip_dialog.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/transaction_slip_dialog_ctrl.dart';

/// Full-width LP Secondary activity list (desktop + phone).
class LpSecondaryTransactionList extends StatelessWidget {
  final SecondaryTransactionPageCtrl ctrl;
  final bool isPhone;

  const LpSecondaryTransactionList({
    super.key,
    required this.ctrl,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoading.isTrue) return const Loader();
      if (ctrl.finalList.isEmpty) {
        return NoDataView(onPressed: ctrl.getData);
      }
      return RefreshIndicator(
        onRefresh: ctrl.getData,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            isPhone ? 0 : 4,
            4,
            isPhone ? 0 : 4,
            24,
          ),
          itemCount: ctrl.finalList.length,
          separatorBuilder: (_, __) => SizedBox(height: isPhone ? 10 : 12),
          itemBuilder: (context, index) {
            final item = ctrl.finalList[index];
            if (item.isBuying) {
              return _BuyListItem(
                model: item.buy,
                ctrl: ctrl,
                isPhone: isPhone,
              );
            }
            return _SellListItem(
              model: item.sell,
              ctrl: ctrl,
              isPhone: isPhone,
            );
          },
        ),
      );
    });
  }
}

// ─── Shared chrome ───────────────────────────────────────────────────────────

class _ListPanel extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;

  const _ListPanel({
    required this.child,
    required this.accent,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: accent),
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideBadge extends StatelessWidget {
  final String label;
  final bool isBuy;

  const _SideBadge({required this.label, required this.isBuy});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isBuy ? colors.primaryContainer : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: isBuy ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ThinProgress extends StatelessWidget {
  final double percentage;

  const _ThinProgress({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final pct = percentage.clamp(0, 100);
    return Row(
      children: [
        Expanded(
          child: CustomProgressBar(
            progress: pct / 100,
            height: 6,
            radius: 4,
            backgroundColor: colors.surfaceContainerHighest,
            gradientColors: [
              colors.primary.withValues(alpha: 0.5),
              colors.primary,
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${pct.round()}%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}

class _DocsMenu extends StatelessWidget {
  final SecondaryTransactionModel model;

  const _DocsMenu({required this.model});

  @override
  Widget build(BuildContext context) {
    final hasSh4 = model.sh4Document.signedPath.isNotEmpty;
    final hasReceipt = model.shareTransferReceipt.signedPath.isNotEmpty;
    if (!hasSh4 && !hasReceipt) return const SizedBox.shrink();

    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      splashRadius: 18,
      tooltip: 'Documents',
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: context.theme.colorScheme.onSurfaceVariant,
      ),
      onSelected: (int result) async {
        if (result == 1) {
          await DownloadFile.downloadFromUrl(
            url: model.sh4Document.signedPath,
            fileName: model.sh4Document.meta.name,
          );
        } else if (result == 2) {
          await DownloadFile.downloadFromUrl(
            url: model.shareTransferReceipt.signedPath,
            fileName: model.shareTransferReceipt.meta.name,
          );
        }
      },
      itemBuilder: (_) {
        final list = <PopupMenuEntry<int>>[];
        list.addIf(
          hasSh4,
          const PopupMenuItem(value: 1, child: Text('Download SH4')),
        );
        list.addIf(
          hasReceipt,
          const PopupMenuItem(
            value: 2,
            child: Text('Share transfer receipt'),
          ),
        );
        return list;
      },
    );
  }
}

class _ExpirePill extends StatelessWidget {
  final DateTime expiredAt;
  final Color color;

  const _ExpirePill({required this.expiredAt, required this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '${expiredAt.timeRemainingValue} ${expiredAt.timeRemainingUnit}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildActions({
  required BuildContext context,
  required SecondaryTransactionModel model,
  required SecondaryTransactionPageCtrl ctrl,
  required bool isPhone,
}) {
  final colors = context.theme.colorScheme;

  if (model.upload) {
    return FilledButton.tonal(
      onPressed: () async {
        final res = await showCustomDialog(TransactionSlipDialog(model));
        Get.delete<TransactionSlipDialogCtrl>();
        if (res == true) ctrl.getData();
      },
      style: FilledButton.styleFrom(
        minimumSize: Size(isPhone ? 0 : 132, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        visualDensity: VisualDensity.compact,
      ),
      child: const Text('Upload receipt'),
    );
  }

  if (model.approve) {
    return FilledButton(
      onPressed: () =>
          ctrl.approveRequest(model.id, model.shareTransferReceipt.id),
      style: FilledButton.styleFrom(
        minimumSize: Size(isPhone ? 0 : 120, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(isPhone ? 'Approve' : 'Approve transfer'),
    );
  }

  if (model.waiting) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => ctrl.updateStatus(id: model.id, status: 2),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            foregroundColor: colors.error,
            side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Reject'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => ctrl.updateStatus(id: model.id, status: 1),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Buy'),
        ),
      ],
    );
  }

  return const SizedBox.shrink();
}

// ─── Buy row ─────────────────────────────────────────────────────────────────

class _BuyListItem extends StatelessWidget {
  final SecondaryTransactionModel model;
  final SecondaryTransactionPageCtrl ctrl;
  final bool isPhone;

  const _BuyListItem({
    required this.model,
    required this.ctrl,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final hasAction = model.upload || model.approve || model.waiting;

    return _ListPanel(
      accent: colors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompanyRow(
            logo: model.startup.cms.logo,
            title: model.startup.brandName,
            badge: const _SideBadge(label: 'BUY', isBuy: true),
            amount: model.translationStart
                ? model.investmentAmount.toFormattedPrice
                : '—',
            amountCaption: 'Total',
            onLogoTap: () => Get.toNamed(
              Routes.primaryDetailPage,
              arguments: model.startupId,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.showExpire)
                  _ExpirePill(
                    expiredAt: model.expiredAt,
                    color: model.color,
                  ),
                _DocsMenu(model: model),
              ],
            ),
            isPhone: isPhone,
          ),
          const SizedBox(height: 12),
          _MetaLine(
            items: [
              (
                'Shares',
                model.translationStart ? model.shares.formattedDecimal : 'N/A',
              ),
              ('PPS', model.sharePrice.toFormattedPrice),
              if (!isPhone) ('Date', model.createdAt.showDate),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 12),
          if (isPhone) ...[
            _StatusBlock(
              status: model.currentStatus,
              nextStep: model.nextStep,
              showNext: !hasAction,
            ),
            if (!model.rejected) ...[
              const SizedBox(height: 10),
              _ThinProgress(percentage: model.percentage),
            ],
            if (hasAction) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: _buildActions(
                  context: context,
                  model: model,
                  ctrl: ctrl,
                  isPhone: true,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              model.createdAt.showDate,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _StatusBlock(
                    status: model.currentStatus,
                    nextStep: model.nextStep,
                    showNext: !hasAction,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!model.rejected) ...[
                        _ThinProgress(percentage: model.percentage),
                        const SizedBox(height: 10),
                      ],
                      if (hasAction)
                        _buildActions(
                          context: context,
                          model: model,
                          ctrl: ctrl,
                          isPhone: false,
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Sell group ──────────────────────────────────────────────────────────────

class _SellListItem extends StatelessWidget {
  final SellRequestModel model;
  final SecondaryTransactionPageCtrl ctrl;
  final bool isPhone;

  const _SellListItem({
    required this.model,
    required this.ctrl,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;

    return _ListPanel(
      accent: colors.onSurfaceVariant,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: _CompanyRow(
              logo: model.startup.cms.logo,
              title: model.startup.brandName,
              badge: const _SideBadge(label: 'SELL', isBuy: false),
              amount: model.shares.formattedDecimal,
              amountCaption: 'Listed shares',
              onLogoTap: () => Get.toNamed(
                Routes.primaryDetailPage,
                arguments: model.startupId,
              ),
              subtitle: 'Ask ${model.price.toFormattedPrice} / share',
              isPhone: isPhone,
            ),
          ),
          if (model.transactions.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < model.transactions.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: isPhone ? 14 : 56,
                        endIndent: 14,
                        color: colors.outlineVariant,
                      ),
                    _SellBuyerRow(
                      model: model.transactions[i],
                      ctrl: ctrl,
                      isPhone: isPhone,
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

class _SellBuyerRow extends StatelessWidget {
  final SecondaryTransactionModel model;
  final SecondaryTransactionPageCtrl ctrl;
  final bool isPhone;

  const _SellBuyerRow({
    required this.model,
    required this.ctrl,
    required this.isPhone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final hasAction = model.upload || model.approve;
    final buyerName =
        model.buyer.name.isNotEmpty ? model.buyer.name : 'Buyer';

    return Padding(
      padding: EdgeInsets.fromLTRB(isPhone ? 14 : 16, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isPhone ? 14 : 16,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  buyerName.characters.first.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buyerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    model.translationStart
                        ? model.investmentAmount.toFormattedPrice
                        : '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    model.translationStart
                        ? '${model.shares.formattedDecimal} sh'
                        : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              _DocsMenu(model: model),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            model.currentStatus,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              height: 1.3,
            ),
          ),
          if (!hasAction && model.nextStep.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Next: ${model.nextStep}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ],
          const SizedBox(height: 8),
          _ThinProgress(percentage: model.percentage),
          if (hasAction) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: _buildActions(
                context: context,
                model: model,
                ctrl: ctrl,
                isPhone: isPhone,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              model.createdAt.showDate,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Small building blocks ───────────────────────────────────────────────────

class _CompanyRow extends StatelessWidget {
  final String logo;
  final String title;
  final String? subtitle;
  final Widget badge;
  final String amount;
  final String amountCaption;
  final Widget? trailing;
  final VoidCallback? onLogoTap;
  final bool isPhone;

  const _CompanyRow({
    required this.logo,
    required this.title,
    required this.badge,
    required this.amount,
    required this.amountCaption,
    required this.isPhone,
    this.subtitle,
    this.trailing,
    this.onLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    final size = isPhone ? 40.0 : 48.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onLogoTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant),
            ),
            clipBehavior: Clip.antiAlias,
            child: LogoImage(
              url: logo,
              width: size,
              height: size,
              radius: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isPhone ? 15 : 17,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  badge,
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amountCaption,
              style: TextStyle(
                fontSize: 10,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: TextStyle(
                fontSize: isPhone ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MetaLine extends StatelessWidget {
  final List<(String, String)> items;

  const _MetaLine({required this.items});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final item in items)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${item.$1}  ',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                TextSpan(
                  text: item.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusBlock extends StatelessWidget {
  final String status;
  final String nextStep;
  final bool showNext;

  const _StatusBlock({
    required this.status,
    required this.nextStep,
    this.showNext = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            color: colors.onSurface,
          ),
        ),
        if (showNext && nextStep.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'NEXT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nextStep,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: colors.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}
