import 'package:private_deals/src/shared/app_exports.dart';

import 'package:private_deals/src/features/wealth_manager/presentation/send_document/desktop_send_document_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/send_document/phone_send_document_view.dart';
import 'package:private_deals/src/features/wealth_manager/presentation/send_document/send_document_page_ctrl.dart';

class SendDocumentPage extends StatelessWidget {
  final SendDocumentPageCtrl c = Get.put(SendDocumentPageCtrl());

  SendDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return PhoneSendDocumentView();
    } else {
      return DesktopSendDocumentView();
    }
  }
}
