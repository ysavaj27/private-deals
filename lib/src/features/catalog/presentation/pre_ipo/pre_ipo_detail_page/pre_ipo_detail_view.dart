import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'pre_ipo_detail_page_ctrl.dart';
import 'pre_ipo_detail_sections.dart';
import 'pre_ipo_investor_card.dart';
import 'seller_slots_widget.dart';

/// Both layouts share the same information hierarchy and existing controller.
class PreIPODetailView extends StatelessWidget {
  const PreIPODetailView({super.key, required this.phone});

  final bool phone;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PreIPODetailPageCtrl>();
    final colors = Theme.of(context).colorScheme;
    final scaffold = Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: colors.surface,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: phone ? () => Get.back() : onBackPressed,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      'Unlisted shares',
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _SectionNavigation(c: c),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) return const Loader();
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final split = !phone && constraints.maxWidth >= 1120;
                    final padding = phone ? 16.0 : 28.0;
                    final content = SingleChildScrollView(
                      key: const ValueKey('pre-ipo-details-scroll'),
                      controller: c.scrollController,
                      padding: EdgeInsets.fromLTRB(padding, 24, padding, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PreIPOCompanyHeader(company: c.model()),
                          const SizedBox(height: 24),
                          if (!split) ...[
                            _InvestmentPanel(c: c, phone: phone),
                            const SizedBox(height: 24),
                          ],
                          PreIPODetailSections(
                            c: c,
                            phone: phone,
                            showPriceChart: true,
                          ),
                        ],
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
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        24,
                                        28,
                                        24,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: SingleChildScrollView(
                                              primary: false,
                                              child: _InvestmentPanel(
                                                c: c,
                                                phone: phone,
                                              ),
                                            ),
                                          ),
                                          _InvestButton(c: c),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(child: content),
                                  if (!phone)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                      ),
                                      child: _InvestButton(c: c),
                                    ),
                                ],
                              ),
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
    if (phone) return scaffold;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => onBackLogic(context, didPop),
      child: scaffold,
    );
  }
}

class _SectionNavigation extends StatelessWidget {
  const _SectionNavigation({required this.c});
  final PreIPODetailPageCtrl c;
  static const labels = [
    'Overview',
    'Fundamentals',
    'Financials',
    'Shareholding',
    'Peers',
    'Events',
    'Management',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            labels.length,
            (index) => Obx(() {
              final selected = c.tab.value == index;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? colors.secondary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: c.isLoading.value
                      ? null
                      : () {
                          if (c.sectionKeys[index].currentContext != null) {
                            c.scrollToSection(index);
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: selected
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(48, 46),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _InvestmentPanel extends StatelessWidget {
  const _InvestmentPanel({required this.c, required this.phone});
  final PreIPODetailPageCtrl c;
  final bool phone;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SellerSlotsWidget(),
      if (!phone)
        Form(
          key: c.desktopFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (c.investorList.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Your investment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review quantity and price for each investor.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final investor in c.investorList)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PreIPOInvestorCard(
                        key: ObjectKey(investor),
                        model: investor,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
    ],
  );
}

class _InvestButton extends StatelessWidget {
  const _InvestButton({required this.c});
  final PreIPODetailPageCtrl c;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (c.investorList.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CustomElevatedButton(
        radius: 12,
        isLoading: c.investing.value,
        backgroundColor: AppColors.preIpoButton(context),
        onPressed: () {
          if (c.desktopFormKey.currentState?.validate() ?? false) c.onPress();
        },
        text: 'Invest',
      ),
    );
  });
}
