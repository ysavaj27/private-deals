import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/shared/functions/on_back_logic.dart';

import 'pre_ipo_detail_page_ctrl.dart';
import 'pre_ipo_detail_sections.dart';
import 'seller_deals_board.dart';

/// Seller (Institution) detail: basic company header and market deals only.
class SellerPreIPODetailView extends StatelessWidget {
  const SellerPreIPODetailView({super.key, required this.phone});

  final bool phone;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PreIPODetailPageCtrl>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scaffold = Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBackPressed,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Flexible(
                    flex: 2,
                    child: Text(
                      'Unlisted shares',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) return const Loader();
                return SingleChildScrollView(
                  key: const ValueKey('seller-pre-ipo-details-scroll'),
                  padding: AppPagePadding.of(context, bottom: 40),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PreIPOCompanyHeader(company: c.model()),
                          const SizedBox(height: AppSpace.xl),
                          const SellerDealsBoard(),
                        ],
                      ),
                    ),
                  ),
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
