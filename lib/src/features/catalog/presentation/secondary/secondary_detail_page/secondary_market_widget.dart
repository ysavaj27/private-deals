import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog.dart';
import 'package:private_deals/src/features/catalog/presentation/secondary/secondary_transaction_dialog/secondary_transaction_dialog_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'secondary_detail_page_ctrl.dart';

class MarketWidget extends StatelessWidget {
  MarketWidget({super.key});

  final SecondaryDetailPageCtrl c = Get.find<SecondaryDetailPageCtrl>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final deals = c.model().deals;
      if (deals.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No market deals available right now.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    'Name',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Share Price',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Qty',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Action',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ListView.separated(
            shrinkWrap: true,
            itemCount: deals.length,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: AppColors.borderColor(context)),
            itemBuilder: (context, index) {
              final model = deals[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Anonymous ${index + 1}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          model.sharePrice.toCurrency,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          model.availableQuantity.toShowNum,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CustomOutlinedButton(
                          color: context.theme.primaryColor,
                          onPressed: () async {
                            final updatedModel = model.copyWith(
                              companySlug: c.model().slug,
                            );
                            await showCustomDialog(
                              SecondaryTransactionDialog(updatedModel),
                            );
                            await Get.delete<SecondaryTransactionDialogCtrl>();
                          },
                          width: 96,
                          height: 36,
                          text: 'Buy',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
