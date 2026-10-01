import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/investor_transaction/secondary/transaction_slip_dialog/transaction_slip_dialog_ctrl.dart';

class DesktopTransactionSlipDialogView extends StatelessWidget {
  final TransactionSlipDialogCtrl c = Get.find<TransactionSlipDialogCtrl>();

  DesktopTransactionSlipDialogView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCardWidget(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      color: context.theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${c.model.paymentSlipMessage}",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 21),
          DropTarget(
            onDragDone: (detail) {
              if (detail.files.isNotEmpty) {
                var filePath = detail.files.first.path;
                if (filePath.isImageFileName) {
                  var model = MediaModel(
                    type: FileType.image,
                    name: filePath.fileName,
                    dataType: FileDataType.filePath,
                  );
                  c.receipt(model);
                } else {
                  toast("Please drop image file only");
                }
              }
            },
            child: CustomDottedBorder(
              radius: 28,
              padding: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Obx(() {
                      if (c.receipt().isEmpty) {
                        return SVGImage(
                          AppAssets.uploadIc,
                          width: 62,
                          height: 52,
                        );
                      } else {
                        if (c.receipt().dataType == FileDataType.filePath &&
                            c.receipt().file != null) {
                          return Image.file(
                            c.receipt().file!,
                            width: 100,
                            height: 100,
                          );
                        } else if (c.receipt().uint8list != null) {
                          return Image.memory(
                            c.receipt().uint8list!,
                            width: 100,
                            height: 100,
                          );
                        }
                        return SizedBox();
                      }
                    }),
                    const SizedBox(height: 21),
                    Obx(() {
                      return Text(
                        c.receipt().isEmpty
                            ? c.model.paymentSlipMessage
                            : c.receipt().path.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                    const SizedBox(height: 25),
                    CustomElevatedButton(
                      text: "Upload",
                      radius: 10,
                      height: 45,
                      width: 140,
                      fontSize: 18,
                      onPressed: () async {
                        if (c.receipt().isEmpty) {
                          var res = await FilePickers().pickSingleImage();
                          c.receipt(res);
                        } else {
                          /// Upload File
                          c.uploadSlip();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomOutlinedButton(
                onPressed: Get.back,
                width: 140,
                height: 45,
                text: "Close",
              ),
              SizedBox(width: 50),
              Obx(() {
                return CustomElevatedButton(
                  isLoading: c.isUploading.value,
                  onPressed: c.uploadSlip,
                  width: 140,
                  height: 45,
                  text: "Submit",
                );
              }),
            ],
          ),
        ],
      ),
    );

/*
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
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 26),
          Text(
            "${c.model.paymentSlipMessage()}*",
            style: TextStyle(fontSize: 20),
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
            ),
          ),
          SizedBox(height: 38),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomOutlinedButton(
                width: 153,
                height: 42,
                onPressed: Get.back,
                text: 'Close',
              ),
              SizedBox(width: 24),
              Obx(() {
                return CustomElevatedButton(
                  isLoading: c.isUploading.value,
                  width: 153,
                  height: 42,
                  onPressed: c.uploadSlip,
                  text: 'Upload',
                );
              }),
            ],
          )
        ],
      ),
    );
*/
  }
}
