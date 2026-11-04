import 'package:private_deals/src/shared/app_exports.dart';

import 'investor_filter/investor_filter_dialog.dart';
import 'investors_page_ctrl.dart';

/// Matches the Channel Partner page: creation first, then directory controls.
class InvestorsToolbar extends StatelessWidget {
  const InvestorsToolbar({super.key});

  Future<void> _addInvestor(InvestorsPageCtrl controller) async {
    final saved = await Get.toNamed(
      Routes.addInvestorPath('/wealth-manager/${WTabBarEnum.investors.slug}'),
    );
    if (saved == true && !controller.isClosed) {
      await controller.getInvestorList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestorsPageCtrl>();
    final search = TextField(
      key: const ValueKey('investors-search'),
      controller: controller.controller,
      onChanged: controller.search,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search name, email or mobile',
        prefixIcon: Icon(Icons.search_rounded, size: 22),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
    final filters = OutlinedButton.icon(
      key: const ValueKey('investors-filter'),
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        showCustomDialog(const InvestorFilterDialog());
      },
      icon: const Icon(Icons.tune_rounded, size: 18),
      label: const Text('Filters'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
    final add = FilledButton.icon(
      key: const ValueKey('investors-add'),
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _addInvestor(controller);
      },
      icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
      label: const Text('Add investor'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerLeft, child: add),
        const SizedBox(height: AppSpace.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14)
                .clamp(1.0, 3.0);
            if (constraints.maxWidth >= 600 * textScale) {
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: AppSpace.lg),
                  filters,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: AppSpace.md),
                Align(alignment: Alignment.centerRight, child: filters),
              ],
            );
          },
        ),
      ],
    );
  }
}
