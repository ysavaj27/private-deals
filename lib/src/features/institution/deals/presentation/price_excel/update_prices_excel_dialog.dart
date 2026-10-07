import 'package:flutter/material.dart';
import 'package:private_deals/src/features/institution/data/models/deal/price_excel_review_model.dart';
import 'package:private_deals/src/features/institution/deals/presentation/price_excel/update_prices_excel_ctrl.dart';
import 'package:private_deals/src/shared/institution_widgets/app_button.dart';
import 'package:private_deals/src/shared/institution_widgets/custom_card_widget.dart';

Future<bool?> showUpdatePricesExcelDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      final compact = size.width < 700;
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.all(compact ? 12 : 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1080,
            maxHeight: size.height * (compact ? 0.94 : 0.88),
          ),
          child: const _UpdatePricesExcelDialog(),
        ),
      );
    },
  );
}

class _UpdatePricesExcelDialog extends StatefulWidget {
  const _UpdatePricesExcelDialog();

  @override
  State<_UpdatePricesExcelDialog> createState() =>
      _UpdatePricesExcelDialogState();
}

class _UpdatePricesExcelDialogState extends State<_UpdatePricesExcelDialog> {
  late final UpdatePricesExcelCtrl ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = UpdatePricesExcelCtrl()..addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    ctrl
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _close({bool saved = false}) {
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final compact = MediaQuery.sizeOf(context).width < 700;
    final horizontal = compact ? 20.0 : 28.0;

    return CustomCardWidget(
      padding: EdgeInsets.zero,
      radius: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox.expand(
          child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 16, 8, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.table_view_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _titleFor(ctrl.step),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (ctrl.step == PriceExcelStep.review &&
                            ctrl.review != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${ctrl.review!.createCount} to save · '
                            '${ctrl.review!.skipCount} blank · '
                            '${ctrl.review!.errorCount} need a fix',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Close',
                    child: Material(
                      color: colors.surfaceContainerHighest,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _close(
                          saved: ctrl.step == PriceExcelStep.done,
                        ),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            size: 22,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 12),
              child: _StepIndicator(step: ctrl.step),
            ),
            Expanded(
              child: switch (ctrl.step) {
                PriceExcelStep.start => _StartStep(
                  ctrl: ctrl,
                  horizontal: horizontal,
                ),
                PriceExcelStep.review => _ReviewStep(
                  ctrl: ctrl,
                  horizontal: horizontal,
                ),
                PriceExcelStep.done => _DoneStep(count: ctrl.savedCount),
              },
            ),
            if (ctrl.message.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 8),
                child: _InlineBanner(
                  message: ctrl.message,
                  isError: ctrl.messageIsError,
                ),
              ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 16),
              child: _FooterActions(
                ctrl: ctrl,
                onClose: () => _close(saved: true),
                onDismiss: () => _close(),
                compact: compact,
              ),
            ),
            if (ctrl.busy)
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: colors.surfaceContainerHighest,
              ),
          ],
        ),
        ),
      ),
    );
  }

  String _titleFor(PriceExcelStep step) => switch (step) {
    PriceExcelStep.start => 'Update prices',
    PriceExcelStep.review => 'Check prices',
    PriceExcelStep.done => 'Prices saved',
  };
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final PriceExcelStep step;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labels = const ['Download', 'Review', 'Done'];
    final activeIndex = step.index;

    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: i <= activeIndex
                    ? colors.primary
                    : colors.outlineVariant,
              ),
            ),
          _StepDot(
            index: i + 1,
            label: labels[i],
            active: i <= activeIndex,
            current: i == activeIndex,
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.active,
    required this.current,
  });

  final int index;
  final String label;
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? colors.primary : colors.surfaceContainerHighest,
            border: Border.all(
              color: current ? colors.primary : colors.outlineVariant,
              width: current ? 2 : 1,
            ),
          ),
          child: Text(
            '$index',
            style: textTheme.labelMedium?.copyWith(
              color: active ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: active ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: current ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StartStep extends StatelessWidget {
  const _StartStep({required this.ctrl, required this.horizontal});

  final UpdatePricesExcelCtrl ctrl;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 560 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.table_view_rounded,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Download the sheet, change the prices, then upload it here.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Download sheet',
                icon: Icons.download_rounded,
                expanded: true,
                isLoading: ctrl.busy,
                onPressed: ctrl.busy ? null : ctrl.downloadSheet,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Upload filled sheet',
                icon: Icons.upload_file_rounded,
                variant: AppButtonVariant.outline,
                expanded: true,
                onPressed: ctrl.busy ? null : () => ctrl.pickAndUpload(),
              ),
              const SizedBox(height: 16),
              Text(
                "Yesterday's prices are already filled at the top. A blank price is skipped.",
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.ctrl, required this.horizontal});

  final UpdatePricesExcelCtrl ctrl;
  final double horizontal;

  @override
  Widget build(BuildContext context) {
    final review = ctrl.review;
    if (review == null) {
      return const Center(child: Text('No review data.'));
    }

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final createRows = review.createRows;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CountChip(
                          label: 'Will save',
                          count: review.createCount,
                          emphasize: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CountChip(
                          label: 'Left blank',
                          count: review.skipCount,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CountChip(
                          label: 'Needs a fix',
                          count: review.errorCount,
                          isError: review.errorCount > 0,
                        ),
                      ),
                    ],
                  ),
                  if (review.errorCount > 0 && review.createCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Clear or blank the rows that need a fix in Excel, then upload again to save the ${review.createCount} valid ${review.createCount == 1 ? 'price' : 'prices'}.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (review.unchangedCount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Some prices are already saved for today.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (review.skipCount > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${review.skipCount} ${review.skipCount == 1 ? 'company was' : 'companies were'} left blank and will be skipped.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (review.errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: wide ? 110 : 96),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              itemCount: review.errors.length,
              itemBuilder: (context, index) =>
                  _ErrorTile(error: review.errors[index]),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 6, horizontal, 6),
          child: Row(
            children: [
              Text(
                'Prices to save',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${createRows.length}',
                style: textTheme.titleSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: createRows.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No new prices to save. Fill at least one sell or buy price in the sheet.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          if (wide) const _PriceListHeader(),
                          Expanded(
                            child: ListView.separated(
                              itemCount: createRows.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) => _CreateRowTile(
                                row: createRows[index],
                                wide: wide,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 44,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$count ${count == 1 ? 'price' : 'prices'} saved for today.',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your company list and uploaded counts will refresh when you close.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    this.emphasize = false,
    this.isError = false,
  });

  final String label;
  final int count;
  final bool emphasize;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final warning = _warningTone(context);

    final bg = isError
        ? warning.background
        : emphasize
        ? colors.primaryContainer
        : colors.surfaceContainerLow;
    final fg = isError
        ? warning.foreground
        : emphasize
        ? colors.onPrimaryContainer
        : colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? warning.border : colors.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _PriceListHeader extends StatelessWidget {
  const _PriceListHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w700,
    );

    return Container(
      color: colors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Company', style: style)),
          SizedBox(
            width: 88,
            child: Text('Sheet', style: style, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 120,
            child: Text('Your price', style: style, textAlign: TextAlign.end),
          ),
          SizedBox(
            width: 120,
            child: Text('Buyer sees', style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _CreateRowTile extends StatelessWidget {
  const _CreateRowTile({required this.row, this.wide = false});

  final PriceExcelRow row;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (wide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.brandName,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (row.legalName.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      row.legalName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 88,
              child: Text(
                row.sheet.isEmpty ? '—' : row.sheet,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                _formatPrice(row.basePrice),
                textAlign: TextAlign.end,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                _formatPrice(row.sharePrice),
                textAlign: TextAlign.end,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.brandName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (row.legalName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    row.legalName,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (row.sheet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    row.sheet,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Your price',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatPrice(row.basePrice),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Buyer sees',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatPrice(row.sharePrice),
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.error});

  final PriceExcelError error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final warning = _warningTone(context);

    final meta = [
      if (error.sheet.isNotEmpty) error.sheet,
      if (error.excelRow > 0) 'Row ${error.excelRow}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: warning.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warning.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.isNotEmpty)
            Text(
              meta,
              style: textTheme.labelSmall?.copyWith(
                color: warning.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (error.brandName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              error.brandName,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: warning.foreground,
              ),
            ),
          ],
          if (error.legalName.isNotEmpty) ...[
            Text(
              error.legalName,
              style: textTheme.bodySmall?.copyWith(
                color: warning.foreground.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 2),
          Text(
            error.message,
            style: textTheme.bodySmall?.copyWith(
              color: warning.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final warning = _warningTone(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? warning.background : colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: isError ? Border.all(color: warning.border) : null,
      ),
      child: Text(
        message,
        style: textTheme.bodySmall?.copyWith(
          color: isError ? warning.foreground : colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FooterActions extends StatelessWidget {
  const _FooterActions({
    required this.ctrl,
    required this.onClose,
    required this.onDismiss,
    required this.compact,
  });

  final UpdatePricesExcelCtrl ctrl;
  final VoidCallback onClose;
  final VoidCallback onDismiss;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hasErrors = ctrl.hasFixableErrors;

    return switch (ctrl.step) {
      PriceExcelStep.start => Align(
        alignment: Alignment.centerRight,
        child: AppButton(
          label: 'Close',
          variant: AppButtonVariant.text,
          onPressed: ctrl.canDismiss ? onDismiss : null,
        ),
      ),
      PriceExcelStep.review => compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton(
                  label: hasErrors
                      ? 'Upload fixed sheet'
                      : 'Save prices',
                  icon: hasErrors
                      ? Icons.upload_file_rounded
                      : Icons.save_outlined,
                  expanded: true,
                  isLoading: ctrl.busy,
                  onPressed: ctrl.busy
                      ? null
                      : hasErrors
                      ? ctrl.uploadAnother
                      : ctrl.canSave
                      ? ctrl.savePrices
                      : null,
                ),
                const SizedBox(height: 8),
                if (!hasErrors)
                  AppButton(
                    label: 'Upload another file',
                    variant: AppButtonVariant.outline,
                    expanded: true,
                    onPressed: ctrl.busy ? null : ctrl.uploadAnother,
                  )
                else
                  AppButton(
                    label: 'Save prices',
                    variant: AppButtonVariant.outline,
                    expanded: true,
                    onPressed: null,
                  ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: hasErrors
                        ? 'Save prices'
                        : 'Upload another file',
                    variant: AppButtonVariant.outline,
                    expanded: true,
                    onPressed: hasErrors || ctrl.busy
                        ? null
                        : ctrl.uploadAnother,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: hasErrors
                        ? 'Upload fixed sheet'
                        : 'Save prices',
                    icon: hasErrors
                        ? Icons.upload_file_rounded
                        : Icons.save_outlined,
                    expanded: true,
                    isLoading: ctrl.busy,
                    onPressed: ctrl.busy
                        ? null
                        : hasErrors
                        ? ctrl.uploadAnother
                        : ctrl.canSave
                        ? ctrl.savePrices
                        : null,
                  ),
                ),
              ],
            ),
      PriceExcelStep.done => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: compact ? double.infinity : 220,
          child: AppButton(
            label: 'Close',
            icon: Icons.check_rounded,
            expanded: true,
            onPressed: onClose,
          ),
        ),
      ),
    };
  }
}

class _WarningTone {
  const _WarningTone({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

_WarningTone _warningTone(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isDark) {
    return _WarningTone(
      background: const Color(0xFF3A2F1A),
      foreground: const Color(0xFFE8D5A3),
      border: const Color(0xFF8A7340).withValues(alpha: 0.55),
    );
  }
  return _WarningTone(
    background: const Color(0xFFFFF6E5),
    foreground: const Color(0xFF7A5B14),
    border: const Color(0xFFD2B56A).withValues(alpha: 0.7),
  );
}

String _formatPrice(double? value) {
  if (value == null) return '—';
  return '₹${value.toStringAsFixed(2)}';
}
