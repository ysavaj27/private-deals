import 'package:private_deals/src/features/catalog/presentation/primary/primary_detail_page/primary_detail_page_ctrl.dart';
import 'package:private_deals/src/shared/app_exports.dart';

class CommitNowDialog extends StatelessWidget {
  final PrimaryDetailPageCtrl c = Get.find<PrimaryDetailPageCtrl>();

  CommitNowDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      width: context.width * 0.95,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: c.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Commit",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: Get.back,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close_rounded),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 20),
            TitleTextField(
              name: 'Enter Amount',
              controller: c.commitCTRL,
              isRequired: true,
              keyboardType: TextInputType.number,
              maxLines: 1,
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return 'Enter valid amount';
                } else if (double.tryParse(p0) == null) {
                  return "Enter valid amount";
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomOutlinedButton(
                    height: 45,
                    onPressed: Get.back,
                    text: "Close",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    return CustomElevatedButton(
                      maximumSize: Size(40, double.infinity),
                      text: 'Commit Now',
                      isLoading: c.isCommitting.value,
                      onPressed: () {
                        if (c.formKey.currentState?.validate() ?? false) {
                          c.commit();
                        }
                      },
                    );
                  }),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
