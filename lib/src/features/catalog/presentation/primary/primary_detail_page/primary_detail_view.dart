import 'package:flutter/rendering.dart';
import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'primary_detail_page_ctrl.dart';
import 'primary_detail_sections.dart';
import 'primary_investment_panel.dart';

/// The same section-based layout as Pre-IPO, with primary round terms.
class PrimaryDetailView extends StatefulWidget {
  const PrimaryDetailView({super.key, required this.phone});
  final bool phone;

  @override
  State<PrimaryDetailView> createState() => _PrimaryDetailViewState();
}

class _PrimaryDetailViewState extends State<PrimaryDetailView> {
  final _scroll = ScrollController();
  final _sections = List.generate(7, (_) => GlobalKey());
  final _navKeys = List.generate(7, (_) => GlobalKey());
  final _selected = ValueNotifier<int>(0);
  final _sectionOffsets = List<double?>.filled(7, null);
  bool _offsetRefreshScheduled = false;
  bool _jumping = false;

  static const _labels = [
    'Overview',
    'Key information',
    'Team',
    'Updates',
    'Investors',
    'FAQs',
    'Documents',
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_trackSection);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _selected.dispose();
    super.dispose();
  }

  double? _sectionOffset(int index) {
    final object = _sections[index].currentContext?.findRenderObject();
    if (object == null || !object.attached) return null;
    return RenderAbstractViewport.of(object)
        .getOffsetToReveal(object, 0)
        .offset;
  }

  void _refreshOffsetsAfterLayout() {
    if (_offsetRefreshScheduled) return;
    _offsetRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offsetRefreshScheduled = false;
      if (!mounted) return;
      for (var i = 0; i < _sections.length; i++) {
        _sectionOffsets[i] = _sectionOffset(i);
      }
      _trackSection();
    });
  }

  void _trackSection() {
    if (_jumping || !_scroll.hasClients) return;
    var current = 0;
    for (var i = 0; i < _sections.length; i++) {
      final offset = _sectionOffsets[i];
      if (offset != null && offset <= _scroll.offset + 60) current = i;
    }
    if (_scroll.offset > 0 && _scroll.position.extentAfter < 2) {
      current = _sections.length - 1;
    }
    if (current != _selected.value) _selected.value = current;
  }

  Future<void> _jumpTo(int index) async {
    if (!_scroll.hasClients) return;
    final offset = _sectionOffset(index);
    if (offset == null) return;
    _selected.value = index;
    _jumping = true;
    final navContext = _navKeys[index].currentContext;
    if (navContext != null) {
      Scrollable.ensureVisible(
        navContext,
        alignment: 0.5,
        duration: AppMotion.duration(context, AppMotion.normal),
      );
    }
    try {
      await _scroll.animateTo(
        index == 0 ? 0 : offset.clamp(0, _scroll.position.maxScrollExtent),
        duration: AppMotion.duration(context, AppMotion.normal),
        curve: Curves.easeInOut,
      );
    } finally {
      if (mounted) _jumping = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PrimaryDetailPageCtrl>();
    final colors = Theme.of(context).colorScheme;
    final scaffold = Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: colors.surface,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBackPressed,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      'Startup · Primary',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Company overview',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _selected,
              builder: (context, selected, _) => Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (var i = 0; i < _labels.length; i++)
                        Container(
                          key: _navKeys[i],
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selected.value == i
                                    ? colors.secondary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Obx(
                            () => TextButton(
                              key: ValueKey('primary-nav-$i'),
                              onPressed:
                                  c.isLoading.value ||
                                      c.loadError.isNotEmpty ||
                                      c.model.id == 0
                                  ? null
                                  : () => _jumpTo(i),
                              style: TextButton.styleFrom(
                                foregroundColor: _selected.value == i
                                    ? colors.onSurface
                                    : colors.onSurfaceVariant,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                minimumSize: const Size(48, 46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadii.tabAll,
                                ),
                              ),
                              child: Text(
                                _labels[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _selected.value == i
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) return const Loader();
                if (c.loadError.isNotEmpty || c.model.id == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 40,
                            color: colors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Startup details are unavailable',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c.loadError.isEmpty
                                ? 'Please try loading this startup again.'
                                : c.loadError.value,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: c.getData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final split = !widget.phone && constraints.maxWidth >= 1120;
                    final padding = widget.phone ? 16.0 : 28.0;
                    _refreshOffsetsAfterLayout();
                    final content =
                        NotificationListener<SizeChangedLayoutNotification>(
                          onNotification: (_) {
                            _refreshOffsetsAfterLayout();
                            return false;
                          },
                          child: SingleChildScrollView(
                            key: const ValueKey('primary-details-scroll'),
                            controller: _scroll,
                            padding: EdgeInsets.fromLTRB(
                              padding,
                              24,
                              padding,
                              40,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PrimaryCompanyHeader(model: c.model),
                                const SizedBox(height: 24),
                                if (!split) ...[
                                  PrimaryInvestmentPanel(c: c),
                                  const SizedBox(height: 24),
                                ],
                                PrimaryDetailSections(
                                  model: c.model,
                                  sectionKeys: _sections,
                                ),
                              ],
                            ),
                          ),
                        );
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1600),
                        child: split
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: content),
                                  SizedBox(
                                    width: 380,
                                    child: SingleChildScrollView(
                                      key: const ValueKey(
                                        'primary-investment-scroll',
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        24,
                                        28,
                                        24,
                                      ),
                                      child: PrimaryInvestmentPanel(c: c),
                                    ),
                                  ),
                                ],
                              )
                            : content,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
    if (widget.phone) return scaffold;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: scaffold,
    );
  }
}
