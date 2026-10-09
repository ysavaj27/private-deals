import 'package:private_deals/src/shared/app_exports.dart';

import 'add_channel_partner_dialog_ctrl.dart';
import 'add_channel_partner_form.dart';

class AddChannelPartnerDialog extends StatefulWidget {
  const AddChannelPartnerDialog({super.key});

  @override
  State<AddChannelPartnerDialog> createState() =>
      _AddChannelPartnerDialogState();
}

class _AddChannelPartnerDialogState extends State<AddChannelPartnerDialog> {
  @override
  void initState() {
    super.initState();
    Get.put(AddChannelPartnerDialogCtrl(null));
  }

  @override
  void dispose() {
    Get.delete<AddChannelPartnerDialogCtrl>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(16),
    clipBehavior: Clip.antiAlias,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 820, maxHeight: 900),
      child: const AddChannelPartnerForm(),
    ),
  );
}
