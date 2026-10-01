import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/primary_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/widgets/transaction_card_widgets.dart';
import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/payment_receipt_dialog.dart';

class DesktopPrimaryTransactionView extends StatelessWidget {
  final PrimaryTransactionPageCtrl c = Get.put(PrimaryTransactionPageCtrl());

  DesktopPrimaryTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarTextField(onChanged: (p0) => c.search(p0)),
        const SizedBox(height: 18),
        Expanded(
          child: Obx(() {
            if (c.isLoading.isTrue) return const Loader();
            if (c.list.isEmpty) {
              return NoDataView(onPressed: c.getData);
            }
            return RefreshIndicator(
              onRefresh: c.getData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: c.finalList
                      .map((model) => _DesktopPrimaryCard(model: model, ctrl: c))
                      .toList(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DesktopPrimaryCard extends StatelessWidget {
  final PrimaryTransactionModel model;
  final PrimaryTransactionPageCtrl ctrl;

  const _DesktopPrimaryCard({required this.model, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return TransactionCardShell(
      width: 420,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionCardHeader(
            logoUrl: model.startup.cms.logo,
            title: model.startup.brandName,
            subtitle: model.investor.name,
            logoSize: 56,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TransactionAmountLabel(
                  amount: model.investmentAmount.toFormattedPrice,
                  caption: 'Invested',
                ),
                if (model.isVisible) _PrimaryDocsMenu(model: model),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TransactionStatusRow(
            currentStatus: model.currentStatus,
            nextStep: model.status == 6
                ? TransactionLinkAction(
                    label: 'Upload Receipt',
                    onPressed: () async {
                      await showCustomDialog(
                        PaymentReceiptDialog(model: model),
                      );
                      ctrl.clearData();
                    },
                  )
                : Text(model.nextStep),
          ),
          const SizedBox(height: 12),
          TransactionProgressSection(percentage: model.percentage),
        ],
      ),
    );
  }
}

class _PrimaryDocsMenu extends StatelessWidget {
  final PrimaryTransactionModel model;

  const _PrimaryDocsMenu({required this.model});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: context.theme.colorScheme.primary,
      ),
      onSelected: (String result) async {
        switch (result) {
          case 'SSA':
            await DownloadFile.downloadFromUrl(
              url: model.ssaDocument.signedPath,
              fileName: model.ssaDocument.meta.name,
            );
            break;
          case 'Offer':
            await DownloadFile.downloadFromUrl(
              url: model.offerDocument.signedPath,
              fileName: model.offerDocument.meta.name,
            );
            break;
          case 'SHA':
            await DownloadFile.downloadFromUrl(
              url: model.shaDocument.signedPath,
              fileName: model.shaDocument.meta.name,
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        final list = <PopupMenuEntry<String>>[];
        list.addIf(
          model.ssaDocument.signedPath.isNotEmpty,
          const PopupMenuItem<String>(value: 'SSA', child: Text('SSA')),
        );
        list.addIf(
          model.offerDocument.signedPath.isNotEmpty,
          const PopupMenuItem<String>(value: 'Offer', child: Text('Offer')),
        );
        list.addIf(
          model.shaDocument.signedPath.isNotEmpty,
          const PopupMenuItem<String>(value: 'SHA', child: Text('SHA')),
        );
        return list;
      },
    );
  }
}
