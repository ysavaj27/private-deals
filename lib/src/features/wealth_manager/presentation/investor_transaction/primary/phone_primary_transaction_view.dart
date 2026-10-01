import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/primary_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/widgets/transaction_card_widgets.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class PhonePrimaryTransactionView extends StatelessWidget {
  final PrimaryTransactionPageCtrl c = Get.put(PrimaryTransactionPageCtrl());

  PhonePrimaryTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          SearchBarTextField(
            hintText: "Search Startup",
            onChanged: (p0) => c.search(p0),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (c.isLoading.isTrue) return const Loader();
              if (c.finalList.isEmpty) {
                return NoDataView(onPressed: c.getData);
              }
              return RefreshIndicator(
                onRefresh: c.getData,
                child: ListView.builder(
                  itemCount: c.finalList.length,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      child: _PrimaryTransactionCard(model: c.finalList[index]),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PrimaryTransactionCard extends StatelessWidget {
  final PrimaryTransactionModel model;

  const _PrimaryTransactionCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return TransactionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TransactionCardHeader(
            logoUrl: model.startup.cms.logo,
            title: model.investor.name,
            subtitle: model.startup.brandName,
            logoSize: 44,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TransactionAmountLabel(
                  amount: model.investmentAmount.toFormattedPrice,
                ),
                if (model.isVisible) _PrimaryDocsMenu(model: model),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TransactionStatusRow(
            currentStatus: model.currentStatus,
            nextStep: Text(model.nextStep),
          ),
          const SizedBox(height: 10),
          TransactionProgressSection(
            percentage: model.percentage,
            compact: true,
          ),
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
        color: context.theme.colorScheme.primary,
        size: 20,
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
