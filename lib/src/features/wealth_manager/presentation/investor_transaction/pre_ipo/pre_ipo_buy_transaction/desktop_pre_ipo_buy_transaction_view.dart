import 'unlisted_transaction_card.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_buy_transaction_page_ctrl.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/pre_ipo/pre_ipo_buy_transaction/pre_ipo_order_detail_dialog.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class DesktopPreIPOBuyTransactionView extends StatelessWidget {
  final PreIPOBuyTransactionPageCtrl c = Get.put(
    PreIPOBuyTransactionPageCtrl(),
  );

  DesktopPreIPOBuyTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarTextField(
          onChanged: c.search,
          hintText: 'Search by company, investor, or status',
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Obx(() {
            if (c.isLoading.isTrue) return const Loader();
            if (c.finalList.isEmpty) {
              return NoDataView(onPressed: c.getData);
            }
            return RefreshIndicator(
              onRefresh: c.getData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: c.finalList.length,
                itemBuilder: (context, index) {
                  final order = c.finalList[index];
                  return _OrderCard(order: order, controller: c);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class PhonePreIPOBuyTransactionView extends StatelessWidget {
  final PreIPOBuyTransactionPageCtrl c = Get.put(
    PreIPOBuyTransactionPageCtrl(),
  );

  PhonePreIPOBuyTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarTextField(
          onChanged: c.search,
          hintText: 'Search transactions',
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (c.isLoading.isTrue) return const Loader();
            if (c.finalList.isEmpty) {
              return NoDataView(onPressed: c.getData);
            }
            return RefreshIndicator(
              onRefresh: c.getData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: c.finalList.length,
                itemBuilder: (context, index) {
                  final order = c.finalList[index];
                  return _OrderCard(order: order, controller: c);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final PreIpoOrderModel order;
  final PreIPOBuyTransactionPageCtrl controller;

  const _OrderCard({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => UnlistedTransactionCard(
        order: order,
        isActionLoading: controller.actionLoadingId.value == order.id,
        onDetails: () => showPreIpoOrderDetailDialog(
          order: order,
          onAction: (action) => controller.handleAction(order, action),
          loadDetail: () => controller.loadDetail(order.id),
        ),
        onAction: (action) => controller.handleAction(order, action),
      ),
    );
  }
}
