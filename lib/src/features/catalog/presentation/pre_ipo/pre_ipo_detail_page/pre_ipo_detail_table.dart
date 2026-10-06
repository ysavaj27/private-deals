import 'package:flutter/material.dart';

/// Keep financial columns readable at every viewport size.
class PreIPODetailTable extends StatefulWidget {
  const PreIPODetailTable({
    super.key,
    required this.headers,
    required this.rows,
  });
  final List<String> headers;
  final List<List<String>> rows;

  @override
  State<PreIPODetailTable> createState() => _PreIPODetailTableState();
}

class _PreIPODetailTableState extends State<PreIPODetailTable> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.headers.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = 220.0 + (widget.headers.length - 1) * 130;
        final width = constraints.maxWidth > minWidth
            ? constraints.maxWidth
            : minWidth;
        final scrolls = width > constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scrolls)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Scroll to see all columns',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: scrolls,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(bottom: scrolls ? 14 : 0),
                  child: SizedBox(
                    width: width,
                    child: Table(
                      columnWidths: {0: const FixedColumnWidth(220)},
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      border: TableBorder(
                        horizontalInside: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.6),
                        ),
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                          ),
                          children: [
                            for (var i = 0; i < widget.headers.length; i++)
                              _cell(widget.headers[i], i, header: true),
                          ],
                        ),
                        for (var row = 0; row < widget.rows.length; row++)
                          TableRow(
                            decoration: BoxDecoration(
                              color: row.isEven
                                  ? colors.surface
                                  : colors.surfaceContainerLow,
                            ),
                            children: [
                              for (
                                var col = 0;
                                col < widget.headers.length;
                                col++
                              )
                                _cell(
                                  col < widget.rows[row].length
                                      ? widget.rows[row][col]
                                      : '—',
                                  col,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cell(String value, int column, {bool header = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Text(
      value.trim().isEmpty ? '—' : value,
      textAlign: column == 0 ? TextAlign.left : TextAlign.right,
      style: TextStyle(
        fontSize: header ? 12 : 13,
        height: 1.5,
        color: header
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: header || column == 0 ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}
