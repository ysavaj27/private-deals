import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/primary/primary_transaction_page_ctrl.dart';

class PaymentReceiptDialog extends StatelessWidget {
  final PrimaryTransactionModel model;
  final PrimaryTransactionPageCtrl c = Get.find<PrimaryTransactionPageCtrl>();

  PaymentReceiptDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      color: context.theme.scaffoldBackgroundColor,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Upload",
            style: TextStyle(
              fontSize: context.isPhone ? 20 : 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 26),
          Text(
            "${model.paymentSlipMessage()}*",
            style: TextStyle(
              fontSize: context.isPhone ? 16 : 20,
            ),
          ),
          SizedBox(height: 13),
          SizedBox(
            width: 384,
            child: CustomTextField(
              controller: c.receiptCTRL,
              hintText: 'No file Chosen',
              readOnly: true,
              onTap: () async {
                var res = await FilePickers().pickSingleImage();
                if (res != null) {
                  c.receiptCTRL.text = res.name;
                  c.receipt(res);
                }
              },
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return model.paymentSlipMessage();
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 38),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomOutlinedButton(
                width: context.isPhone ? 100 : 153,
                height: 42,
                onPressed: Get.back,
                text: 'Close',
              ),
              SizedBox(width: 24),
              Obx(() {
                return CustomElevatedButton(
                  isLoading: c.isUploading.value,
                  width: context.isPhone ? 100 : 153,
                  height: 42,
                  onPressed: () {
                    c.uploadSlip(model.id);
                  },
                  text: 'Upload',
                );
              }),
            ],
          )
        ],
      ),
    );
  }
}
